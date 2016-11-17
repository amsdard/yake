#!/usr/bin/env bash

repoRawUrl="https://yake.amsdard.io"

# CHECK REQUIREMENTS
requirements=( "perl" "cpan" "curl" )
for program in "${requirements[@]}"
do
    hash $program 2>/dev/null || { echo >&2 "I require \"$program\" but it's not installed.  Aborting."; exit 1; }
done

# CPAN DEPENDENCIES
if [[ ! -z "$(perl -MYAML::XS -e 1 2>&1)" ]]; then
    echo "installing cpan module YAML::XS...";
    export PERL_MM_USE_DEFAULT=1
    cpan install YAML::XS >/dev/null 2>&1
fi

# INSTALL BINARIES
installDir="/usr/local/bin"
if [[ ! -d $installDir ]]; then
    echo "Cant find \"$installDir\" directory";
    exit 1;
fi

curl -fsSL "$repoRawUrl/yakeCore.pl" -o "$installDir/yakeCore.pl"
curl -fsSL "$repoRawUrl/yake.sh" -o "$installDir/yake"
chmod +x "$installDir/yakeCore.pl" "$installDir/yake"

# INSTALL AUTO-COMPLETION
bashCompletionDir="/etc/bash_completion.d"
if [[ -d $bashCompletionDir ]]; then
    curl -fsSL "$repoRawUrl/yake_completion.sh" -o "$bashCompletionDir/yake_completion.sh"
    chmod +x "$bashCompletionDir/yake_completion.sh"
fi

# EXIT IF FAILS
if [ $? != 0 ]; then
    exit $?
fi

# INSTALLATION FINISHED SUCCESSFULLY
echo "\"yake\" installed!";
echo "Create \"Yakefile\" in Your directory and run \"yake YOUR_COMMAND\"";
echo "Docs: http://yake.amsdard.io"