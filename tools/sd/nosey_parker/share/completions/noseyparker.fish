# Print an optspec for argparse to handle cmd's options that are independent of any subcommand.
function __fish_noseyparker_global_optspecs
	string join \n v/verbose q/quiet color= progress= ignore-certs rlimit-nofile= sqlite-cache-size= enable-backtraces= h/help V/version
end

function __fish_noseyparker_needs_command
	# Figure out if the current invocation already has a command.
	set -l cmd (commandline -opc)
	set -e cmd[1]
	argparse -s (__fish_noseyparker_global_optspecs) -- $cmd 2>/dev/null
	or return
	if set -q argv[1]
		# Also print the command, so this can be used to figure out what it is.
		echo $argv[1]
		return 1
	end
	return 0
end

function __fish_noseyparker_using_subcommand
	set -l cmd (__fish_noseyparker_needs_command)
	test -z "$cmd"
	and return 1
	contains -- $cmd[1] $argv
end

complete -c noseyparker -n "__fish_noseyparker_needs_command" -l color -d 'Enable or disable colored output' -r -f -a "auto\t''
never\t''
always\t''"
complete -c noseyparker -n "__fish_noseyparker_needs_command" -l progress -d 'Enable or disable progress bars' -r -f -a "auto\t''
never\t''
always\t''"
complete -c noseyparker -n "__fish_noseyparker_needs_command" -l rlimit-nofile -d 'Set the rlimit for number of open files to LIMIT' -r
complete -c noseyparker -n "__fish_noseyparker_needs_command" -l sqlite-cache-size -d 'Set the cache size for SQLite connections to SIZE' -r
complete -c noseyparker -n "__fish_noseyparker_needs_command" -l enable-backtraces -d 'Enable or disable backtraces on panic' -r -f -a "true\t''
false\t''"
complete -c noseyparker -n "__fish_noseyparker_needs_command" -s v -l verbose -d 'Enable verbose output'
complete -c noseyparker -n "__fish_noseyparker_needs_command" -s q -l quiet -d 'Suppress non-error feedback messages'
complete -c noseyparker -n "__fish_noseyparker_needs_command" -l ignore-certs -d 'Ignore validation of TLS certificates'
complete -c noseyparker -n "__fish_noseyparker_needs_command" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c noseyparker -n "__fish_noseyparker_needs_command" -s V -l version -d 'Print version'
complete -c noseyparker -n "__fish_noseyparker_needs_command" -f -a "scan" -d 'Scan content for secrets'
complete -c noseyparker -n "__fish_noseyparker_needs_command" -f -a "summarize" -d 'Summarize scan findings'
complete -c noseyparker -n "__fish_noseyparker_needs_command" -f -a "report" -d 'Report detailed scan findings'
complete -c noseyparker -n "__fish_noseyparker_needs_command" -f -a "github" -d 'Interact with GitHub'
complete -c noseyparker -n "__fish_noseyparker_needs_command" -f -a "datastore" -d 'Manage datastores'
complete -c noseyparker -n "__fish_noseyparker_needs_command" -f -a "rules" -d 'Manage rules and rulesets'
complete -c noseyparker -n "__fish_noseyparker_needs_command" -f -a "annotations" -d 'Manage annotations (experimental)'
complete -c noseyparker -n "__fish_noseyparker_needs_command" -f -a "generate" -d 'Generate Nosey Parker release assets'
complete -c noseyparker -n "__fish_noseyparker_needs_command" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand scan" -s d -l datastore -d 'Use the specified datastore' -r -f -a "(__fish_complete_directories)"
complete -c noseyparker -n "__fish_noseyparker_using_subcommand scan" -s j -l jobs -d 'Use N parallel scanning threads' -r
complete -c noseyparker -n "__fish_noseyparker_using_subcommand scan" -l rules-path -d 'Load additional rules and rulesets from the specified file or directory' -r -F
complete -c noseyparker -n "__fish_noseyparker_using_subcommand scan" -l ruleset -d 'Enable the ruleset with the specified ID' -r
complete -c noseyparker -n "__fish_noseyparker_using_subcommand scan" -l load-builtins -d 'Control whether built-in rules and rulesets are loaded' -r -f -a "true\t''
false\t''"
complete -c noseyparker -n "__fish_noseyparker_using_subcommand scan" -l git-url -d 'Clone and scan the Git repository at the specified URL' -r -f
complete -c noseyparker -n "__fish_noseyparker_using_subcommand scan" -l enumerator -d 'Read inputs from a JSONL enumerator file (experimental)' -r -F
complete -c noseyparker -n "__fish_noseyparker_using_subcommand scan" -l github-user -d 'Clone and scan accessible repositories belonging to the specified GitHub user' -r
complete -c noseyparker -n "__fish_noseyparker_using_subcommand scan" -l github-organization -l github-org -d 'Clone and scan accessible repositories belonging to the specified GitHub organization' -r
complete -c noseyparker -n "__fish_noseyparker_using_subcommand scan" -l github-api-url -l api-url -d 'Use the specified URL for GitHub API access' -r -f
complete -c noseyparker -n "__fish_noseyparker_using_subcommand scan" -l github-repo-type -d 'Clone and scan GitHub repos only of the given type' -r -f -a "all\t'Select both source repositories and fork repositories'
source\t'Only source repositories, i.e., ones that are not forks'
fork\t'Only fork repositories'"
complete -c noseyparker -n "__fish_noseyparker_using_subcommand scan" -l git-clone -d 'Use the specified method for cloning Git repositories' -r -f -a "bare\t'Match the behavior of `git clone --bare`'
mirror\t'Match the behavior of `git clone --mirror`'"
complete -c noseyparker -n "__fish_noseyparker_using_subcommand scan" -l git-history -d 'Use the specified mode for handling Git history' -r -f -a "full\t'Scan all history'
none\t'Scan no history'"
complete -c noseyparker -n "__fish_noseyparker_using_subcommand scan" -l max-file-size -d 'Do not scan files larger than the specified size' -r
complete -c noseyparker -n "__fish_noseyparker_using_subcommand scan" -s i -l ignore -d 'Use custom path-based ignore rules from the specified file' -r -F
complete -c noseyparker -n "__fish_noseyparker_using_subcommand scan" -l blob-metadata -d 'Specify which blobs will have metadata recorded' -r -f -a "all\t'Record metadata for all encountered blobs'
matching\t'Record metadata only for blobs with matches'
none\t'Record metadata for no blobs'"
complete -c noseyparker -n "__fish_noseyparker_using_subcommand scan" -l git-blob-provenance -d 'Specify which Git commit provenance metadata will be collected' -r -f -a "first-seen\t'The Git repository and set of commits and accompanying pathnames in which a blob is first seen'
minimal\t'Only the Git repository in which a blob is seen'"
complete -c noseyparker -n "__fish_noseyparker_using_subcommand scan" -l snippet-length -d 'Include up to the specified number of bytes before and after each match' -r
complete -c noseyparker -n "__fish_noseyparker_using_subcommand scan" -l copy-blobs -d 'Specify which blobs will be copied in entirety to the datastore' -r -f -a "all\t'Copy all encountered blobs'
matching\t'Copy only blobs with matches'
none\t'Copy no blobs'"
complete -c noseyparker -n "__fish_noseyparker_using_subcommand scan" -l copy-blobs-format -d 'Specify the format for blobs copied by the `--copy-blobs` option' -r -f -a "parquet\t'Parquet format'
files\t'Plain files, similar to Git\'s loose object format'"
complete -c noseyparker -n "__fish_noseyparker_using_subcommand scan" -l color -d 'Enable or disable colored output' -r -f -a "auto\t''
never\t''
always\t''"
complete -c noseyparker -n "__fish_noseyparker_using_subcommand scan" -l progress -d 'Enable or disable progress bars' -r -f -a "auto\t''
never\t''
always\t''"
complete -c noseyparker -n "__fish_noseyparker_using_subcommand scan" -l rlimit-nofile -d 'Set the rlimit for number of open files to LIMIT' -r
complete -c noseyparker -n "__fish_noseyparker_using_subcommand scan" -l sqlite-cache-size -d 'Set the cache size for SQLite connections to SIZE' -r
complete -c noseyparker -n "__fish_noseyparker_using_subcommand scan" -l enable-backtraces -d 'Enable or disable backtraces on panic' -r -f -a "true\t''
false\t''"
complete -c noseyparker -n "__fish_noseyparker_using_subcommand scan" -l all-github-organizations -l all-github-orgs -d 'Clone and scan accessible repositories from all accessible GitHub organizations'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand scan" -s v -l verbose -d 'Enable verbose output'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand scan" -s q -l quiet -d 'Suppress non-error feedback messages'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand scan" -l ignore-certs -d 'Ignore validation of TLS certificates'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand scan" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand summarize" -s d -l datastore -d 'Use the specified datastore' -r -f -a "(__fish_complete_directories)"
complete -c noseyparker -n "__fish_noseyparker_using_subcommand summarize" -s o -l output -d 'Write output to the specified path' -r -F
complete -c noseyparker -n "__fish_noseyparker_using_subcommand summarize" -s f -l format -d 'Write output in the specified format' -r -f -a "human\t'A text-based format designed for humans'
json\t'Pretty-printed JSON format'
jsonl\t'JSON Lines format'"
complete -c noseyparker -n "__fish_noseyparker_using_subcommand summarize" -l color -d 'Enable or disable colored output' -r -f -a "auto\t''
never\t''
always\t''"
complete -c noseyparker -n "__fish_noseyparker_using_subcommand summarize" -l progress -d 'Enable or disable progress bars' -r -f -a "auto\t''
never\t''
always\t''"
complete -c noseyparker -n "__fish_noseyparker_using_subcommand summarize" -l rlimit-nofile -d 'Set the rlimit for number of open files to LIMIT' -r
complete -c noseyparker -n "__fish_noseyparker_using_subcommand summarize" -l sqlite-cache-size -d 'Set the cache size for SQLite connections to SIZE' -r
complete -c noseyparker -n "__fish_noseyparker_using_subcommand summarize" -l enable-backtraces -d 'Enable or disable backtraces on panic' -r -f -a "true\t''
false\t''"
complete -c noseyparker -n "__fish_noseyparker_using_subcommand summarize" -s v -l verbose -d 'Enable verbose output'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand summarize" -s q -l quiet -d 'Suppress non-error feedback messages'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand summarize" -l ignore-certs -d 'Ignore validation of TLS certificates'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand summarize" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand report" -s d -l datastore -d 'Use the specified datastore' -r -f -a "(__fish_complete_directories)"
complete -c noseyparker -n "__fish_noseyparker_using_subcommand report" -l max-matches -d 'Limit the number of matches per finding to at most N' -r
complete -c noseyparker -n "__fish_noseyparker_using_subcommand report" -l max-provenance -d 'Limit the number of provenance entries per match to at most N' -r
complete -c noseyparker -n "__fish_noseyparker_using_subcommand report" -l min-score -d 'Only report findings that have a mean score of at least N' -r
complete -c noseyparker -n "__fish_noseyparker_using_subcommand report" -l finding-status -d 'Include only findings with the assigned status' -r -f -a "accept\t'Findings with `accept` matches'
reject\t'Findings with `reject` matches'
mixed\t'Findings with both `accept` and `reject` matches'
null\t'Findings without any `accept` or `reject` matches'"
complete -c noseyparker -n "__fish_noseyparker_using_subcommand report" -l suppress-redundant -d 'Suppress redundant matches and findings' -r -f -a "true\t''
false\t''"
complete -c noseyparker -n "__fish_noseyparker_using_subcommand report" -s o -l output -d 'Write output to the specified path' -r -F
complete -c noseyparker -n "__fish_noseyparker_using_subcommand report" -s f -l format -d 'Write output in the specified format' -r -f -a "human\t'A text-based format designed for humans'
json\t'Pretty-printed JSON format'
jsonl\t'JSON Lines format'
sarif\t'SARIF format (experimental)'"
complete -c noseyparker -n "__fish_noseyparker_using_subcommand report" -l color -d 'Enable or disable colored output' -r -f -a "auto\t''
never\t''
always\t''"
complete -c noseyparker -n "__fish_noseyparker_using_subcommand report" -l progress -d 'Enable or disable progress bars' -r -f -a "auto\t''
never\t''
always\t''"
complete -c noseyparker -n "__fish_noseyparker_using_subcommand report" -l rlimit-nofile -d 'Set the rlimit for number of open files to LIMIT' -r
complete -c noseyparker -n "__fish_noseyparker_using_subcommand report" -l sqlite-cache-size -d 'Set the cache size for SQLite connections to SIZE' -r
complete -c noseyparker -n "__fish_noseyparker_using_subcommand report" -l enable-backtraces -d 'Enable or disable backtraces on panic' -r -f -a "true\t''
false\t''"
complete -c noseyparker -n "__fish_noseyparker_using_subcommand report" -s v -l verbose -d 'Enable verbose output'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand report" -s q -l quiet -d 'Suppress non-error feedback messages'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand report" -l ignore-certs -d 'Ignore validation of TLS certificates'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand report" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand github; and not __fish_seen_subcommand_from repos help" -l github-api-url -l api-url -d 'Use the specified URL for GitHub API access' -r -f
complete -c noseyparker -n "__fish_noseyparker_using_subcommand github; and not __fish_seen_subcommand_from repos help" -l color -d 'Enable or disable colored output' -r -f -a "auto\t''
never\t''
always\t''"
complete -c noseyparker -n "__fish_noseyparker_using_subcommand github; and not __fish_seen_subcommand_from repos help" -l progress -d 'Enable or disable progress bars' -r -f -a "auto\t''
never\t''
always\t''"
complete -c noseyparker -n "__fish_noseyparker_using_subcommand github; and not __fish_seen_subcommand_from repos help" -l rlimit-nofile -d 'Set the rlimit for number of open files to LIMIT' -r
complete -c noseyparker -n "__fish_noseyparker_using_subcommand github; and not __fish_seen_subcommand_from repos help" -l sqlite-cache-size -d 'Set the cache size for SQLite connections to SIZE' -r
complete -c noseyparker -n "__fish_noseyparker_using_subcommand github; and not __fish_seen_subcommand_from repos help" -l enable-backtraces -d 'Enable or disable backtraces on panic' -r -f -a "true\t''
false\t''"
complete -c noseyparker -n "__fish_noseyparker_using_subcommand github; and not __fish_seen_subcommand_from repos help" -s v -l verbose -d 'Enable verbose output'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand github; and not __fish_seen_subcommand_from repos help" -s q -l quiet -d 'Suppress non-error feedback messages'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand github; and not __fish_seen_subcommand_from repos help" -l ignore-certs -d 'Ignore validation of TLS certificates'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand github; and not __fish_seen_subcommand_from repos help" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand github; and not __fish_seen_subcommand_from repos help" -f -a "repos" -d 'Interact with GitHub repositories'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand github; and not __fish_seen_subcommand_from repos help" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand github; and __fish_seen_subcommand_from repos" -l github-api-url -l api-url -d 'Use the specified URL for GitHub API access' -r -f
complete -c noseyparker -n "__fish_noseyparker_using_subcommand github; and __fish_seen_subcommand_from repos" -l color -d 'Enable or disable colored output' -r -f -a "auto\t''
never\t''
always\t''"
complete -c noseyparker -n "__fish_noseyparker_using_subcommand github; and __fish_seen_subcommand_from repos" -l progress -d 'Enable or disable progress bars' -r -f -a "auto\t''
never\t''
always\t''"
complete -c noseyparker -n "__fish_noseyparker_using_subcommand github; and __fish_seen_subcommand_from repos" -l rlimit-nofile -d 'Set the rlimit for number of open files to LIMIT' -r
complete -c noseyparker -n "__fish_noseyparker_using_subcommand github; and __fish_seen_subcommand_from repos" -l sqlite-cache-size -d 'Set the cache size for SQLite connections to SIZE' -r
complete -c noseyparker -n "__fish_noseyparker_using_subcommand github; and __fish_seen_subcommand_from repos" -l enable-backtraces -d 'Enable or disable backtraces on panic' -r -f -a "true\t''
false\t''"
complete -c noseyparker -n "__fish_noseyparker_using_subcommand github; and __fish_seen_subcommand_from repos" -s v -l verbose -d 'Enable verbose output'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand github; and __fish_seen_subcommand_from repos" -s q -l quiet -d 'Suppress non-error feedback messages'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand github; and __fish_seen_subcommand_from repos" -l ignore-certs -d 'Ignore validation of TLS certificates'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand github; and __fish_seen_subcommand_from repos" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand github; and __fish_seen_subcommand_from repos" -f -a "list" -d 'List repositories belonging to a specific user or organization'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand github; and __fish_seen_subcommand_from repos" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand github; and __fish_seen_subcommand_from help" -f -a "repos" -d 'Interact with GitHub repositories'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand github; and __fish_seen_subcommand_from help" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand datastore; and not __fish_seen_subcommand_from init export help" -l color -d 'Enable or disable colored output' -r -f -a "auto\t''
never\t''
always\t''"
complete -c noseyparker -n "__fish_noseyparker_using_subcommand datastore; and not __fish_seen_subcommand_from init export help" -l progress -d 'Enable or disable progress bars' -r -f -a "auto\t''
never\t''
always\t''"
complete -c noseyparker -n "__fish_noseyparker_using_subcommand datastore; and not __fish_seen_subcommand_from init export help" -l rlimit-nofile -d 'Set the rlimit for number of open files to LIMIT' -r
complete -c noseyparker -n "__fish_noseyparker_using_subcommand datastore; and not __fish_seen_subcommand_from init export help" -l sqlite-cache-size -d 'Set the cache size for SQLite connections to SIZE' -r
complete -c noseyparker -n "__fish_noseyparker_using_subcommand datastore; and not __fish_seen_subcommand_from init export help" -l enable-backtraces -d 'Enable or disable backtraces on panic' -r -f -a "true\t''
false\t''"
complete -c noseyparker -n "__fish_noseyparker_using_subcommand datastore; and not __fish_seen_subcommand_from init export help" -s v -l verbose -d 'Enable verbose output'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand datastore; and not __fish_seen_subcommand_from init export help" -s q -l quiet -d 'Suppress non-error feedback messages'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand datastore; and not __fish_seen_subcommand_from init export help" -l ignore-certs -d 'Ignore validation of TLS certificates'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand datastore; and not __fish_seen_subcommand_from init export help" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand datastore; and not __fish_seen_subcommand_from init export help" -f -a "init" -d 'Initialize a new datastore'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand datastore; and not __fish_seen_subcommand_from init export help" -f -a "export" -d 'Export a datastore'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand datastore; and not __fish_seen_subcommand_from init export help" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand datastore; and __fish_seen_subcommand_from init" -s d -l datastore -d 'Initialize the datastore at specified path' -r -f -a "(__fish_complete_directories)"
complete -c noseyparker -n "__fish_noseyparker_using_subcommand datastore; and __fish_seen_subcommand_from init" -l color -d 'Enable or disable colored output' -r -f -a "auto\t''
never\t''
always\t''"
complete -c noseyparker -n "__fish_noseyparker_using_subcommand datastore; and __fish_seen_subcommand_from init" -l progress -d 'Enable or disable progress bars' -r -f -a "auto\t''
never\t''
always\t''"
complete -c noseyparker -n "__fish_noseyparker_using_subcommand datastore; and __fish_seen_subcommand_from init" -l rlimit-nofile -d 'Set the rlimit for number of open files to LIMIT' -r
complete -c noseyparker -n "__fish_noseyparker_using_subcommand datastore; and __fish_seen_subcommand_from init" -l sqlite-cache-size -d 'Set the cache size for SQLite connections to SIZE' -r
complete -c noseyparker -n "__fish_noseyparker_using_subcommand datastore; and __fish_seen_subcommand_from init" -l enable-backtraces -d 'Enable or disable backtraces on panic' -r -f -a "true\t''
false\t''"
complete -c noseyparker -n "__fish_noseyparker_using_subcommand datastore; and __fish_seen_subcommand_from init" -s v -l verbose -d 'Enable verbose output'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand datastore; and __fish_seen_subcommand_from init" -s q -l quiet -d 'Suppress non-error feedback messages'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand datastore; and __fish_seen_subcommand_from init" -l ignore-certs -d 'Ignore validation of TLS certificates'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand datastore; and __fish_seen_subcommand_from init" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand datastore; and __fish_seen_subcommand_from export" -s d -l datastore -d 'Datastore to export' -r -f -a "(__fish_complete_directories)"
complete -c noseyparker -n "__fish_noseyparker_using_subcommand datastore; and __fish_seen_subcommand_from export" -s o -l output -d 'Write output to the specified path' -r -F
complete -c noseyparker -n "__fish_noseyparker_using_subcommand datastore; and __fish_seen_subcommand_from export" -s f -l format -d 'Write output in the specified format' -r -f -a "tgz\t'gzipped tarball'"
complete -c noseyparker -n "__fish_noseyparker_using_subcommand datastore; and __fish_seen_subcommand_from export" -l color -d 'Enable or disable colored output' -r -f -a "auto\t''
never\t''
always\t''"
complete -c noseyparker -n "__fish_noseyparker_using_subcommand datastore; and __fish_seen_subcommand_from export" -l progress -d 'Enable or disable progress bars' -r -f -a "auto\t''
never\t''
always\t''"
complete -c noseyparker -n "__fish_noseyparker_using_subcommand datastore; and __fish_seen_subcommand_from export" -l rlimit-nofile -d 'Set the rlimit for number of open files to LIMIT' -r
complete -c noseyparker -n "__fish_noseyparker_using_subcommand datastore; and __fish_seen_subcommand_from export" -l sqlite-cache-size -d 'Set the cache size for SQLite connections to SIZE' -r
complete -c noseyparker -n "__fish_noseyparker_using_subcommand datastore; and __fish_seen_subcommand_from export" -l enable-backtraces -d 'Enable or disable backtraces on panic' -r -f -a "true\t''
false\t''"
complete -c noseyparker -n "__fish_noseyparker_using_subcommand datastore; and __fish_seen_subcommand_from export" -s v -l verbose -d 'Enable verbose output'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand datastore; and __fish_seen_subcommand_from export" -s q -l quiet -d 'Suppress non-error feedback messages'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand datastore; and __fish_seen_subcommand_from export" -l ignore-certs -d 'Ignore validation of TLS certificates'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand datastore; and __fish_seen_subcommand_from export" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand datastore; and __fish_seen_subcommand_from help" -f -a "init" -d 'Initialize a new datastore'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand datastore; and __fish_seen_subcommand_from help" -f -a "export" -d 'Export a datastore'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand datastore; and __fish_seen_subcommand_from help" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand rules; and not __fish_seen_subcommand_from check list help" -l color -d 'Enable or disable colored output' -r -f -a "auto\t''
never\t''
always\t''"
complete -c noseyparker -n "__fish_noseyparker_using_subcommand rules; and not __fish_seen_subcommand_from check list help" -l progress -d 'Enable or disable progress bars' -r -f -a "auto\t''
never\t''
always\t''"
complete -c noseyparker -n "__fish_noseyparker_using_subcommand rules; and not __fish_seen_subcommand_from check list help" -l rlimit-nofile -d 'Set the rlimit for number of open files to LIMIT' -r
complete -c noseyparker -n "__fish_noseyparker_using_subcommand rules; and not __fish_seen_subcommand_from check list help" -l sqlite-cache-size -d 'Set the cache size for SQLite connections to SIZE' -r
complete -c noseyparker -n "__fish_noseyparker_using_subcommand rules; and not __fish_seen_subcommand_from check list help" -l enable-backtraces -d 'Enable or disable backtraces on panic' -r -f -a "true\t''
false\t''"
complete -c noseyparker -n "__fish_noseyparker_using_subcommand rules; and not __fish_seen_subcommand_from check list help" -s v -l verbose -d 'Enable verbose output'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand rules; and not __fish_seen_subcommand_from check list help" -s q -l quiet -d 'Suppress non-error feedback messages'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand rules; and not __fish_seen_subcommand_from check list help" -l ignore-certs -d 'Ignore validation of TLS certificates'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand rules; and not __fish_seen_subcommand_from check list help" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand rules; and not __fish_seen_subcommand_from check list help" -f -a "check" -d 'Check rules for problems'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand rules; and not __fish_seen_subcommand_from check list help" -f -a "list" -d 'List available rules'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand rules; and not __fish_seen_subcommand_from check list help" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand rules; and __fish_seen_subcommand_from check" -l rules-path -d 'Load additional rules and rulesets from the specified file or directory' -r -F
complete -c noseyparker -n "__fish_noseyparker_using_subcommand rules; and __fish_seen_subcommand_from check" -l ruleset -d 'Enable the ruleset with the specified ID' -r
complete -c noseyparker -n "__fish_noseyparker_using_subcommand rules; and __fish_seen_subcommand_from check" -l load-builtins -d 'Control whether built-in rules and rulesets are loaded' -r -f -a "true\t''
false\t''"
complete -c noseyparker -n "__fish_noseyparker_using_subcommand rules; and __fish_seen_subcommand_from check" -l color -d 'Enable or disable colored output' -r -f -a "auto\t''
never\t''
always\t''"
complete -c noseyparker -n "__fish_noseyparker_using_subcommand rules; and __fish_seen_subcommand_from check" -l progress -d 'Enable or disable progress bars' -r -f -a "auto\t''
never\t''
always\t''"
complete -c noseyparker -n "__fish_noseyparker_using_subcommand rules; and __fish_seen_subcommand_from check" -l rlimit-nofile -d 'Set the rlimit for number of open files to LIMIT' -r
complete -c noseyparker -n "__fish_noseyparker_using_subcommand rules; and __fish_seen_subcommand_from check" -l sqlite-cache-size -d 'Set the cache size for SQLite connections to SIZE' -r
complete -c noseyparker -n "__fish_noseyparker_using_subcommand rules; and __fish_seen_subcommand_from check" -l enable-backtraces -d 'Enable or disable backtraces on panic' -r -f -a "true\t''
false\t''"
complete -c noseyparker -n "__fish_noseyparker_using_subcommand rules; and __fish_seen_subcommand_from check" -s W -l warnings-as-errors -d 'Treat warnings as errors'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand rules; and __fish_seen_subcommand_from check" -l pedantic -d 'Perform additional nit-picking checks'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand rules; and __fish_seen_subcommand_from check" -s v -l verbose -d 'Enable verbose output'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand rules; and __fish_seen_subcommand_from check" -s q -l quiet -d 'Suppress non-error feedback messages'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand rules; and __fish_seen_subcommand_from check" -l ignore-certs -d 'Ignore validation of TLS certificates'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand rules; and __fish_seen_subcommand_from check" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand rules; and __fish_seen_subcommand_from list" -l rules-path -d 'Load additional rules and rulesets from the specified file or directory' -r -F
complete -c noseyparker -n "__fish_noseyparker_using_subcommand rules; and __fish_seen_subcommand_from list" -l ruleset -d 'Enable the ruleset with the specified ID' -r
complete -c noseyparker -n "__fish_noseyparker_using_subcommand rules; and __fish_seen_subcommand_from list" -l load-builtins -d 'Control whether built-in rules and rulesets are loaded' -r -f -a "true\t''
false\t''"
complete -c noseyparker -n "__fish_noseyparker_using_subcommand rules; and __fish_seen_subcommand_from list" -s o -l output -d 'Write output to the specified path' -r -F
complete -c noseyparker -n "__fish_noseyparker_using_subcommand rules; and __fish_seen_subcommand_from list" -s f -l format -d 'Write output in the specified format' -r -f -a "human\t'A text-based format designed for humans'
json\t'Pretty-printed JSON format'"
complete -c noseyparker -n "__fish_noseyparker_using_subcommand rules; and __fish_seen_subcommand_from list" -l color -d 'Enable or disable colored output' -r -f -a "auto\t''
never\t''
always\t''"
complete -c noseyparker -n "__fish_noseyparker_using_subcommand rules; and __fish_seen_subcommand_from list" -l progress -d 'Enable or disable progress bars' -r -f -a "auto\t''
never\t''
always\t''"
complete -c noseyparker -n "__fish_noseyparker_using_subcommand rules; and __fish_seen_subcommand_from list" -l rlimit-nofile -d 'Set the rlimit for number of open files to LIMIT' -r
complete -c noseyparker -n "__fish_noseyparker_using_subcommand rules; and __fish_seen_subcommand_from list" -l sqlite-cache-size -d 'Set the cache size for SQLite connections to SIZE' -r
complete -c noseyparker -n "__fish_noseyparker_using_subcommand rules; and __fish_seen_subcommand_from list" -l enable-backtraces -d 'Enable or disable backtraces on panic' -r -f -a "true\t''
false\t''"
complete -c noseyparker -n "__fish_noseyparker_using_subcommand rules; and __fish_seen_subcommand_from list" -s v -l verbose -d 'Enable verbose output'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand rules; and __fish_seen_subcommand_from list" -s q -l quiet -d 'Suppress non-error feedback messages'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand rules; and __fish_seen_subcommand_from list" -l ignore-certs -d 'Ignore validation of TLS certificates'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand rules; and __fish_seen_subcommand_from list" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand rules; and __fish_seen_subcommand_from help" -f -a "check" -d 'Check rules for problems'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand rules; and __fish_seen_subcommand_from help" -f -a "list" -d 'List available rules'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand rules; and __fish_seen_subcommand_from help" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand annotations; and not __fish_seen_subcommand_from export import help" -l color -d 'Enable or disable colored output' -r -f -a "auto\t''
never\t''
always\t''"
complete -c noseyparker -n "__fish_noseyparker_using_subcommand annotations; and not __fish_seen_subcommand_from export import help" -l progress -d 'Enable or disable progress bars' -r -f -a "auto\t''
never\t''
always\t''"
complete -c noseyparker -n "__fish_noseyparker_using_subcommand annotations; and not __fish_seen_subcommand_from export import help" -l rlimit-nofile -d 'Set the rlimit for number of open files to LIMIT' -r
complete -c noseyparker -n "__fish_noseyparker_using_subcommand annotations; and not __fish_seen_subcommand_from export import help" -l sqlite-cache-size -d 'Set the cache size for SQLite connections to SIZE' -r
complete -c noseyparker -n "__fish_noseyparker_using_subcommand annotations; and not __fish_seen_subcommand_from export import help" -l enable-backtraces -d 'Enable or disable backtraces on panic' -r -f -a "true\t''
false\t''"
complete -c noseyparker -n "__fish_noseyparker_using_subcommand annotations; and not __fish_seen_subcommand_from export import help" -s v -l verbose -d 'Enable verbose output'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand annotations; and not __fish_seen_subcommand_from export import help" -s q -l quiet -d 'Suppress non-error feedback messages'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand annotations; and not __fish_seen_subcommand_from export import help" -l ignore-certs -d 'Ignore validation of TLS certificates'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand annotations; and not __fish_seen_subcommand_from export import help" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand annotations; and not __fish_seen_subcommand_from export import help" -f -a "export" -d 'Export annotations from a datastore (experimental)'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand annotations; and not __fish_seen_subcommand_from export import help" -f -a "import" -d 'Import annotations into a datastore (experimental)'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand annotations; and not __fish_seen_subcommand_from export import help" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand annotations; and __fish_seen_subcommand_from export" -s d -l datastore -d 'Use the specified datastore' -r -f -a "(__fish_complete_directories)"
complete -c noseyparker -n "__fish_noseyparker_using_subcommand annotations; and __fish_seen_subcommand_from export" -s o -l output -d 'Write annotations to the specified path' -r -F
complete -c noseyparker -n "__fish_noseyparker_using_subcommand annotations; and __fish_seen_subcommand_from export" -l color -d 'Enable or disable colored output' -r -f -a "auto\t''
never\t''
always\t''"
complete -c noseyparker -n "__fish_noseyparker_using_subcommand annotations; and __fish_seen_subcommand_from export" -l progress -d 'Enable or disable progress bars' -r -f -a "auto\t''
never\t''
always\t''"
complete -c noseyparker -n "__fish_noseyparker_using_subcommand annotations; and __fish_seen_subcommand_from export" -l rlimit-nofile -d 'Set the rlimit for number of open files to LIMIT' -r
complete -c noseyparker -n "__fish_noseyparker_using_subcommand annotations; and __fish_seen_subcommand_from export" -l sqlite-cache-size -d 'Set the cache size for SQLite connections to SIZE' -r
complete -c noseyparker -n "__fish_noseyparker_using_subcommand annotations; and __fish_seen_subcommand_from export" -l enable-backtraces -d 'Enable or disable backtraces on panic' -r -f -a "true\t''
false\t''"
complete -c noseyparker -n "__fish_noseyparker_using_subcommand annotations; and __fish_seen_subcommand_from export" -s v -l verbose -d 'Enable verbose output'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand annotations; and __fish_seen_subcommand_from export" -s q -l quiet -d 'Suppress non-error feedback messages'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand annotations; and __fish_seen_subcommand_from export" -l ignore-certs -d 'Ignore validation of TLS certificates'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand annotations; and __fish_seen_subcommand_from export" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand annotations; and __fish_seen_subcommand_from import" -s d -l datastore -d 'Use the specified datastore' -r -f -a "(__fish_complete_directories)"
complete -c noseyparker -n "__fish_noseyparker_using_subcommand annotations; and __fish_seen_subcommand_from import" -s i -l input -d 'Read annotations from the specified path' -r -F
complete -c noseyparker -n "__fish_noseyparker_using_subcommand annotations; and __fish_seen_subcommand_from import" -l color -d 'Enable or disable colored output' -r -f -a "auto\t''
never\t''
always\t''"
complete -c noseyparker -n "__fish_noseyparker_using_subcommand annotations; and __fish_seen_subcommand_from import" -l progress -d 'Enable or disable progress bars' -r -f -a "auto\t''
never\t''
always\t''"
complete -c noseyparker -n "__fish_noseyparker_using_subcommand annotations; and __fish_seen_subcommand_from import" -l rlimit-nofile -d 'Set the rlimit for number of open files to LIMIT' -r
complete -c noseyparker -n "__fish_noseyparker_using_subcommand annotations; and __fish_seen_subcommand_from import" -l sqlite-cache-size -d 'Set the cache size for SQLite connections to SIZE' -r
complete -c noseyparker -n "__fish_noseyparker_using_subcommand annotations; and __fish_seen_subcommand_from import" -l enable-backtraces -d 'Enable or disable backtraces on panic' -r -f -a "true\t''
false\t''"
complete -c noseyparker -n "__fish_noseyparker_using_subcommand annotations; and __fish_seen_subcommand_from import" -s v -l verbose -d 'Enable verbose output'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand annotations; and __fish_seen_subcommand_from import" -s q -l quiet -d 'Suppress non-error feedback messages'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand annotations; and __fish_seen_subcommand_from import" -l ignore-certs -d 'Ignore validation of TLS certificates'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand annotations; and __fish_seen_subcommand_from import" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand annotations; and __fish_seen_subcommand_from help" -f -a "export" -d 'Export annotations from a datastore (experimental)'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand annotations; and __fish_seen_subcommand_from help" -f -a "import" -d 'Import annotations into a datastore (experimental)'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand annotations; and __fish_seen_subcommand_from help" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand generate; and not __fish_seen_subcommand_from manpages json-schema shell-completions help" -l color -d 'Enable or disable colored output' -r -f -a "auto\t''
never\t''
always\t''"
complete -c noseyparker -n "__fish_noseyparker_using_subcommand generate; and not __fish_seen_subcommand_from manpages json-schema shell-completions help" -l progress -d 'Enable or disable progress bars' -r -f -a "auto\t''
never\t''
always\t''"
complete -c noseyparker -n "__fish_noseyparker_using_subcommand generate; and not __fish_seen_subcommand_from manpages json-schema shell-completions help" -l rlimit-nofile -d 'Set the rlimit for number of open files to LIMIT' -r
complete -c noseyparker -n "__fish_noseyparker_using_subcommand generate; and not __fish_seen_subcommand_from manpages json-schema shell-completions help" -l sqlite-cache-size -d 'Set the cache size for SQLite connections to SIZE' -r
complete -c noseyparker -n "__fish_noseyparker_using_subcommand generate; and not __fish_seen_subcommand_from manpages json-schema shell-completions help" -l enable-backtraces -d 'Enable or disable backtraces on panic' -r -f -a "true\t''
false\t''"
complete -c noseyparker -n "__fish_noseyparker_using_subcommand generate; and not __fish_seen_subcommand_from manpages json-schema shell-completions help" -s v -l verbose -d 'Enable verbose output'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand generate; and not __fish_seen_subcommand_from manpages json-schema shell-completions help" -s q -l quiet -d 'Suppress non-error feedback messages'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand generate; and not __fish_seen_subcommand_from manpages json-schema shell-completions help" -l ignore-certs -d 'Ignore validation of TLS certificates'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand generate; and not __fish_seen_subcommand_from manpages json-schema shell-completions help" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand generate; and not __fish_seen_subcommand_from manpages json-schema shell-completions help" -f -a "manpages" -d 'Generate man pages'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand generate; and not __fish_seen_subcommand_from manpages json-schema shell-completions help" -f -a "json-schema" -d 'Generate the JSON schema for the output of the `report` command'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand generate; and not __fish_seen_subcommand_from manpages json-schema shell-completions help" -f -a "shell-completions" -d 'Generate shell completions'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand generate; and not __fish_seen_subcommand_from manpages json-schema shell-completions help" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand generate; and __fish_seen_subcommand_from manpages" -s o -l output -d 'Write output to the specified directory' -r -f -a "(__fish_complete_directories)"
complete -c noseyparker -n "__fish_noseyparker_using_subcommand generate; and __fish_seen_subcommand_from manpages" -l color -d 'Enable or disable colored output' -r -f -a "auto\t''
never\t''
always\t''"
complete -c noseyparker -n "__fish_noseyparker_using_subcommand generate; and __fish_seen_subcommand_from manpages" -l progress -d 'Enable or disable progress bars' -r -f -a "auto\t''
never\t''
always\t''"
complete -c noseyparker -n "__fish_noseyparker_using_subcommand generate; and __fish_seen_subcommand_from manpages" -l rlimit-nofile -d 'Set the rlimit for number of open files to LIMIT' -r
complete -c noseyparker -n "__fish_noseyparker_using_subcommand generate; and __fish_seen_subcommand_from manpages" -l sqlite-cache-size -d 'Set the cache size for SQLite connections to SIZE' -r
complete -c noseyparker -n "__fish_noseyparker_using_subcommand generate; and __fish_seen_subcommand_from manpages" -l enable-backtraces -d 'Enable or disable backtraces on panic' -r -f -a "true\t''
false\t''"
complete -c noseyparker -n "__fish_noseyparker_using_subcommand generate; and __fish_seen_subcommand_from manpages" -s v -l verbose -d 'Enable verbose output'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand generate; and __fish_seen_subcommand_from manpages" -s q -l quiet -d 'Suppress non-error feedback messages'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand generate; and __fish_seen_subcommand_from manpages" -l ignore-certs -d 'Ignore validation of TLS certificates'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand generate; and __fish_seen_subcommand_from manpages" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand generate; and __fish_seen_subcommand_from json-schema" -s o -l output -d 'Write output to the specified path' -r -F
complete -c noseyparker -n "__fish_noseyparker_using_subcommand generate; and __fish_seen_subcommand_from json-schema" -l color -d 'Enable or disable colored output' -r -f -a "auto\t''
never\t''
always\t''"
complete -c noseyparker -n "__fish_noseyparker_using_subcommand generate; and __fish_seen_subcommand_from json-schema" -l progress -d 'Enable or disable progress bars' -r -f -a "auto\t''
never\t''
always\t''"
complete -c noseyparker -n "__fish_noseyparker_using_subcommand generate; and __fish_seen_subcommand_from json-schema" -l rlimit-nofile -d 'Set the rlimit for number of open files to LIMIT' -r
complete -c noseyparker -n "__fish_noseyparker_using_subcommand generate; and __fish_seen_subcommand_from json-schema" -l sqlite-cache-size -d 'Set the cache size for SQLite connections to SIZE' -r
complete -c noseyparker -n "__fish_noseyparker_using_subcommand generate; and __fish_seen_subcommand_from json-schema" -l enable-backtraces -d 'Enable or disable backtraces on panic' -r -f -a "true\t''
false\t''"
complete -c noseyparker -n "__fish_noseyparker_using_subcommand generate; and __fish_seen_subcommand_from json-schema" -s v -l verbose -d 'Enable verbose output'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand generate; and __fish_seen_subcommand_from json-schema" -s q -l quiet -d 'Suppress non-error feedback messages'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand generate; and __fish_seen_subcommand_from json-schema" -l ignore-certs -d 'Ignore validation of TLS certificates'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand generate; and __fish_seen_subcommand_from json-schema" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand generate; and __fish_seen_subcommand_from shell-completions" -s s -l shell -r -f -a "bash\t''
zsh\t''
fish\t''
powershell\t''
elvish\t''"
complete -c noseyparker -n "__fish_noseyparker_using_subcommand generate; and __fish_seen_subcommand_from shell-completions" -l color -d 'Enable or disable colored output' -r -f -a "auto\t''
never\t''
always\t''"
complete -c noseyparker -n "__fish_noseyparker_using_subcommand generate; and __fish_seen_subcommand_from shell-completions" -l progress -d 'Enable or disable progress bars' -r -f -a "auto\t''
never\t''
always\t''"
complete -c noseyparker -n "__fish_noseyparker_using_subcommand generate; and __fish_seen_subcommand_from shell-completions" -l rlimit-nofile -d 'Set the rlimit for number of open files to LIMIT' -r
complete -c noseyparker -n "__fish_noseyparker_using_subcommand generate; and __fish_seen_subcommand_from shell-completions" -l sqlite-cache-size -d 'Set the cache size for SQLite connections to SIZE' -r
complete -c noseyparker -n "__fish_noseyparker_using_subcommand generate; and __fish_seen_subcommand_from shell-completions" -l enable-backtraces -d 'Enable or disable backtraces on panic' -r -f -a "true\t''
false\t''"
complete -c noseyparker -n "__fish_noseyparker_using_subcommand generate; and __fish_seen_subcommand_from shell-completions" -s v -l verbose -d 'Enable verbose output'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand generate; and __fish_seen_subcommand_from shell-completions" -s q -l quiet -d 'Suppress non-error feedback messages'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand generate; and __fish_seen_subcommand_from shell-completions" -l ignore-certs -d 'Ignore validation of TLS certificates'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand generate; and __fish_seen_subcommand_from shell-completions" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand generate; and __fish_seen_subcommand_from help" -f -a "manpages" -d 'Generate man pages'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand generate; and __fish_seen_subcommand_from help" -f -a "json-schema" -d 'Generate the JSON schema for the output of the `report` command'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand generate; and __fish_seen_subcommand_from help" -f -a "shell-completions" -d 'Generate shell completions'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand generate; and __fish_seen_subcommand_from help" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand help; and not __fish_seen_subcommand_from scan summarize report github datastore rules annotations generate help" -f -a "scan" -d 'Scan content for secrets'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand help; and not __fish_seen_subcommand_from scan summarize report github datastore rules annotations generate help" -f -a "summarize" -d 'Summarize scan findings'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand help; and not __fish_seen_subcommand_from scan summarize report github datastore rules annotations generate help" -f -a "report" -d 'Report detailed scan findings'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand help; and not __fish_seen_subcommand_from scan summarize report github datastore rules annotations generate help" -f -a "github" -d 'Interact with GitHub'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand help; and not __fish_seen_subcommand_from scan summarize report github datastore rules annotations generate help" -f -a "datastore" -d 'Manage datastores'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand help; and not __fish_seen_subcommand_from scan summarize report github datastore rules annotations generate help" -f -a "rules" -d 'Manage rules and rulesets'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand help; and not __fish_seen_subcommand_from scan summarize report github datastore rules annotations generate help" -f -a "annotations" -d 'Manage annotations (experimental)'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand help; and not __fish_seen_subcommand_from scan summarize report github datastore rules annotations generate help" -f -a "generate" -d 'Generate Nosey Parker release assets'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand help; and not __fish_seen_subcommand_from scan summarize report github datastore rules annotations generate help" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand help; and __fish_seen_subcommand_from github" -f -a "repos" -d 'Interact with GitHub repositories'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand help; and __fish_seen_subcommand_from datastore" -f -a "init" -d 'Initialize a new datastore'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand help; and __fish_seen_subcommand_from datastore" -f -a "export" -d 'Export a datastore'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand help; and __fish_seen_subcommand_from rules" -f -a "check" -d 'Check rules for problems'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand help; and __fish_seen_subcommand_from rules" -f -a "list" -d 'List available rules'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand help; and __fish_seen_subcommand_from annotations" -f -a "export" -d 'Export annotations from a datastore (experimental)'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand help; and __fish_seen_subcommand_from annotations" -f -a "import" -d 'Import annotations into a datastore (experimental)'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand help; and __fish_seen_subcommand_from generate" -f -a "manpages" -d 'Generate man pages'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand help; and __fish_seen_subcommand_from generate" -f -a "json-schema" -d 'Generate the JSON schema for the output of the `report` command'
complete -c noseyparker -n "__fish_noseyparker_using_subcommand help; and __fish_seen_subcommand_from generate" -f -a "shell-completions" -d 'Generate shell completions'
