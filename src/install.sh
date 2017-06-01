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

if [[ ! -z "$(perl -MYAML::XS -e 1 2>&1)" ]]; then
    echo "Perl module YAML::XS is not installed! Install it on Your own and run yake install again.";
    echo "\$ cpanm YAML::XS # cpan install YAML::XS";
    exit 1;
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
    curl -fsSL "$repoRawUrl/bash/yake_completion.sh" -o "$bashCompletionDir/yake_completion.sh"
    chmod +x "$bashCompletionDir/yake_completion.sh"
fi

if [[ $ZSH && -d $ZSH ]]; then
    zshCompletionDir="$ZSH/completions"
    zshUser=$(ls -ld "$ZSH" | awk '{print $3}')
    if [[ ! -d $zshCompletionDir ]]; then
        mkdir $zshCompletionDir;
        chown $zshUser $zshCompletionDir;
    fi

    curl -fsSL "$repoRawUrl/zsh/_yake.sh" -o "$zshCompletionDir/_yake"
    chmod +x "$zshCompletionDir/_yake"
    chown $zshUser "$zshCompletionDir/_yake";
fi

# EXIT IF FAILS
if [ $? != 0 ]; then
    exit $?
fi

# INSTALLATION FINISHED SUCCESSFULLY
echo "\"yake\" installed!";
echo "";
echo "You can run now:"
echo "\$ yake --help";