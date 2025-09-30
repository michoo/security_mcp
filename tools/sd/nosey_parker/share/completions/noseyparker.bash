_noseyparker() {
    local i cur prev opts cmd
    COMPREPLY=()
    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
        cur="$2"
    else
        cur="${COMP_WORDS[COMP_CWORD]}"
    fi
    prev="$3"
    cmd=""
    opts=""

    for i in "${COMP_WORDS[@]:0:COMP_CWORD}"
    do
        case "${cmd},${i}" in
            ",$1")
                cmd="noseyparker"
                ;;
            noseyparker,annotations)
                cmd="noseyparker__annotations"
                ;;
            noseyparker,datastore)
                cmd="noseyparker__datastore"
                ;;
            noseyparker,generate)
                cmd="noseyparker__generate"
                ;;
            noseyparker,github)
                cmd="noseyparker__github"
                ;;
            noseyparker,help)
                cmd="noseyparker__help"
                ;;
            noseyparker,report)
                cmd="noseyparker__report"
                ;;
            noseyparker,rules)
                cmd="noseyparker__rules"
                ;;
            noseyparker,scan)
                cmd="noseyparker__scan"
                ;;
            noseyparker,summarize)
                cmd="noseyparker__summarize"
                ;;
            noseyparker__annotations,export)
                cmd="noseyparker__annotations__export"
                ;;
            noseyparker__annotations,help)
                cmd="noseyparker__annotations__help"
                ;;
            noseyparker__annotations,import)
                cmd="noseyparker__annotations__import"
                ;;
            noseyparker__annotations__help,export)
                cmd="noseyparker__annotations__help__export"
                ;;
            noseyparker__annotations__help,help)
                cmd="noseyparker__annotations__help__help"
                ;;
            noseyparker__annotations__help,import)
                cmd="noseyparker__annotations__help__import"
                ;;
            noseyparker__datastore,export)
                cmd="noseyparker__datastore__export"
                ;;
            noseyparker__datastore,help)
                cmd="noseyparker__datastore__help"
                ;;
            noseyparker__datastore,init)
                cmd="noseyparker__datastore__init"
                ;;
            noseyparker__datastore__help,export)
                cmd="noseyparker__datastore__help__export"
                ;;
            noseyparker__datastore__help,help)
                cmd="noseyparker__datastore__help__help"
                ;;
            noseyparker__datastore__help,init)
                cmd="noseyparker__datastore__help__init"
                ;;
            noseyparker__generate,help)
                cmd="noseyparker__generate__help"
                ;;
            noseyparker__generate,json-schema)
                cmd="noseyparker__generate__json__schema"
                ;;
            noseyparker__generate,manpages)
                cmd="noseyparker__generate__manpages"
                ;;
            noseyparker__generate,shell-completions)
                cmd="noseyparker__generate__shell__completions"
                ;;
            noseyparker__generate__help,help)
                cmd="noseyparker__generate__help__help"
                ;;
            noseyparker__generate__help,json-schema)
                cmd="noseyparker__generate__help__json__schema"
                ;;
            noseyparker__generate__help,manpages)
                cmd="noseyparker__generate__help__manpages"
                ;;
            noseyparker__generate__help,shell-completions)
                cmd="noseyparker__generate__help__shell__completions"
                ;;
            noseyparker__github,help)
                cmd="noseyparker__github__help"
                ;;
            noseyparker__github,repos)
                cmd="noseyparker__github__repos"
                ;;
            noseyparker__github__help,help)
                cmd="noseyparker__github__help__help"
                ;;
            noseyparker__github__help,repos)
                cmd="noseyparker__github__help__repos"
                ;;
            noseyparker__github__help__repos,list)
                cmd="noseyparker__github__help__repos__list"
                ;;
            noseyparker__github__repos,help)
                cmd="noseyparker__github__repos__help"
                ;;
            noseyparker__github__repos,list)
                cmd="noseyparker__github__repos__list"
                ;;
            noseyparker__github__repos__help,help)
                cmd="noseyparker__github__repos__help__help"
                ;;
            noseyparker__github__repos__help,list)
                cmd="noseyparker__github__repos__help__list"
                ;;
            noseyparker__help,annotations)
                cmd="noseyparker__help__annotations"
                ;;
            noseyparker__help,datastore)
                cmd="noseyparker__help__datastore"
                ;;
            noseyparker__help,generate)
                cmd="noseyparker__help__generate"
                ;;
            noseyparker__help,github)
                cmd="noseyparker__help__github"
                ;;
            noseyparker__help,help)
                cmd="noseyparker__help__help"
                ;;
            noseyparker__help,report)
                cmd="noseyparker__help__report"
                ;;
            noseyparker__help,rules)
                cmd="noseyparker__help__rules"
                ;;
            noseyparker__help,scan)
                cmd="noseyparker__help__scan"
                ;;
            noseyparker__help,summarize)
                cmd="noseyparker__help__summarize"
                ;;
            noseyparker__help__annotations,export)
                cmd="noseyparker__help__annotations__export"
                ;;
            noseyparker__help__annotations,import)
                cmd="noseyparker__help__annotations__import"
                ;;
            noseyparker__help__datastore,export)
                cmd="noseyparker__help__datastore__export"
                ;;
            noseyparker__help__datastore,init)
                cmd="noseyparker__help__datastore__init"
                ;;
            noseyparker__help__generate,json-schema)
                cmd="noseyparker__help__generate__json__schema"
                ;;
            noseyparker__help__generate,manpages)
                cmd="noseyparker__help__generate__manpages"
                ;;
            noseyparker__help__generate,shell-completions)
                cmd="noseyparker__help__generate__shell__completions"
                ;;
            noseyparker__help__github,repos)
                cmd="noseyparker__help__github__repos"
                ;;
            noseyparker__help__github__repos,list)
                cmd="noseyparker__help__github__repos__list"
                ;;
            noseyparker__help__rules,check)
                cmd="noseyparker__help__rules__check"
                ;;
            noseyparker__help__rules,list)
                cmd="noseyparker__help__rules__list"
                ;;
            noseyparker__rules,check)
                cmd="noseyparker__rules__check"
                ;;
            noseyparker__rules,help)
                cmd="noseyparker__rules__help"
                ;;
            noseyparker__rules,list)
                cmd="noseyparker__rules__list"
                ;;
            noseyparker__rules__help,check)
                cmd="noseyparker__rules__help__check"
                ;;
            noseyparker__rules__help,help)
                cmd="noseyparker__rules__help__help"
                ;;
            noseyparker__rules__help,list)
                cmd="noseyparker__rules__help__list"
                ;;
            *)
                ;;
        esac
    done

    case "${cmd}" in
        noseyparker)
            opts="-v -q -h -V --verbose --quiet --color --progress --ignore-certs --rlimit-nofile --sqlite-cache-size --enable-backtraces --help --version scan summarize report github datastore rules annotations generate help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 1 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --color)
                    COMPREPLY=($(compgen -W "auto never always" -- "${cur}"))
                    return 0
                    ;;
                --progress)
                    COMPREPLY=($(compgen -W "auto never always" -- "${cur}"))
                    return 0
                    ;;
                --rlimit-nofile)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --sqlite-cache-size)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --enable-backtraces)
                    COMPREPLY=($(compgen -W "true false" -- "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        noseyparker__annotations)
            opts="-v -q -h --verbose --quiet --color --progress --ignore-certs --rlimit-nofile --sqlite-cache-size --enable-backtraces --help export import help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --color)
                    COMPREPLY=($(compgen -W "auto never always" -- "${cur}"))
                    return 0
                    ;;
                --progress)
                    COMPREPLY=($(compgen -W "auto never always" -- "${cur}"))
                    return 0
                    ;;
                --rlimit-nofile)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --sqlite-cache-size)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --enable-backtraces)
                    COMPREPLY=($(compgen -W "true false" -- "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        noseyparker__annotations__export)
            opts="-d -o -v -q -h --datastore --output --verbose --quiet --color --progress --ignore-certs --rlimit-nofile --sqlite-cache-size --enable-backtraces --help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --datastore)
                    COMPREPLY=()
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o plusdirs
                    fi
                    return 0
                    ;;
                -d)
                    COMPREPLY=()
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o plusdirs
                    fi
                    return 0
                    ;;
                --output)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                -o)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                --color)
                    COMPREPLY=($(compgen -W "auto never always" -- "${cur}"))
                    return 0
                    ;;
                --progress)
                    COMPREPLY=($(compgen -W "auto never always" -- "${cur}"))
                    return 0
                    ;;
                --rlimit-nofile)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --sqlite-cache-size)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --enable-backtraces)
                    COMPREPLY=($(compgen -W "true false" -- "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        noseyparker__annotations__help)
            opts="export import help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        noseyparker__annotations__help__export)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        noseyparker__annotations__help__help)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        noseyparker__annotations__help__import)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        noseyparker__annotations__import)
            opts="-d -i -v -q -h --datastore --input --verbose --quiet --color --progress --ignore-certs --rlimit-nofile --sqlite-cache-size --enable-backtraces --help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --datastore)
                    COMPREPLY=()
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o plusdirs
                    fi
                    return 0
                    ;;
                -d)
                    COMPREPLY=()
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o plusdirs
                    fi
                    return 0
                    ;;
                --input)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                -i)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                --color)
                    COMPREPLY=($(compgen -W "auto never always" -- "${cur}"))
                    return 0
                    ;;
                --progress)
                    COMPREPLY=($(compgen -W "auto never always" -- "${cur}"))
                    return 0
                    ;;
                --rlimit-nofile)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --sqlite-cache-size)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --enable-backtraces)
                    COMPREPLY=($(compgen -W "true false" -- "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        noseyparker__datastore)
            opts="-v -q -h --verbose --quiet --color --progress --ignore-certs --rlimit-nofile --sqlite-cache-size --enable-backtraces --help init export help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --color)
                    COMPREPLY=($(compgen -W "auto never always" -- "${cur}"))
                    return 0
                    ;;
                --progress)
                    COMPREPLY=($(compgen -W "auto never always" -- "${cur}"))
                    return 0
                    ;;
                --rlimit-nofile)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --sqlite-cache-size)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --enable-backtraces)
                    COMPREPLY=($(compgen -W "true false" -- "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        noseyparker__datastore__export)
            opts="-d -o -f -v -q -h --datastore --output --format --verbose --quiet --color --progress --ignore-certs --rlimit-nofile --sqlite-cache-size --enable-backtraces --help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --datastore)
                    COMPREPLY=()
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o plusdirs
                    fi
                    return 0
                    ;;
                -d)
                    COMPREPLY=()
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o plusdirs
                    fi
                    return 0
                    ;;
                --output)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                -o)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                --format)
                    COMPREPLY=($(compgen -W "tgz" -- "${cur}"))
                    return 0
                    ;;
                -f)
                    COMPREPLY=($(compgen -W "tgz" -- "${cur}"))
                    return 0
                    ;;
                --color)
                    COMPREPLY=($(compgen -W "auto never always" -- "${cur}"))
                    return 0
                    ;;
                --progress)
                    COMPREPLY=($(compgen -W "auto never always" -- "${cur}"))
                    return 0
                    ;;
                --rlimit-nofile)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --sqlite-cache-size)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --enable-backtraces)
                    COMPREPLY=($(compgen -W "true false" -- "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        noseyparker__datastore__help)
            opts="init export help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        noseyparker__datastore__help__export)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        noseyparker__datastore__help__help)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        noseyparker__datastore__help__init)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        noseyparker__datastore__init)
            opts="-d -v -q -h --datastore --verbose --quiet --color --progress --ignore-certs --rlimit-nofile --sqlite-cache-size --enable-backtraces --help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --datastore)
                    COMPREPLY=()
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o plusdirs
                    fi
                    return 0
                    ;;
                -d)
                    COMPREPLY=()
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o plusdirs
                    fi
                    return 0
                    ;;
                --color)
                    COMPREPLY=($(compgen -W "auto never always" -- "${cur}"))
                    return 0
                    ;;
                --progress)
                    COMPREPLY=($(compgen -W "auto never always" -- "${cur}"))
                    return 0
                    ;;
                --rlimit-nofile)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --sqlite-cache-size)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --enable-backtraces)
                    COMPREPLY=($(compgen -W "true false" -- "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        noseyparker__generate)
            opts="-v -q -h --verbose --quiet --color --progress --ignore-certs --rlimit-nofile --sqlite-cache-size --enable-backtraces --help manpages json-schema shell-completions help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --color)
                    COMPREPLY=($(compgen -W "auto never always" -- "${cur}"))
                    return 0
                    ;;
                --progress)
                    COMPREPLY=($(compgen -W "auto never always" -- "${cur}"))
                    return 0
                    ;;
                --rlimit-nofile)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --sqlite-cache-size)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --enable-backtraces)
                    COMPREPLY=($(compgen -W "true false" -- "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        noseyparker__generate__help)
            opts="manpages json-schema shell-completions help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        noseyparker__generate__help__help)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        noseyparker__generate__help__json__schema)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        noseyparker__generate__help__manpages)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        noseyparker__generate__help__shell__completions)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        noseyparker__generate__json__schema)
            opts="-o -v -q -h --output --verbose --quiet --color --progress --ignore-certs --rlimit-nofile --sqlite-cache-size --enable-backtraces --help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --output)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                -o)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                --color)
                    COMPREPLY=($(compgen -W "auto never always" -- "${cur}"))
                    return 0
                    ;;
                --progress)
                    COMPREPLY=($(compgen -W "auto never always" -- "${cur}"))
                    return 0
                    ;;
                --rlimit-nofile)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --sqlite-cache-size)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --enable-backtraces)
                    COMPREPLY=($(compgen -W "true false" -- "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        noseyparker__generate__manpages)
            opts="-o -v -q -h --output --verbose --quiet --color --progress --ignore-certs --rlimit-nofile --sqlite-cache-size --enable-backtraces --help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --output)
                    COMPREPLY=()
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o plusdirs
                    fi
                    return 0
                    ;;
                -o)
                    COMPREPLY=()
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o plusdirs
                    fi
                    return 0
                    ;;
                --color)
                    COMPREPLY=($(compgen -W "auto never always" -- "${cur}"))
                    return 0
                    ;;
                --progress)
                    COMPREPLY=($(compgen -W "auto never always" -- "${cur}"))
                    return 0
                    ;;
                --rlimit-nofile)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --sqlite-cache-size)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --enable-backtraces)
                    COMPREPLY=($(compgen -W "true false" -- "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        noseyparker__generate__shell__completions)
            opts="-s -v -q -h --shell --verbose --quiet --color --progress --ignore-certs --rlimit-nofile --sqlite-cache-size --enable-backtraces --help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --shell)
                    COMPREPLY=($(compgen -W "bash zsh fish powershell elvish" -- "${cur}"))
                    return 0
                    ;;
                -s)
                    COMPREPLY=($(compgen -W "bash zsh fish powershell elvish" -- "${cur}"))
                    return 0
                    ;;
                --color)
                    COMPREPLY=($(compgen -W "auto never always" -- "${cur}"))
                    return 0
                    ;;
                --progress)
                    COMPREPLY=($(compgen -W "auto never always" -- "${cur}"))
                    return 0
                    ;;
                --rlimit-nofile)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --sqlite-cache-size)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --enable-backtraces)
                    COMPREPLY=($(compgen -W "true false" -- "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        noseyparker__github)
            opts="-v -q -h --api-url --github-api-url --verbose --quiet --color --progress --ignore-certs --rlimit-nofile --sqlite-cache-size --enable-backtraces --help repos help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --github-api-url)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --api-url)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --color)
                    COMPREPLY=($(compgen -W "auto never always" -- "${cur}"))
                    return 0
                    ;;
                --progress)
                    COMPREPLY=($(compgen -W "auto never always" -- "${cur}"))
                    return 0
                    ;;
                --rlimit-nofile)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --sqlite-cache-size)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --enable-backtraces)
                    COMPREPLY=($(compgen -W "true false" -- "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        noseyparker__github__help)
            opts="repos help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        noseyparker__github__help__help)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        noseyparker__github__help__repos)
            opts="list"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        noseyparker__github__help__repos__list)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 5 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        noseyparker__github__repos)
            opts="-v -q -h --api-url --github-api-url --verbose --quiet --color --progress --ignore-certs --rlimit-nofile --sqlite-cache-size --enable-backtraces --help list help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --github-api-url)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --api-url)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --color)
                    COMPREPLY=($(compgen -W "auto never always" -- "${cur}"))
                    return 0
                    ;;
                --progress)
                    COMPREPLY=($(compgen -W "auto never always" -- "${cur}"))
                    return 0
                    ;;
                --rlimit-nofile)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --sqlite-cache-size)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --enable-backtraces)
                    COMPREPLY=($(compgen -W "true false" -- "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        noseyparker__github__repos__help)
            opts="list help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        noseyparker__github__repos__help__help)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 5 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        noseyparker__github__repos__help__list)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 5 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        noseyparker__github__repos__list)
            opts="-o -f -v -q -h --github-user --user --org --github-organization --github-org --organization --all-orgs --all-github-organizations --all-github-orgs --all-organizations --github-repo-type --repo-type --output --format --api-url --github-api-url --verbose --quiet --color --progress --ignore-certs --rlimit-nofile --sqlite-cache-size --enable-backtraces --help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --user)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --github-user)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --organization)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --org)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --github-organization)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --github-org)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --repo-type)
                    COMPREPLY=($(compgen -W "all source fork" -- "${cur}"))
                    return 0
                    ;;
                --github-repo-type)
                    COMPREPLY=($(compgen -W "all source fork" -- "${cur}"))
                    return 0
                    ;;
                --output)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                -o)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                --format)
                    COMPREPLY=($(compgen -W "human json jsonl" -- "${cur}"))
                    return 0
                    ;;
                -f)
                    COMPREPLY=($(compgen -W "human json jsonl" -- "${cur}"))
                    return 0
                    ;;
                --github-api-url)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --api-url)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --color)
                    COMPREPLY=($(compgen -W "auto never always" -- "${cur}"))
                    return 0
                    ;;
                --progress)
                    COMPREPLY=($(compgen -W "auto never always" -- "${cur}"))
                    return 0
                    ;;
                --rlimit-nofile)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --sqlite-cache-size)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --enable-backtraces)
                    COMPREPLY=($(compgen -W "true false" -- "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        noseyparker__help)
            opts="scan summarize report github datastore rules annotations generate help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        noseyparker__help__annotations)
            opts="export import"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        noseyparker__help__annotations__export)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        noseyparker__help__annotations__import)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        noseyparker__help__datastore)
            opts="init export"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        noseyparker__help__datastore__export)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        noseyparker__help__datastore__init)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        noseyparker__help__generate)
            opts="manpages json-schema shell-completions"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        noseyparker__help__generate__json__schema)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        noseyparker__help__generate__manpages)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        noseyparker__help__generate__shell__completions)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        noseyparker__help__github)
            opts="repos"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        noseyparker__help__github__repos)
            opts="list"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        noseyparker__help__github__repos__list)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 5 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        noseyparker__help__help)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        noseyparker__help__report)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        noseyparker__help__rules)
            opts="check list"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        noseyparker__help__rules__check)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        noseyparker__help__rules__list)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        noseyparker__help__scan)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        noseyparker__help__summarize)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        noseyparker__report)
            opts="-d -o -f -v -q -h --datastore --max-matches --max-provenance --min-score --finding-status --suppress-redundant --output --format --verbose --quiet --color --progress --ignore-certs --rlimit-nofile --sqlite-cache-size --enable-backtraces --help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --datastore)
                    COMPREPLY=()
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o plusdirs
                    fi
                    return 0
                    ;;
                -d)
                    COMPREPLY=()
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o plusdirs
                    fi
                    return 0
                    ;;
                --max-matches)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --max-provenance)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --min-score)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --finding-status)
                    COMPREPLY=($(compgen -W "accept reject mixed null" -- "${cur}"))
                    return 0
                    ;;
                --suppress-redundant)
                    COMPREPLY=($(compgen -W "true false" -- "${cur}"))
                    return 0
                    ;;
                --output)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                -o)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                --format)
                    COMPREPLY=($(compgen -W "human json jsonl sarif" -- "${cur}"))
                    return 0
                    ;;
                -f)
                    COMPREPLY=($(compgen -W "human json jsonl sarif" -- "${cur}"))
                    return 0
                    ;;
                --color)
                    COMPREPLY=($(compgen -W "auto never always" -- "${cur}"))
                    return 0
                    ;;
                --progress)
                    COMPREPLY=($(compgen -W "auto never always" -- "${cur}"))
                    return 0
                    ;;
                --rlimit-nofile)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --sqlite-cache-size)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --enable-backtraces)
                    COMPREPLY=($(compgen -W "true false" -- "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        noseyparker__rules)
            opts="-v -q -h --verbose --quiet --color --progress --ignore-certs --rlimit-nofile --sqlite-cache-size --enable-backtraces --help check list help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --color)
                    COMPREPLY=($(compgen -W "auto never always" -- "${cur}"))
                    return 0
                    ;;
                --progress)
                    COMPREPLY=($(compgen -W "auto never always" -- "${cur}"))
                    return 0
                    ;;
                --rlimit-nofile)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --sqlite-cache-size)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --enable-backtraces)
                    COMPREPLY=($(compgen -W "true false" -- "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        noseyparker__rules__check)
            opts="-W -v -q -h --warnings-as-errors --pedantic --rules-path --ruleset --load-builtins --verbose --quiet --color --progress --ignore-certs --rlimit-nofile --sqlite-cache-size --enable-backtraces --help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --rules-path)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --ruleset)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --load-builtins)
                    COMPREPLY=($(compgen -W "true false" -- "${cur}"))
                    return 0
                    ;;
                --color)
                    COMPREPLY=($(compgen -W "auto never always" -- "${cur}"))
                    return 0
                    ;;
                --progress)
                    COMPREPLY=($(compgen -W "auto never always" -- "${cur}"))
                    return 0
                    ;;
                --rlimit-nofile)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --sqlite-cache-size)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --enable-backtraces)
                    COMPREPLY=($(compgen -W "true false" -- "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        noseyparker__rules__help)
            opts="check list help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        noseyparker__rules__help__check)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        noseyparker__rules__help__help)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        noseyparker__rules__help__list)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        noseyparker__rules__list)
            opts="-o -f -v -q -h --rules-path --ruleset --load-builtins --output --format --verbose --quiet --color --progress --ignore-certs --rlimit-nofile --sqlite-cache-size --enable-backtraces --help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --rules-path)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --ruleset)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --load-builtins)
                    COMPREPLY=($(compgen -W "true false" -- "${cur}"))
                    return 0
                    ;;
                --output)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                -o)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                --format)
                    COMPREPLY=($(compgen -W "human json" -- "${cur}"))
                    return 0
                    ;;
                -f)
                    COMPREPLY=($(compgen -W "human json" -- "${cur}"))
                    return 0
                    ;;
                --color)
                    COMPREPLY=($(compgen -W "auto never always" -- "${cur}"))
                    return 0
                    ;;
                --progress)
                    COMPREPLY=($(compgen -W "auto never always" -- "${cur}"))
                    return 0
                    ;;
                --rlimit-nofile)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --sqlite-cache-size)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --enable-backtraces)
                    COMPREPLY=($(compgen -W "true false" -- "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        noseyparker__scan)
            opts="-d -j -i -v -q -h --datastore --jobs --rules-path --ruleset --load-builtins --git-url --enumerator --github-user --github-org --github-organization --all-github-orgs --all-github-organizations --api-url --github-api-url --github-repo-type --git-clone --git-history --max-file-size --ignore --blob-metadata --git-blob-provenance --snippet-length --copy-blobs --copy-blobs-format --verbose --quiet --color --progress --ignore-certs --rlimit-nofile --sqlite-cache-size --enable-backtraces --help [INPUT]..."
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --datastore)
                    COMPREPLY=()
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o plusdirs
                    fi
                    return 0
                    ;;
                -d)
                    COMPREPLY=()
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o plusdirs
                    fi
                    return 0
                    ;;
                --jobs)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -j)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --rules-path)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --ruleset)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --load-builtins)
                    COMPREPLY=($(compgen -W "true false" -- "${cur}"))
                    return 0
                    ;;
                --git-url)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --enumerator)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                --github-user)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --github-organization)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --github-org)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --github-api-url)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --api-url)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --github-repo-type)
                    COMPREPLY=($(compgen -W "all source fork" -- "${cur}"))
                    return 0
                    ;;
                --git-clone)
                    COMPREPLY=($(compgen -W "bare mirror" -- "${cur}"))
                    return 0
                    ;;
                --git-history)
                    COMPREPLY=($(compgen -W "full none" -- "${cur}"))
                    return 0
                    ;;
                --max-file-size)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --ignore)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                -i)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                --blob-metadata)
                    COMPREPLY=($(compgen -W "all matching none" -- "${cur}"))
                    return 0
                    ;;
                --git-blob-provenance)
                    COMPREPLY=($(compgen -W "first-seen minimal" -- "${cur}"))
                    return 0
                    ;;
                --snippet-length)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --copy-blobs)
                    COMPREPLY=($(compgen -W "all matching none" -- "${cur}"))
                    return 0
                    ;;
                --copy-blobs-format)
                    COMPREPLY=($(compgen -W "parquet files" -- "${cur}"))
                    return 0
                    ;;
                --color)
                    COMPREPLY=($(compgen -W "auto never always" -- "${cur}"))
                    return 0
                    ;;
                --progress)
                    COMPREPLY=($(compgen -W "auto never always" -- "${cur}"))
                    return 0
                    ;;
                --rlimit-nofile)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --sqlite-cache-size)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --enable-backtraces)
                    COMPREPLY=($(compgen -W "true false" -- "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        noseyparker__summarize)
            opts="-d -o -f -v -q -h --datastore --output --format --verbose --quiet --color --progress --ignore-certs --rlimit-nofile --sqlite-cache-size --enable-backtraces --help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --datastore)
                    COMPREPLY=()
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o plusdirs
                    fi
                    return 0
                    ;;
                -d)
                    COMPREPLY=()
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o plusdirs
                    fi
                    return 0
                    ;;
                --output)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                -o)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                --format)
                    COMPREPLY=($(compgen -W "human json jsonl" -- "${cur}"))
                    return 0
                    ;;
                -f)
                    COMPREPLY=($(compgen -W "human json jsonl" -- "${cur}"))
                    return 0
                    ;;
                --color)
                    COMPREPLY=($(compgen -W "auto never always" -- "${cur}"))
                    return 0
                    ;;
                --progress)
                    COMPREPLY=($(compgen -W "auto never always" -- "${cur}"))
                    return 0
                    ;;
                --rlimit-nofile)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --sqlite-cache-size)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --enable-backtraces)
                    COMPREPLY=($(compgen -W "true false" -- "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
    esac
}

if [[ "${BASH_VERSINFO[0]}" -eq 4 && "${BASH_VERSINFO[1]}" -ge 4 || "${BASH_VERSINFO[0]}" -gt 4 ]]; then
    complete -F _noseyparker -o nosort -o bashdefault -o default noseyparker
else
    complete -F _noseyparker -o bashdefault -o default noseyparker
fi
