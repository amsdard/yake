#!/usr/bin/env bash

_yake() {
  YAKEFILE=$(echo $COMP_LINE | awk 'match($0, / YAKEFILE[ =]([^ ]+)/, awkrules) {print awkrules[1]}')
  YAKEFILE=${YAKEFILE:-Yakefile}
  local opts
  case "${COMP_WORDS[COMP_CWORD-1]}" in
    -file)
       local IFS=$'\n'
       COMPREPLY=( $( compgen -o plusdirs  -f  -- ${COMP_WORDS[COMP_CWORD]} ) )
       return 0
      ;;
    *)
      opts=""
      if test -f "$YAKEFILE"
      then
        opts=$(awk -F: '/^\S/ {print $1}' "$YAKEFILE")
      fi
      ;;
  esac
  COMPREPLY=($(compgen -W "${opts}" -- ${COMP_WORDS[COMP_CWORD]}))
  return 0
}

complete -o filenames -F _yake yake