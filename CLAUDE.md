# CLAUDE.md — conventions for this repository

Guidance for working in the **security MCP server**. The goal of this file is
that **every scanner is wired the same way**, so adding or changing one is a
mechanical, predictable process. When you add a tool, follow the checklist at
the bottom — touch every listed place, in the same style as the existing tools.

## What this project is

A FastMCP server (`server.py`) plus a CLI (`cli.py`) that run a set of security
scanners over a target and produce **SARIF 2.1.0** (or JSON for zaproxy), then
normalize, aggregate and deduplicate the findings into a consolidated report.

- Python 3.12+, package manager **uv** (`uv run python ...`, `uv sync`).
- Scanner binaries live under `tools/<family>/<tool>/` and are referenced by
  **relative paths** (`./tools/...`). Therefore the server and CLI must run from
  the repo root — `cli.py` does `os.chdir(REPO_ROOT)` for this reason.
- Generated reports go to `./reports/scan_<timestamp>_<mode>/` (git-ignored).

## Module map

| File | Role |
|------|------|
| `security/<tool>.py` | One module per scanner. Exposes a single async `*_impl(project_dir)` (or `(target_url)`, or `(project_dir, language)`) returning `List[types.TextContent]` whose text is raw SARIF/JSON. |
| `scanners.py` | **Single source of truth**: the `SCANNERS` registry (`Scanner` dataclass) + `scanners_for_mode()`. Everything downstream is driven by this list. |
| `report.py` | `extract_findings(tool, fmt, text)` normalizes SARIF/JSON → flat findings; `build_report()` + `render_json/md/html()` produce the consolidated report. |
| `aggregate.py` | Runs all scanners of a mode, dedupes (`deduplicate()`), and `run_and_persist()` writes the report. Backs the aggregated MCP tools. |
| `config.py` | Loads `.env` and resolves per-scanner toggles (`scanner_enabled()`, `env_var_for()`). |
| `server.py` | FastMCP tool definitions — one per scanner + the aggregated `static_scan`/`dynamic_scan`. |
| `cli.py` | Command-line runner. Picks up scanners from the registry automatically. |
| `tests/test_scanners.py` | End-to-end harness: one fixture per family under `tests/examples/`, asserts each scanner emits valid SARIF/JSON. |
| `tools/<family>/<tool>/install.sh` | Per-tool installer (relative paths, run from its own dir). `tools/install-all.sh` runs them all; `tools/uninstall.sh` removes binaries. |

## The scanner impl contract (`security/<tool>.py`)

Mirror the existing modules (e.g. `security/gitleaks.py` for a single-step
stdout scanner, `security/titus.py` for a scan→report datastore scanner). Every
impl:

- Defines `logger`, `TIMEOUT = 900`, and a `<tool>_path = "./tools/<family>/<tool>/<bin>"`.
- Is `async def <family>_<tool>_scan_impl(project_dir: str) -> List[types.TextContent]`.
- Guards empty input, runs via `subprocess.run(..., capture_output=True, text=True, timeout=TIMEOUT, check=False)`.
- Returns the **raw SARIF/JSON text** as a single `types.TextContent`.
- Handles `subprocess.TimeoutExpired`, `FileNotFoundError`, and generic
  `Exception` by returning a human-readable message (not raising).
- Prefers **fully-local** operation — no network/credential validation (e.g.
  kingfisher uses `--no-validate`, titus runs with no dynamic scoring).
- Emits **SARIF 2.1.0** (`"version": "2.1.0"`) where the tool supports it, so
  `report.extract_findings` parses it. JSON is only for tools with no SARIF
  (currently just zaproxy, `fmt="json"`).

### Conventions that must stay consistent

- **Scanner name** is lowercase, matches the `tools/` directory name (e.g.
  `osv-scanner`, `nosey_parker`, `trivy-misconfig`).
- **Env toggle var** = scanner name uppercased with `-`→`_` (`OSV_SCANNER`,
  `TRIVY_MISCONFIG`). Resolved by `config.env_var_for()`; never hardcode it.
- **Family** ∈ `SCA`, `Secret`, `SAST`, `Pipeline`, `DAST`, `IaC`, `License`.
- **Mode** = `STATIC` (scans a directory) or `DYNAMIC` (scans a URL).
- **A "graceful skip"** (prerequisite missing, not applicable) returns text
  starting with `SKIPPED:`. The CLI/aggregator classify those as `skipped`
  rather than `error` (see `_SKIP_MARKERS`). Use this instead of raising.

### How things flow automatically from the registry

Once a scanner is in `SCANNERS`, the **CLI**, **aggregated scans**, **reports**,
and **dedup** all pick it up with no further changes — they iterate
`scanners_for_mode(mode)`. You only add code by hand in `security/`, `scanners.py`,
`server.py` (the per-scanner MCP tool), the tests, and the docs/toggles.

## Findings & dedup

- A finding is `{rule, severity, message, location}` (`report.extract_findings`).
  Severity ∈ `critical|high|medium|low|info`.
- `aggregate.deduplicate()` collapses findings by **(location, message)** —
  case/whitespace-normalized — keeping the highest severity and unioning the
  contributing `tools` and `rules`. **Location is never dropped**, so distinct
  secrets/issues at distinct locations are always preserved.

## Adding a new scanner — checklist

Do **all** of these (this is the "everything" that keeps tools uniform):

1. **`tools/<family>/<tool>/install.sh`** — installer with pinned `VERSION` and a
   checksum check, relative paths, run from its own dir (mirror an existing one).
   It is auto-discovered by `tools/install-all.sh`.
2. **`security/<tool>.py`** — the `*_impl` following the contract above.
3. **`scanners.py`** — import the impl and add one `Scanner(...)` line to
   `SCANNERS` (set `needs_language=True` only if the tool needs a language, like
   codeql).
4. **`server.py`** — import the impl and add an `@mcp.tool()` +
   `@respects_toggle("<name>")` wrapper (decorator order matters: `@mcp.tool()`
   on top). Write a docstring in the same style as the siblings.
5. **`tests/test_scanners.py`** — import the impl and add a `run_sarif(...)` call
   in the matching family section. Use `min_results=1` if the fixture
   deterministically contains findings; add/extend a fixture under
   `tests/examples/<family>/` if none fits.
6. **`.env.example`** — add a commented `# <ENV_VAR>=false` line in the family
   section.
7. **`readme.md`** — list the tool under its family in **Features**.
8. Run `uv run python tests/test_scanners.py` and confirm the new scanner passes
   (and nothing regressed). Verify the MCP tool schema/registration and the
   toggle with a quick `server.mcp.list_tools()` check.

## Misc conventions

- Don't add Python dependencies casually; `config.py` falls back to a built-in
  `.env` parser rather than requiring `python-dotenv`.
- Keep the broad `except Exception` + `# noqa: BLE001` style already used across
  scanner impls and helpers — it is intentional (scanners must never crash the
  server/CLI).
- When cleaning up generated reports, delete only directories you created **by
  exact name** — never glob `reports/scan_*` (it can remove the user's reports;
  `reports/` is not tracked by git and not recoverable).
- New cloud/network/binary-replacing actions (e.g. running an installer that
  downloads ~hundreds of MB) should be confirmed with the user before running.
