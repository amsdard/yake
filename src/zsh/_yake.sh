#compdef yake

_yake() {
    cmd="${words[@]}"
    typeset -A opt_args

    YAKEFILE=$(echo "$cmd" | perl -nle 'm/YAKEFILE=("[^"]+")+/; print $1' );
    YAKEFILE=${YAKEFILE:-$(echo "$cmd" | perl -nle "m/YAKEFILE=('[^']+')+/; print \$1")};
    YAKEFILE=${YAKEFILE:-$(echo "$cmd" | perl -nle 'm/YAKEFILE=([^\s]+)/; print $1')};
    YAKEFILE=${YAKEFILE:-Yakefile}

    argumentWords=()
    isVarUsed=0
    isTaskUsed=0

    if test -f "$YAKEFILE"
        then
            while read -r varName; do
                if [[ ! " $cmd " =~ " ${varName} " ]]; then
                    argumentWords+=("$varName")
                else
                    isVarUsed=1
                fi
            done <<< $(yake YAKEFILE="$YAKEFILE" _config | awk '{print $1}')

            if [[ ! " $cmd " =~ " _config " ]]; then
                argumentWords+=('_config:show internal variables')
            else
                isTaskUsed=1
            fi

            if [[ ! " $cmd " =~ " _tasks " ]]; then
                argumentWords+=('_tasks:show defined tasks with filled variables')
            else
                isTaskUsed=1
            fi

            while read -r line; do
                line=$(echo "$line" | tr -s ' ' );
                taskName=$(echo "$line" | cut -d ' ' -f 1 );
                taskDescription=$(echo "$line" | cut -d ' ' -f 2- );

                if [[ ! " $cmd " =~ " ${taskName} " ]]; then
                    argumentWords+=("$taskName:$taskDescription")
                else
                    isTaskUsed=1
                fi
            done <<< "`yake YAKEFILE="$YAKEFILE" _tasks`"

        fi

    local -a options

    if [[ ! " $cmd " =~ " --version " && ! " $cmd " =~ " --help " && ! " $cmd " =~ " --upgrade " && ! " $cmd " =~ " --debug " ]]; then
        options=(
            '--version:see Yake version and check updates'
            '--help:show docs'
            '--upgrade:execute Yake upgrade to latest version'
            '--debug:do not execute task, show script params and full command as text (able to use with <task> only)'
        )
    fi

    if [[ $isTaskUsed == 0 ]]; then
        _describe 'values' options -- argumentWords
    fi

}
 
_yake "$@"