#!/usr/bin/env bash

cmd=`yakeCore.pl BIN=$0 $@`

if [ $? != 0 ]; then
    echo "$cmd";
    exit $ERROR_CODE
fi

eval "$cmd";