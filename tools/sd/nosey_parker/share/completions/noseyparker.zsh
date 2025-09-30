#compdef noseyparker

autoload -U is-at-least

_noseyparker() {
    typeset -A opt_args
    typeset -a _arguments_options
    local ret=1

    if is-at-least 5.2; then
        _arguments_options=(-s -S -C)
    else
        _arguments_options=(-s -C)
    fi

    local context curcontext="$curcontext" state line
    _arguments "${_arguments_options[@]}" : \
'--color=[Enable or disable colored output]:MODE:(auto never always)' \
'--progress=[Enable or disable progress bars]:MODE:(auto never always)' \
'--rlimit-nofile=[Set the rlimit for number of open files to LIMIT]:LIMIT:_default' \
'--sqlite-cache-size=[Set the cache size for SQLite connections to SIZE]:SIZE:_default' \
'--enable-backtraces=[Enable or disable backtraces on panic]:BOOL:(true false)' \
'*-v[Enable verbose output]' \
'*--verbose[Enable verbose output]' \
'-q[Suppress non-error feedback messages]' \
'--quiet[Suppress non-error feedback messages]' \
'--ignore-certs[Ignore validation of TLS certificates]' \
'-h[Print help (see more with '\''--help'\'')]' \
'--help[Print help (see more with '\''--help'\'')]' \
'-V[Print version]' \
'--version[Print version]' \
":: :_noseyparker_commands" \
"*::: :->noseyparker" \
&& ret=0
    case $state in
    (noseyparker)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:noseyparker-command-$line[1]:"
        case $line[1] in
            (scan)
_arguments "${_arguments_options[@]}" : \
'-d+[Use the specified datastore]:PATH:_files -/' \
'--datastore=[Use the specified datastore]:PATH:_files -/' \
'-j+[Use N parallel scanning threads]:N:_default' \
'--jobs=[Use N parallel scanning threads]:N:_default' \
'*--rules-path=[Load additional rules and rulesets from the specified file or directory]:PATH:_files' \
'*--ruleset=[Enable the ruleset with the specified ID]:ID:_default' \
'--load-builtins=[Control whether built-in rules and rulesets are loaded]:BOOL:(true false)' \
'*--git-url=[Clone and scan the Git repository at the specified URL]:URL:_urls' \
'*--enumerator=[Read inputs from a JSONL enumerator file (experimental)]:PATH:_files' \
'*--github-user=[Clone and scan accessible repositories belonging to the specified GitHub user]:NAME:_default' \
'*--github-organization=[Clone and scan accessible repositories belonging to the specified GitHub organization]:NAME:_default' \
'*--github-org=[Clone and scan accessible repositories belonging to the specified GitHub organization]:NAME:_default' \
'--github-api-url=[Use the specified URL for GitHub API access]:URL:_urls' \
'--api-url=[Use the specified URL for GitHub API access]:URL:_urls' \
'--github-repo-type=[Clone and scan GitHub repos only of the given type]:TYPE:((all\:"Select both source repositories and fork repositories"
source\:"Only source repositories, i.e., ones that are not forks"
fork\:"Only fork repositories"))' \
'--git-clone=[Use the specified method for cloning Git repositories]:MODE:((bare\:"Match the behavior of \`git clone --bare\`"
mirror\:"Match the behavior of \`git clone --mirror\`"))' \
'--git-history=[Use the specified mode for handling Git history]:MODE:((full\:"Scan all history"
none\:"Scan no history"))' \
'--max-file-size=[Do not scan files larger than the specified size]:MEGABYTES:_default' \
'*-i+[Use custom path-based ignore rules from the specified file]:FILE:_files' \
'*--ignore=[Use custom path-based ignore rules from the specified file]:FILE:_files' \
'--blob-metadata=[Specify which blobs will have metadata recorded]:MODE:((all\:"Record metadata for all encountered blobs"
matching\:"Record metadata only for blobs with matches"
none\:"Record metadata for no blobs"))' \
'--git-blob-provenance=[Specify which Git commit provenance metadata will be collected]:MODE:((first-seen\:"The Git repository and set of commits and accompanying pathnames in which a blob is first seen"
minimal\:"Only the Git repository in which a blob is seen"))' \
'--snippet-length=[Include up to the specified number of bytes before and after each match]:BYTES:_default' \
'--copy-blobs=[Specify which blobs will be copied in entirety to the datastore]:MODE:((all\:"Copy all encountered blobs"
matching\:"Copy only blobs with matches"
none\:"Copy no blobs"))' \
'--copy-blobs-format=[Specify the format for blobs copied by the \`--copy-blobs\` option]:FORMAT:((parquet\:"Parquet format"
files\:"Plain files, similar to Git'\''s loose object format"))' \
'--color=[Enable or disable colored output]:MODE:(auto never always)' \
'--progress=[Enable or disable progress bars]:MODE:(auto never always)' \
'--rlimit-nofile=[Set the rlimit for number of open files to LIMIT]:LIMIT:_default' \
'--sqlite-cache-size=[Set the cache size for SQLite connections to SIZE]:SIZE:_default' \
'--enable-backtraces=[Enable or disable backtraces on panic]:BOOL:(true false)' \
'--all-github-organizations[Clone and scan accessible repositories from all accessible GitHub organizations]' \
'--all-github-orgs[Clone and scan accessible repositories from all accessible GitHub organizations]' \
'*-v[Enable verbose output]' \
'*--verbose[Enable verbose output]' \
'-q[Suppress non-error feedback messages]' \
'--quiet[Suppress non-error feedback messages]' \
'--ignore-certs[Ignore validation of TLS certificates]' \
'-h[Print help (see more with '\''--help'\'')]' \
'--help[Print help (see more with '\''--help'\'')]' \
'*::path_inputs -- Scan the specified file, directory, or local Git repository:_files' \
&& ret=0
;;
(summarize)
_arguments "${_arguments_options[@]}" : \
'-d+[Use the specified datastore]:PATH:_files -/' \
'--datastore=[Use the specified datastore]:PATH:_files -/' \
'-o+[Write output to the specified path]:PATH:_files' \
'--output=[Write output to the specified path]:PATH:_files' \
'-f+[Write output in the specified format]:FORMAT:((human\:"A text-based format designed for humans"
json\:"Pretty-printed JSON format"
jsonl\:"JSON Lines format"))' \
'--format=[Write output in the specified format]:FORMAT:((human\:"A text-based format designed for humans"
json\:"Pretty-printed JSON format"
jsonl\:"JSON Lines format"))' \
'--color=[Enable or disable colored output]:MODE:(auto never always)' \
'--progress=[Enable or disable progress bars]:MODE:(auto never always)' \
'--rlimit-nofile=[Set the rlimit for number of open files to LIMIT]:LIMIT:_default' \
'--sqlite-cache-size=[Set the cache size for SQLite connections to SIZE]:SIZE:_default' \
'--enable-backtraces=[Enable or disable backtraces on panic]:BOOL:(true false)' \
'*-v[Enable verbose output]' \
'*--verbose[Enable verbose output]' \
'-q[Suppress non-error feedback messages]' \
'--quiet[Suppress non-error feedback messages]' \
'--ignore-certs[Ignore validation of TLS certificates]' \
'-h[Print help (see more with '\''--help'\'')]' \
'--help[Print help (see more with '\''--help'\'')]' \
&& ret=0
;;
(report)
_arguments "${_arguments_options[@]}" : \
'-d+[Use the specified datastore]:PATH:_files -/' \
'--datastore=[Use the specified datastore]:PATH:_files -/' \
'--max-matches=[Limit the number of matches per finding to at most N]:N:_default' \
'--max-provenance=[Limit the number of provenance entries per match to at most N]:N:_default' \
'--min-score=[Only report findings that have a mean score of at least N]:SCORE:_default' \
'--finding-status=[Include only findings with the assigned status]:STATUS:((accept\:"Findings with \`accept\` matches"
reject\:"Findings with \`reject\` matches"
mixed\:"Findings with both \`accept\` and \`reject\` matches"
null\:"Findings without any \`accept\` or \`reject\` matches"))' \
'--suppress-redundant=[Suppress redundant matches and findings]:BOOL:(true false)' \
'-o+[Write output to the specified path]:PATH:_files' \
'--output=[Write output to the specified path]:PATH:_files' \
'-f+[Write output in the specified format]:FORMAT:((human\:"A text-based format designed for humans"
json\:"Pretty-printed JSON format"
jsonl\:"JSON Lines format"
sarif\:"SARIF format (experimental)"))' \
'--format=[Write output in the specified format]:FORMAT:((human\:"A text-based format designed for humans"
json\:"Pretty-printed JSON format"
jsonl\:"JSON Lines format"
sarif\:"SARIF format (experimental)"))' \
'--color=[Enable or disable colored output]:MODE:(auto never always)' \
'--progress=[Enable or disable progress bars]:MODE:(auto never always)' \
'--rlimit-nofile=[Set the rlimit for number of open files to LIMIT]:LIMIT:_default' \
'--sqlite-cache-size=[Set the cache size for SQLite connections to SIZE]:SIZE:_default' \
'--enable-backtraces=[Enable or disable backtraces on panic]:BOOL:(true false)' \
'*-v[Enable verbose output]' \
'*--verbose[Enable verbose output]' \
'-q[Suppress non-error feedback messages]' \
'--quiet[Suppress non-error feedback messages]' \
'--ignore-certs[Ignore validation of TLS certificates]' \
'-h[Print help (see more with '\''--help'\'')]' \
'--help[Print help (see more with '\''--help'\'')]' \
&& ret=0
;;
(github)
_arguments "${_arguments_options[@]}" : \
'--github-api-url=[Use the specified URL for GitHub API access]:URL:_urls' \
'--api-url=[Use the specified URL for GitHub API access]:URL:_urls' \
'--color=[Enable or disable colored output]:MODE:(auto never always)' \
'--progress=[Enable or disable progress bars]:MODE:(auto never always)' \
'--rlimit-nofile=[Set the rlimit for number of open files to LIMIT]:LIMIT:_default' \
'--sqlite-cache-size=[Set the cache size for SQLite connections to SIZE]:SIZE:_default' \
'--enable-backtraces=[Enable or disable backtraces on panic]:BOOL:(true false)' \
'*-v[Enable verbose output]' \
'*--verbose[Enable verbose output]' \
'-q[Suppress non-error feedback messages]' \
'--quiet[Suppress non-error feedback messages]' \
'--ignore-certs[Ignore validation of TLS certificates]' \
'-h[Print help (see more with '\''--help'\'')]' \
'--help[Print help (see more with '\''--help'\'')]' \
":: :_noseyparker__github_commands" \
"*::: :->github" \
&& ret=0

    case $state in
    (github)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:noseyparker-github-command-$line[1]:"
        case $line[1] in
            (repos)
_arguments "${_arguments_options[@]}" : \
'--github-api-url=[Use the specified URL for GitHub API access]:URL:_urls' \
'--api-url=[Use the specified URL for GitHub API access]:URL:_urls' \
'--color=[Enable or disable colored output]:MODE:(auto never always)' \
'--progress=[Enable or disable progress bars]:MODE:(auto never always)' \
'--rlimit-nofile=[Set the rlimit for number of open files to LIMIT]:LIMIT:_default' \
'--sqlite-cache-size=[Set the cache size for SQLite connections to SIZE]:SIZE:_default' \
'--enable-backtraces=[Enable or disable backtraces on panic]:BOOL:(true false)' \
'*-v[Enable verbose output]' \
'*--verbose[Enable verbose output]' \
'-q[Suppress non-error feedback messages]' \
'--quiet[Suppress non-error feedback messages]' \
'--ignore-certs[Ignore validation of TLS certificates]' \
'-h[Print help (see more with '\''--help'\'')]' \
'--help[Print help (see more with '\''--help'\'')]' \
":: :_noseyparker__github__repos_commands" \
"*::: :->repos" \
&& ret=0

    case $state in
    (repos)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:noseyparker-github-repos-command-$line[1]:"
        case $line[1] in
            (list)
_arguments "${_arguments_options[@]}" : \
'*--user=[Select repositories belonging to the specified user]:USER:_default' \
'*--github-user=[Select repositories belonging to the specified user]:USER:_default' \
'*--organization=[Select repositories belonging to the specified organization]:ORGANIZATION:_default' \
'*--org=[Select repositories belonging to the specified organization]:ORGANIZATION:_default' \
'*--github-organization=[Select repositories belonging to the specified organization]:ORGANIZATION:_default' \
'*--github-org=[Select repositories belonging to the specified organization]:ORGANIZATION:_default' \
'--repo-type=[Select only GitHub repos of the given type]:TYPE:((all\:"Select both source repositories and fork repositories"
source\:"Only source repositories, i.e., ones that are not forks"
fork\:"Only fork repositories"))' \
'--github-repo-type=[Select only GitHub repos of the given type]:TYPE:((all\:"Select both source repositories and fork repositories"
source\:"Only source repositories, i.e., ones that are not forks"
fork\:"Only fork repositories"))' \
'-o+[Write output to the specified path]:PATH:_files' \
'--output=[Write output to the specified path]:PATH:_files' \
'-f+[Write output in the specified format]:FORMAT:((human\:"A text-based format designed for humans"
json\:"Pretty-printed JSON format"
jsonl\:"JSON Lines format"))' \
'--format=[Write output in the specified format]:FORMAT:((human\:"A text-based format designed for humans"
json\:"Pretty-printed JSON format"
jsonl\:"JSON Lines format"))' \
'--github-api-url=[Use the specified URL for GitHub API access]:URL:_urls' \
'--api-url=[Use the specified URL for GitHub API access]:URL:_urls' \
'--color=[Enable or disable colored output]:MODE:(auto never always)' \
'--progress=[Enable or disable progress bars]:MODE:(auto never always)' \
'--rlimit-nofile=[Set the rlimit for number of open files to LIMIT]:LIMIT:_default' \
'--sqlite-cache-size=[Set the cache size for SQLite connections to SIZE]:SIZE:_default' \
'--enable-backtraces=[Enable or disable backtraces on panic]:BOOL:(true false)' \
'--all-organizations[Select repositories belonging to all organizations]' \
'--all-orgs[Select repositories belonging to all organizations]' \
'--all-github-organizations[Select repositories belonging to all organizations]' \
'--all-github-orgs[Select repositories belonging to all organizations]' \
'*-v[Enable verbose output]' \
'*--verbose[Enable verbose output]' \
'-q[Suppress non-error feedback messages]' \
'--quiet[Suppress non-error feedback messages]' \
'--ignore-certs[Ignore validation of TLS certificates]' \
'-h[Print help (see more with '\''--help'\'')]' \
'--help[Print help (see more with '\''--help'\'')]' \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
":: :_noseyparker__github__repos__help_commands" \
"*::: :->help" \
&& ret=0

    case $state in
    (help)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:noseyparker-github-repos-help-command-$line[1]:"
        case $line[1] in
            (list)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
        esac
    ;;
esac
;;
(help)
_arguments "${_arguments_options[@]}" : \
":: :_noseyparker__github__help_commands" \
"*::: :->help" \
&& ret=0

    case $state in
    (help)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:noseyparker-github-help-command-$line[1]:"
        case $line[1] in
            (repos)
_arguments "${_arguments_options[@]}" : \
":: :_noseyparker__github__help__repos_commands" \
"*::: :->repos" \
&& ret=0

    case $state in
    (repos)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:noseyparker-github-help-repos-command-$line[1]:"
        case $line[1] in
            (list)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
(help)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
        esac
    ;;
esac
;;
(datastore)
_arguments "${_arguments_options[@]}" : \
'--color=[Enable or disable colored output]:MODE:(auto never always)' \
'--progress=[Enable or disable progress bars]:MODE:(auto never always)' \
'--rlimit-nofile=[Set the rlimit for number of open files to LIMIT]:LIMIT:_default' \
'--sqlite-cache-size=[Set the cache size for SQLite connections to SIZE]:SIZE:_default' \
'--enable-backtraces=[Enable or disable backtraces on panic]:BOOL:(true false)' \
'*-v[Enable verbose output]' \
'*--verbose[Enable verbose output]' \
'-q[Suppress non-error feedback messages]' \
'--quiet[Suppress non-error feedback messages]' \
'--ignore-certs[Ignore validation of TLS certificates]' \
'-h[Print help (see more with '\''--help'\'')]' \
'--help[Print help (see more with '\''--help'\'')]' \
":: :_noseyparker__datastore_commands" \
"*::: :->datastore" \
&& ret=0

    case $state in
    (datastore)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:noseyparker-datastore-command-$line[1]:"
        case $line[1] in
            (init)
_arguments "${_arguments_options[@]}" : \
'-d+[Initialize the datastore at specified path]:PATH:_files -/' \
'--datastore=[Initialize the datastore at specified path]:PATH:_files -/' \
'--color=[Enable or disable colored output]:MODE:(auto never always)' \
'--progress=[Enable or disable progress bars]:MODE:(auto never always)' \
'--rlimit-nofile=[Set the rlimit for number of open files to LIMIT]:LIMIT:_default' \
'--sqlite-cache-size=[Set the cache size for SQLite connections to SIZE]:SIZE:_default' \
'--enable-backtraces=[Enable or disable backtraces on panic]:BOOL:(true false)' \
'*-v[Enable verbose output]' \
'*--verbose[Enable verbose output]' \
'-q[Suppress non-error feedback messages]' \
'--quiet[Suppress non-error feedback messages]' \
'--ignore-certs[Ignore validation of TLS certificates]' \
'-h[Print help (see more with '\''--help'\'')]' \
'--help[Print help (see more with '\''--help'\'')]' \
&& ret=0
;;
(export)
_arguments "${_arguments_options[@]}" : \
'-d+[Datastore to export]:PATH:_files -/' \
'--datastore=[Datastore to export]:PATH:_files -/' \
'-o+[Write output to the specified path]:PATH:_files' \
'--output=[Write output to the specified path]:PATH:_files' \
'-f+[Write output in the specified format]:FORMAT:((tgz\:"gzipped tarball"))' \
'--format=[Write output in the specified format]:FORMAT:((tgz\:"gzipped tarball"))' \
'--color=[Enable or disable colored output]:MODE:(auto never always)' \
'--progress=[Enable or disable progress bars]:MODE:(auto never always)' \
'--rlimit-nofile=[Set the rlimit for number of open files to LIMIT]:LIMIT:_default' \
'--sqlite-cache-size=[Set the cache size for SQLite connections to SIZE]:SIZE:_default' \
'--enable-backtraces=[Enable or disable backtraces on panic]:BOOL:(true false)' \
'*-v[Enable verbose output]' \
'*--verbose[Enable verbose output]' \
'-q[Suppress non-error feedback messages]' \
'--quiet[Suppress non-error feedback messages]' \
'--ignore-certs[Ignore validation of TLS certificates]' \
'-h[Print help (see more with '\''--help'\'')]' \
'--help[Print help (see more with '\''--help'\'')]' \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
":: :_noseyparker__datastore__help_commands" \
"*::: :->help" \
&& ret=0

    case $state in
    (help)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:noseyparker-datastore-help-command-$line[1]:"
        case $line[1] in
            (init)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(export)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
        esac
    ;;
esac
;;
(rules)
_arguments "${_arguments_options[@]}" : \
'--color=[Enable or disable colored output]:MODE:(auto never always)' \
'--progress=[Enable or disable progress bars]:MODE:(auto never always)' \
'--rlimit-nofile=[Set the rlimit for number of open files to LIMIT]:LIMIT:_default' \
'--sqlite-cache-size=[Set the cache size for SQLite connections to SIZE]:SIZE:_default' \
'--enable-backtraces=[Enable or disable backtraces on panic]:BOOL:(true false)' \
'*-v[Enable verbose output]' \
'*--verbose[Enable verbose output]' \
'-q[Suppress non-error feedback messages]' \
'--quiet[Suppress non-error feedback messages]' \
'--ignore-certs[Ignore validation of TLS certificates]' \
'-h[Print help (see more with '\''--help'\'')]' \
'--help[Print help (see more with '\''--help'\'')]' \
":: :_noseyparker__rules_commands" \
"*::: :->rules" \
&& ret=0

    case $state in
    (rules)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:noseyparker-rules-command-$line[1]:"
        case $line[1] in
            (check)
_arguments "${_arguments_options[@]}" : \
'*--rules-path=[Load additional rules and rulesets from the specified file or directory]:PATH:_files' \
'*--ruleset=[Enable the ruleset with the specified ID]:ID:_default' \
'--load-builtins=[Control whether built-in rules and rulesets are loaded]:BOOL:(true false)' \
'--color=[Enable or disable colored output]:MODE:(auto never always)' \
'--progress=[Enable or disable progress bars]:MODE:(auto never always)' \
'--rlimit-nofile=[Set the rlimit for number of open files to LIMIT]:LIMIT:_default' \
'--sqlite-cache-size=[Set the cache size for SQLite connections to SIZE]:SIZE:_default' \
'--enable-backtraces=[Enable or disable backtraces on panic]:BOOL:(true false)' \
'-W[Treat warnings as errors]' \
'--warnings-as-errors[Treat warnings as errors]' \
'--pedantic[Perform additional nit-picking checks]' \
'*-v[Enable verbose output]' \
'*--verbose[Enable verbose output]' \
'-q[Suppress non-error feedback messages]' \
'--quiet[Suppress non-error feedback messages]' \
'--ignore-certs[Ignore validation of TLS certificates]' \
'-h[Print help (see more with '\''--help'\'')]' \
'--help[Print help (see more with '\''--help'\'')]' \
&& ret=0
;;
(list)
_arguments "${_arguments_options[@]}" : \
'*--rules-path=[Load additional rules and rulesets from the specified file or directory]:PATH:_files' \
'*--ruleset=[Enable the ruleset with the specified ID]:ID:_default' \
'--load-builtins=[Control whether built-in rules and rulesets are loaded]:BOOL:(true false)' \
'-o+[Write output to the specified path]:PATH:_files' \
'--output=[Write output to the specified path]:PATH:_files' \
'-f+[Write output in the specified format]:FORMAT:((human\:"A text-based format designed for humans"
json\:"Pretty-printed JSON format"))' \
'--format=[Write output in the specified format]:FORMAT:((human\:"A text-based format designed for humans"
json\:"Pretty-printed JSON format"))' \
'--color=[Enable or disable colored output]:MODE:(auto never always)' \
'--progress=[Enable or disable progress bars]:MODE:(auto never always)' \
'--rlimit-nofile=[Set the rlimit for number of open files to LIMIT]:LIMIT:_default' \
'--sqlite-cache-size=[Set the cache size for SQLite connections to SIZE]:SIZE:_default' \
'--enable-backtraces=[Enable or disable backtraces on panic]:BOOL:(true false)' \
'*-v[Enable verbose output]' \
'*--verbose[Enable verbose output]' \
'-q[Suppress non-error feedback messages]' \
'--quiet[Suppress non-error feedback messages]' \
'--ignore-certs[Ignore validation of TLS certificates]' \
'-h[Print help (see more with '\''--help'\'')]' \
'--help[Print help (see more with '\''--help'\'')]' \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
":: :_noseyparker__rules__help_commands" \
"*::: :->help" \
&& ret=0

    case $state in
    (help)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:noseyparker-rules-help-command-$line[1]:"
        case $line[1] in
            (check)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(list)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
        esac
    ;;
esac
;;
(annotations)
_arguments "${_arguments_options[@]}" : \
'--color=[Enable or disable colored output]:MODE:(auto never always)' \
'--progress=[Enable or disable progress bars]:MODE:(auto never always)' \
'--rlimit-nofile=[Set the rlimit for number of open files to LIMIT]:LIMIT:_default' \
'--sqlite-cache-size=[Set the cache size for SQLite connections to SIZE]:SIZE:_default' \
'--enable-backtraces=[Enable or disable backtraces on panic]:BOOL:(true false)' \
'*-v[Enable verbose output]' \
'*--verbose[Enable verbose output]' \
'-q[Suppress non-error feedback messages]' \
'--quiet[Suppress non-error feedback messages]' \
'--ignore-certs[Ignore validation of TLS certificates]' \
'-h[Print help (see more with '\''--help'\'')]' \
'--help[Print help (see more with '\''--help'\'')]' \
":: :_noseyparker__annotations_commands" \
"*::: :->annotations" \
&& ret=0

    case $state in
    (annotations)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:noseyparker-annotations-command-$line[1]:"
        case $line[1] in
            (export)
_arguments "${_arguments_options[@]}" : \
'-d+[Use the specified datastore]:PATH:_files -/' \
'--datastore=[Use the specified datastore]:PATH:_files -/' \
'-o+[Write annotations to the specified path]:PATH:_files' \
'--output=[Write annotations to the specified path]:PATH:_files' \
'--color=[Enable or disable colored output]:MODE:(auto never always)' \
'--progress=[Enable or disable progress bars]:MODE:(auto never always)' \
'--rlimit-nofile=[Set the rlimit for number of open files to LIMIT]:LIMIT:_default' \
'--sqlite-cache-size=[Set the cache size for SQLite connections to SIZE]:SIZE:_default' \
'--enable-backtraces=[Enable or disable backtraces on panic]:BOOL:(true false)' \
'*-v[Enable verbose output]' \
'*--verbose[Enable verbose output]' \
'-q[Suppress non-error feedback messages]' \
'--quiet[Suppress non-error feedback messages]' \
'--ignore-certs[Ignore validation of TLS certificates]' \
'-h[Print help (see more with '\''--help'\'')]' \
'--help[Print help (see more with '\''--help'\'')]' \
&& ret=0
;;
(import)
_arguments "${_arguments_options[@]}" : \
'-d+[Use the specified datastore]:PATH:_files -/' \
'--datastore=[Use the specified datastore]:PATH:_files -/' \
'-i+[Read annotations from the specified path]:PATH:_files' \
'--input=[Read annotations from the specified path]:PATH:_files' \
'--color=[Enable or disable colored output]:MODE:(auto never always)' \
'--progress=[Enable or disable progress bars]:MODE:(auto never always)' \
'--rlimit-nofile=[Set the rlimit for number of open files to LIMIT]:LIMIT:_default' \
'--sqlite-cache-size=[Set the cache size for SQLite connections to SIZE]:SIZE:_default' \
'--enable-backtraces=[Enable or disable backtraces on panic]:BOOL:(true false)' \
'*-v[Enable verbose output]' \
'*--verbose[Enable verbose output]' \
'-q[Suppress non-error feedback messages]' \
'--quiet[Suppress non-error feedback messages]' \
'--ignore-certs[Ignore validation of TLS certificates]' \
'-h[Print help (see more with '\''--help'\'')]' \
'--help[Print help (see more with '\''--help'\'')]' \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
":: :_noseyparker__annotations__help_commands" \
"*::: :->help" \
&& ret=0

    case $state in
    (help)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:noseyparker-annotations-help-command-$line[1]:"
        case $line[1] in
            (export)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(import)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
        esac
    ;;
esac
;;
(generate)
_arguments "${_arguments_options[@]}" : \
'--color=[Enable or disable colored output]:MODE:(auto never always)' \
'--progress=[Enable or disable progress bars]:MODE:(auto never always)' \
'--rlimit-nofile=[Set the rlimit for number of open files to LIMIT]:LIMIT:_default' \
'--sqlite-cache-size=[Set the cache size for SQLite connections to SIZE]:SIZE:_default' \
'--enable-backtraces=[Enable or disable backtraces on panic]:BOOL:(true false)' \
'*-v[Enable verbose output]' \
'*--verbose[Enable verbose output]' \
'-q[Suppress non-error feedback messages]' \
'--quiet[Suppress non-error feedback messages]' \
'--ignore-certs[Ignore validation of TLS certificates]' \
'-h[Print help (see more with '\''--help'\'')]' \
'--help[Print help (see more with '\''--help'\'')]' \
":: :_noseyparker__generate_commands" \
"*::: :->generate" \
&& ret=0

    case $state in
    (generate)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:noseyparker-generate-command-$line[1]:"
        case $line[1] in
            (manpages)
_arguments "${_arguments_options[@]}" : \
'-o+[Write output to the specified directory]:PATH:_files -/' \
'--output=[Write output to the specified directory]:PATH:_files -/' \
'--color=[Enable or disable colored output]:MODE:(auto never always)' \
'--progress=[Enable or disable progress bars]:MODE:(auto never always)' \
'--rlimit-nofile=[Set the rlimit for number of open files to LIMIT]:LIMIT:_default' \
'--sqlite-cache-size=[Set the cache size for SQLite connections to SIZE]:SIZE:_default' \
'--enable-backtraces=[Enable or disable backtraces on panic]:BOOL:(true false)' \
'*-v[Enable verbose output]' \
'*--verbose[Enable verbose output]' \
'-q[Suppress non-error feedback messages]' \
'--quiet[Suppress non-error feedback messages]' \
'--ignore-certs[Ignore validation of TLS certificates]' \
'-h[Print help (see more with '\''--help'\'')]' \
'--help[Print help (see more with '\''--help'\'')]' \
&& ret=0
;;
(json-schema)
_arguments "${_arguments_options[@]}" : \
'-o+[Write output to the specified path]:PATH:_files' \
'--output=[Write output to the specified path]:PATH:_files' \
'--color=[Enable or disable colored output]:MODE:(auto never always)' \
'--progress=[Enable or disable progress bars]:MODE:(auto never always)' \
'--rlimit-nofile=[Set the rlimit for number of open files to LIMIT]:LIMIT:_default' \
'--sqlite-cache-size=[Set the cache size for SQLite connections to SIZE]:SIZE:_default' \
'--enable-backtraces=[Enable or disable backtraces on panic]:BOOL:(true false)' \
'*-v[Enable verbose output]' \
'*--verbose[Enable verbose output]' \
'-q[Suppress non-error feedback messages]' \
'--quiet[Suppress non-error feedback messages]' \
'--ignore-certs[Ignore validation of TLS certificates]' \
'-h[Print help (see more with '\''--help'\'')]' \
'--help[Print help (see more with '\''--help'\'')]' \
&& ret=0
;;
(shell-completions)
_arguments "${_arguments_options[@]}" : \
'-s+[]:SHELL:(bash zsh fish powershell elvish)' \
'--shell=[]:SHELL:(bash zsh fish powershell elvish)' \
'--color=[Enable or disable colored output]:MODE:(auto never always)' \
'--progress=[Enable or disable progress bars]:MODE:(auto never always)' \
'--rlimit-nofile=[Set the rlimit for number of open files to LIMIT]:LIMIT:_default' \
'--sqlite-cache-size=[Set the cache size for SQLite connections to SIZE]:SIZE:_default' \
'--enable-backtraces=[Enable or disable backtraces on panic]:BOOL:(true false)' \
'*-v[Enable verbose output]' \
'*--verbose[Enable verbose output]' \
'-q[Suppress non-error feedback messages]' \
'--quiet[Suppress non-error feedback messages]' \
'--ignore-certs[Ignore validation of TLS certificates]' \
'-h[Print help (see more with '\''--help'\'')]' \
'--help[Print help (see more with '\''--help'\'')]' \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
":: :_noseyparker__generate__help_commands" \
"*::: :->help" \
&& ret=0

    case $state in
    (help)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:noseyparker-generate-help-command-$line[1]:"
        case $line[1] in
            (manpages)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(json-schema)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(shell-completions)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
        esac
    ;;
esac
;;
(help)
_arguments "${_arguments_options[@]}" : \
":: :_noseyparker__help_commands" \
"*::: :->help" \
&& ret=0

    case $state in
    (help)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:noseyparker-help-command-$line[1]:"
        case $line[1] in
            (scan)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(summarize)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(report)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(github)
_arguments "${_arguments_options[@]}" : \
":: :_noseyparker__help__github_commands" \
"*::: :->github" \
&& ret=0

    case $state in
    (github)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:noseyparker-help-github-command-$line[1]:"
        case $line[1] in
            (repos)
_arguments "${_arguments_options[@]}" : \
":: :_noseyparker__help__github__repos_commands" \
"*::: :->repos" \
&& ret=0

    case $state in
    (repos)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:noseyparker-help-github-repos-command-$line[1]:"
        case $line[1] in
            (list)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
        esac
    ;;
esac
;;
(datastore)
_arguments "${_arguments_options[@]}" : \
":: :_noseyparker__help__datastore_commands" \
"*::: :->datastore" \
&& ret=0

    case $state in
    (datastore)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:noseyparker-help-datastore-command-$line[1]:"
        case $line[1] in
            (init)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(export)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
(rules)
_arguments "${_arguments_options[@]}" : \
":: :_noseyparker__help__rules_commands" \
"*::: :->rules" \
&& ret=0

    case $state in
    (rules)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:noseyparker-help-rules-command-$line[1]:"
        case $line[1] in
            (check)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(list)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
(annotations)
_arguments "${_arguments_options[@]}" : \
":: :_noseyparker__help__annotations_commands" \
"*::: :->annotations" \
&& ret=0

    case $state in
    (annotations)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:noseyparker-help-annotations-command-$line[1]:"
        case $line[1] in
            (export)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(import)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
(generate)
_arguments "${_arguments_options[@]}" : \
":: :_noseyparker__help__generate_commands" \
"*::: :->generate" \
&& ret=0

    case $state in
    (generate)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:noseyparker-help-generate-command-$line[1]:"
        case $line[1] in
            (manpages)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(json-schema)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(shell-completions)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
(help)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
        esac
    ;;
esac
}

(( $+functions[_noseyparker_commands] )) ||
_noseyparker_commands() {
    local commands; commands=(
'scan:Scan content for secrets' \
'summarize:Summarize scan findings' \
'report:Report detailed scan findings' \
'github:Interact with GitHub' \
'datastore:Manage datastores' \
'rules:Manage rules and rulesets' \
'annotations:Manage annotations (experimental)' \
'generate:Generate Nosey Parker release assets' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'noseyparker commands' commands "$@"
}
(( $+functions[_noseyparker__annotations_commands] )) ||
_noseyparker__annotations_commands() {
    local commands; commands=(
'export:Export annotations from a datastore (experimental)' \
'import:Import annotations into a datastore (experimental)' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'noseyparker annotations commands' commands "$@"
}
(( $+functions[_noseyparker__annotations__export_commands] )) ||
_noseyparker__annotations__export_commands() {
    local commands; commands=()
    _describe -t commands 'noseyparker annotations export commands' commands "$@"
}
(( $+functions[_noseyparker__annotations__help_commands] )) ||
_noseyparker__annotations__help_commands() {
    local commands; commands=(
'export:Export annotations from a datastore (experimental)' \
'import:Import annotations into a datastore (experimental)' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'noseyparker annotations help commands' commands "$@"
}
(( $+functions[_noseyparker__annotations__help__export_commands] )) ||
_noseyparker__annotations__help__export_commands() {
    local commands; commands=()
    _describe -t commands 'noseyparker annotations help export commands' commands "$@"
}
(( $+functions[_noseyparker__annotations__help__help_commands] )) ||
_noseyparker__annotations__help__help_commands() {
    local commands; commands=()
    _describe -t commands 'noseyparker annotations help help commands' commands "$@"
}
(( $+functions[_noseyparker__annotations__help__import_commands] )) ||
_noseyparker__annotations__help__import_commands() {
    local commands; commands=()
    _describe -t commands 'noseyparker annotations help import commands' commands "$@"
}
(( $+functions[_noseyparker__annotations__import_commands] )) ||
_noseyparker__annotations__import_commands() {
    local commands; commands=()
    _describe -t commands 'noseyparker annotations import commands' commands "$@"
}
(( $+functions[_noseyparker__datastore_commands] )) ||
_noseyparker__datastore_commands() {
    local commands; commands=(
'init:Initialize a new datastore' \
'export:Export a datastore' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'noseyparker datastore commands' commands "$@"
}
(( $+functions[_noseyparker__datastore__export_commands] )) ||
_noseyparker__datastore__export_commands() {
    local commands; commands=()
    _describe -t commands 'noseyparker datastore export commands' commands "$@"
}
(( $+functions[_noseyparker__datastore__help_commands] )) ||
_noseyparker__datastore__help_commands() {
    local commands; commands=(
'init:Initialize a new datastore' \
'export:Export a datastore' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'noseyparker datastore help commands' commands "$@"
}
(( $+functions[_noseyparker__datastore__help__export_commands] )) ||
_noseyparker__datastore__help__export_commands() {
    local commands; commands=()
    _describe -t commands 'noseyparker datastore help export commands' commands "$@"
}
(( $+functions[_noseyparker__datastore__help__help_commands] )) ||
_noseyparker__datastore__help__help_commands() {
    local commands; commands=()
    _describe -t commands 'noseyparker datastore help help commands' commands "$@"
}
(( $+functions[_noseyparker__datastore__help__init_commands] )) ||
_noseyparker__datastore__help__init_commands() {
    local commands; commands=()
    _describe -t commands 'noseyparker datastore help init commands' commands "$@"
}
(( $+functions[_noseyparker__datastore__init_commands] )) ||
_noseyparker__datastore__init_commands() {
    local commands; commands=()
    _describe -t commands 'noseyparker datastore init commands' commands "$@"
}
(( $+functions[_noseyparker__generate_commands] )) ||
_noseyparker__generate_commands() {
    local commands; commands=(
'manpages:Generate man pages' \
'json-schema:Generate the JSON schema for the output of the \`report\` command' \
'shell-completions:Generate shell completions' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'noseyparker generate commands' commands "$@"
}
(( $+functions[_noseyparker__generate__help_commands] )) ||
_noseyparker__generate__help_commands() {
    local commands; commands=(
'manpages:Generate man pages' \
'json-schema:Generate the JSON schema for the output of the \`report\` command' \
'shell-completions:Generate shell completions' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'noseyparker generate help commands' commands "$@"
}
(( $+functions[_noseyparker__generate__help__help_commands] )) ||
_noseyparker__generate__help__help_commands() {
    local commands; commands=()
    _describe -t commands 'noseyparker generate help help commands' commands "$@"
}
(( $+functions[_noseyparker__generate__help__json-schema_commands] )) ||
_noseyparker__generate__help__json-schema_commands() {
    local commands; commands=()
    _describe -t commands 'noseyparker generate help json-schema commands' commands "$@"
}
(( $+functions[_noseyparker__generate__help__manpages_commands] )) ||
_noseyparker__generate__help__manpages_commands() {
    local commands; commands=()
    _describe -t commands 'noseyparker generate help manpages commands' commands "$@"
}
(( $+functions[_noseyparker__generate__help__shell-completions_commands] )) ||
_noseyparker__generate__help__shell-completions_commands() {
    local commands; commands=()
    _describe -t commands 'noseyparker generate help shell-completions commands' commands "$@"
}
(( $+functions[_noseyparker__generate__json-schema_commands] )) ||
_noseyparker__generate__json-schema_commands() {
    local commands; commands=()
    _describe -t commands 'noseyparker generate json-schema commands' commands "$@"
}
(( $+functions[_noseyparker__generate__manpages_commands] )) ||
_noseyparker__generate__manpages_commands() {
    local commands; commands=()
    _describe -t commands 'noseyparker generate manpages commands' commands "$@"
}
(( $+functions[_noseyparker__generate__shell-completions_commands] )) ||
_noseyparker__generate__shell-completions_commands() {
    local commands; commands=()
    _describe -t commands 'noseyparker generate shell-completions commands' commands "$@"
}
(( $+functions[_noseyparker__github_commands] )) ||
_noseyparker__github_commands() {
    local commands; commands=(
'repos:Interact with GitHub repositories' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'noseyparker github commands' commands "$@"
}
(( $+functions[_noseyparker__github__help_commands] )) ||
_noseyparker__github__help_commands() {
    local commands; commands=(
'repos:Interact with GitHub repositories' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'noseyparker github help commands' commands "$@"
}
(( $+functions[_noseyparker__github__help__help_commands] )) ||
_noseyparker__github__help__help_commands() {
    local commands; commands=()
    _describe -t commands 'noseyparker github help help commands' commands "$@"
}
(( $+functions[_noseyparker__github__help__repos_commands] )) ||
_noseyparker__github__help__repos_commands() {
    local commands; commands=(
'list:List repositories belonging to a specific user or organization' \
    )
    _describe -t commands 'noseyparker github help repos commands' commands "$@"
}
(( $+functions[_noseyparker__github__help__repos__list_commands] )) ||
_noseyparker__github__help__repos__list_commands() {
    local commands; commands=()
    _describe -t commands 'noseyparker github help repos list commands' commands "$@"
}
(( $+functions[_noseyparker__github__repos_commands] )) ||
_noseyparker__github__repos_commands() {
    local commands; commands=(
'list:List repositories belonging to a specific user or organization' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'noseyparker github repos commands' commands "$@"
}
(( $+functions[_noseyparker__github__repos__help_commands] )) ||
_noseyparker__github__repos__help_commands() {
    local commands; commands=(
'list:List repositories belonging to a specific user or organization' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'noseyparker github repos help commands' commands "$@"
}
(( $+functions[_noseyparker__github__repos__help__help_commands] )) ||
_noseyparker__github__repos__help__help_commands() {
    local commands; commands=()
    _describe -t commands 'noseyparker github repos help help commands' commands "$@"
}
(( $+functions[_noseyparker__github__repos__help__list_commands] )) ||
_noseyparker__github__repos__help__list_commands() {
    local commands; commands=()
    _describe -t commands 'noseyparker github repos help list commands' commands "$@"
}
(( $+functions[_noseyparker__github__repos__list_commands] )) ||
_noseyparker__github__repos__list_commands() {
    local commands; commands=()
    _describe -t commands 'noseyparker github repos list commands' commands "$@"
}
(( $+functions[_noseyparker__help_commands] )) ||
_noseyparker__help_commands() {
    local commands; commands=(
'scan:Scan content for secrets' \
'summarize:Summarize scan findings' \
'report:Report detailed scan findings' \
'github:Interact with GitHub' \
'datastore:Manage datastores' \
'rules:Manage rules and rulesets' \
'annotations:Manage annotations (experimental)' \
'generate:Generate Nosey Parker release assets' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'noseyparker help commands' commands "$@"
}
(( $+functions[_noseyparker__help__annotations_commands] )) ||
_noseyparker__help__annotations_commands() {
    local commands; commands=(
'export:Export annotations from a datastore (experimental)' \
'import:Import annotations into a datastore (experimental)' \
    )
    _describe -t commands 'noseyparker help annotations commands' commands "$@"
}
(( $+functions[_noseyparker__help__annotations__export_commands] )) ||
_noseyparker__help__annotations__export_commands() {
    local commands; commands=()
    _describe -t commands 'noseyparker help annotations export commands' commands "$@"
}
(( $+functions[_noseyparker__help__annotations__import_commands] )) ||
_noseyparker__help__annotations__import_commands() {
    local commands; commands=()
    _describe -t commands 'noseyparker help annotations import commands' commands "$@"
}
(( $+functions[_noseyparker__help__datastore_commands] )) ||
_noseyparker__help__datastore_commands() {
    local commands; commands=(
'init:Initialize a new datastore' \
'export:Export a datastore' \
    )
    _describe -t commands 'noseyparker help datastore commands' commands "$@"
}
(( $+functions[_noseyparker__help__datastore__export_commands] )) ||
_noseyparker__help__datastore__export_commands() {
    local commands; commands=()
    _describe -t commands 'noseyparker help datastore export commands' commands "$@"
}
(( $+functions[_noseyparker__help__datastore__init_commands] )) ||
_noseyparker__help__datastore__init_commands() {
    local commands; commands=()
    _describe -t commands 'noseyparker help datastore init commands' commands "$@"
}
(( $+functions[_noseyparker__help__generate_commands] )) ||
_noseyparker__help__generate_commands() {
    local commands; commands=(
'manpages:Generate man pages' \
'json-schema:Generate the JSON schema for the output of the \`report\` command' \
'shell-completions:Generate shell completions' \
    )
    _describe -t commands 'noseyparker help generate commands' commands "$@"
}
(( $+functions[_noseyparker__help__generate__json-schema_commands] )) ||
_noseyparker__help__generate__json-schema_commands() {
    local commands; commands=()
    _describe -t commands 'noseyparker help generate json-schema commands' commands "$@"
}
(( $+functions[_noseyparker__help__generate__manpages_commands] )) ||
_noseyparker__help__generate__manpages_commands() {
    local commands; commands=()
    _describe -t commands 'noseyparker help generate manpages commands' commands "$@"
}
(( $+functions[_noseyparker__help__generate__shell-completions_commands] )) ||
_noseyparker__help__generate__shell-completions_commands() {
    local commands; commands=()
    _describe -t commands 'noseyparker help generate shell-completions commands' commands "$@"
}
(( $+functions[_noseyparker__help__github_commands] )) ||
_noseyparker__help__github_commands() {
    local commands; commands=(
'repos:Interact with GitHub repositories' \
    )
    _describe -t commands 'noseyparker help github commands' commands "$@"
}
(( $+functions[_noseyparker__help__github__repos_commands] )) ||
_noseyparker__help__github__repos_commands() {
    local commands; commands=(
'list:List repositories belonging to a specific user or organization' \
    )
    _describe -t commands 'noseyparker help github repos commands' commands "$@"
}
(( $+functions[_noseyparker__help__github__repos__list_commands] )) ||
_noseyparker__help__github__repos__list_commands() {
    local commands; commands=()
    _describe -t commands 'noseyparker help github repos list commands' commands "$@"
}
(( $+functions[_noseyparker__help__help_commands] )) ||
_noseyparker__help__help_commands() {
    local commands; commands=()
    _describe -t commands 'noseyparker help help commands' commands "$@"
}
(( $+functions[_noseyparker__help__report_commands] )) ||
_noseyparker__help__report_commands() {
    local commands; commands=()
    _describe -t commands 'noseyparker help report commands' commands "$@"
}
(( $+functions[_noseyparker__help__rules_commands] )) ||
_noseyparker__help__rules_commands() {
    local commands; commands=(
'check:Check rules for problems' \
'list:List available rules' \
    )
    _describe -t commands 'noseyparker help rules commands' commands "$@"
}
(( $+functions[_noseyparker__help__rules__check_commands] )) ||
_noseyparker__help__rules__check_commands() {
    local commands; commands=()
    _describe -t commands 'noseyparker help rules check commands' commands "$@"
}
(( $+functions[_noseyparker__help__rules__list_commands] )) ||
_noseyparker__help__rules__list_commands() {
    local commands; commands=()
    _describe -t commands 'noseyparker help rules list commands' commands "$@"
}
(( $+functions[_noseyparker__help__scan_commands] )) ||
_noseyparker__help__scan_commands() {
    local commands; commands=()
    _describe -t commands 'noseyparker help scan commands' commands "$@"
}
(( $+functions[_noseyparker__help__summarize_commands] )) ||
_noseyparker__help__summarize_commands() {
    local commands; commands=()
    _describe -t commands 'noseyparker help summarize commands' commands "$@"
}
(( $+functions[_noseyparker__report_commands] )) ||
_noseyparker__report_commands() {
    local commands; commands=()
    _describe -t commands 'noseyparker report commands' commands "$@"
}
(( $+functions[_noseyparker__rules_commands] )) ||
_noseyparker__rules_commands() {
    local commands; commands=(
'check:Check rules for problems' \
'list:List available rules' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'noseyparker rules commands' commands "$@"
}
(( $+functions[_noseyparker__rules__check_commands] )) ||
_noseyparker__rules__check_commands() {
    local commands; commands=()
    _describe -t commands 'noseyparker rules check commands' commands "$@"
}
(( $+functions[_noseyparker__rules__help_commands] )) ||
_noseyparker__rules__help_commands() {
    local commands; commands=(
'check:Check rules for problems' \
'list:List available rules' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'noseyparker rules help commands' commands "$@"
}
(( $+functions[_noseyparker__rules__help__check_commands] )) ||
_noseyparker__rules__help__check_commands() {
    local commands; commands=()
    _describe -t commands 'noseyparker rules help check commands' commands "$@"
}
(( $+functions[_noseyparker__rules__help__help_commands] )) ||
_noseyparker__rules__help__help_commands() {
    local commands; commands=()
    _describe -t commands 'noseyparker rules help help commands' commands "$@"
}
(( $+functions[_noseyparker__rules__help__list_commands] )) ||
_noseyparker__rules__help__list_commands() {
    local commands; commands=()
    _describe -t commands 'noseyparker rules help list commands' commands "$@"
}
(( $+functions[_noseyparker__rules__list_commands] )) ||
_noseyparker__rules__list_commands() {
    local commands; commands=()
    _describe -t commands 'noseyparker rules list commands' commands "$@"
}
(( $+functions[_noseyparker__scan_commands] )) ||
_noseyparker__scan_commands() {
    local commands; commands=()
    _describe -t commands 'noseyparker scan commands' commands "$@"
}
(( $+functions[_noseyparker__summarize_commands] )) ||
_noseyparker__summarize_commands() {
    local commands; commands=()
    _describe -t commands 'noseyparker summarize commands' commands "$@"
}

if [ "$funcstack[1]" = "_noseyparker" ]; then
    _noseyparker "$@"
else
    compdef _noseyparker noseyparker
fi
