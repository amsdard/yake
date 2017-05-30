#compdef yake

_yake() { 
    local curcontext="$curcontext" state line
    typeset -A opt_args

    YAKEFILE=$(echo "$curcontext" | perl -nle 'm/YAKEFILE=("[^"]+")+/; print $1' );
    YAKEFILE=${YAKEFILE:-$(echo "$curcontext" | perl -nle "m/YAKEFILE=('[^']+')+/; print \$1")};
    YAKEFILE=${YAKEFILE:-$(echo "$curcontext" | perl -nle 'm/YAKEFILE=([^\s]+)/; print $1')};
    YAKEFILE=${YAKEFILE:-Yakefile}

    tasks=""
    configs=""

    if test -f "$YAKEFILE"
        then
            tasks=$(yake YAKEFILE="$YAKEFILE" _tasks | awk '{print $1}')
            configs=$(yake YAKEFILE="$YAKEFILE" _config | awk '{print $1}')
        fi

    _arguments \
        '*: :->word'

    options=('-c:description for -c opt' '-d:description for -d opt')
arguments=('e:description for e arg' 'f:description for f arg')
_describe 'values' options -- arguments

}
 
_yake "$@"