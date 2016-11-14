#!/usr/bin/env bash

cmd=`yakeCore.pl BIN=$0 $@`

if [ $? != 0 ]; then
    echo "$cmd";
    exit $?
fi

eval "$cmd";