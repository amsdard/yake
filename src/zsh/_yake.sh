#compdef yake

_yake() {
    local state
    typeset -A opt_args

    YAKEFILE=$(echo "$state" | perl -nle 'm/YAKEFILE=("[^"]+")+/; print $1' );
    YAKEFILE=${YAKEFILE:-$(echo "$state" | perl -nle "m/YAKEFILE=('[^']+')+/; print \$1")};
    YAKEFILE=${YAKEFILE:-$(echo "$state" | perl -nle 'm/YAKEFILE=([^\s]+)/; print $1')};
    YAKEFILE=${YAKEFILE:-Yakefile}

    words=()
  
    if test -f "$YAKEFILE"
        then
            while read -r varName; do
                words+=("$varName")
            done <<< $(yake YAKEFILE="$YAKEFILE" _config | awk '{print $1}')

            words+=(
                '_config:show internal variables'
                '_tasks:show defined tasks with filled variables'
            )

            while read -r line; do
                line=$(echo "$line" | tr -s ' ' );
                taskName=$(echo "$line" | cut -d ' ' -f 1 | sed 's/^[\s+]*//;s/[\s+]*$//');
                taskDescription=$(echo "$line" | cut -d ' ' -f 2- | sed 's/^[\s+]*//;s/[\s+]*$//');

                words+=("$taskName:$taskDescription")
            done <<< "`yake YAKEFILE="$YAKEFILE" _tasks`"

        fi

    local -a options arguments
    options=(
        '--version:see Yake version and check updates'
        '--help:show docs'
        '--upgrade:execute Yake upgrade to latest version'
        '--debug:do not execute task, show script params and full command as text (able to use with <task> only)'
    )

    _describe 'values' options -- words

}
 
_yake "$@"