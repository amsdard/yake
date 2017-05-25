#!/usr/bin/env bash

cmd=`$(dirname "$0")/yakeCore.pl BIN=$0 $@`
returnCode=$?

if [ $returnCode != 0 ]; then
    echo "$cmd";
    exit $returnCode
fi

eval "$cmd";