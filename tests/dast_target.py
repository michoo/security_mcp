"""Simple FastAPI target used by the DAST scanners (nuclei / zaproxy) in the
test harness.

It exposes a few endpoints, including one that intentionally reflects user
input without escaping, so a dynamic scanner has a live, deterministic target
to crawl. Run standalone with:

    uv run python tests/dast_target.py            # serves on http://127.0.0.1:8000

The test harness (test_scanners.py) starts and stops it automatically.
"""
import sys

from fastapi import FastAPI
from fastapi.responses import HTMLResponse

app = FastAPI(title="DAST test target")


@app.get("/")
def root():
    return {"service": "dast-test-target", "endpoints": ["/", "/ping", "/echo"]}


@app.get("/ping")
def ping():
    return {"pong": True}


@app.get("/echo", response_class=HTMLResponse)
def echo(msg: str = ""):
    # Intentionally reflects user input without escaping (test-only DAST target).
    return f"<html><body>You said: {msg}</body></html>"


if __name__ == "__main__":
    import uvicorn

    host = sys.argv[1] if len(sys.argv) > 1 else "127.0.0.1"
    port = int(sys.argv[2]) if len(sys.argv) > 2 else 8000
    uvicorn.run(app, host=host, port=port, log_level="warning")