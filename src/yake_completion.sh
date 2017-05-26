#!/usr/bin/env bash

_yake() {
  YAKEFILE=$(echo "$COMP_LINE" | perl -nle 'm/YAKEFILE=["]?(.*)[ "]+/; print $1')
  YAKEFILE=${YAKEFILE:-Yakefile}

  tasks=""
  configs=""

  if test -f "$YAKEFILE"
      then
        tasks=$(yake YAKEFILE="$YAKEFILE" _tasks | awk '{print $1}')
        configs=$(yake YAKEFILE="$YAKEFILE" _config | awk '{print $1}')
      fi

  COMPREPLY=($(compgen -W "--version --help --update --debug _config _tasks ${configs} ${tasks}" -- ${COMP_WORDS[COMP_CWORD]}))
  return 0
}

complete -o filenames -F _yake yake