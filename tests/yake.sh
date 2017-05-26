#!/usr/bin/env sh

# basic commands
testYake()
{
    $YAKE_BIN hello_world | grep -Eq '^hello world'
    assertEquals "$?" "0";

    $YAKE_BIN run echo "grep me" | grep -Eq 'grep me'
    assertEquals "$?" "0";
}

# special parameters
testParams()
{
    $YAKE_BIN 2>&1 | grep -Eq '^Usage'
    assertEquals "$?" "0";

    $YAKE_BIN --help 2>&1 | grep -Eq ^'Usage'
    assertEquals "$?" "0";

    $YAKE_BIN --version 2>&1 | grep -Eq '^yake'
    assertEquals "$?" "0";
}

# internal and user config
testConfig()
{
    $YAKE_BIN _config 2>&1 | grep -Eq 'VAR2\s+two one'
    assertEquals "$?" "0";

    $YAKE_BIN VAR1=user _config 2>&1 | grep -Eq 'VAR2\s+two user'
    assertEquals "$?" "0";

    $YAKE_BIN VAR1=\"long user\" _config 2>&1 | grep -Eq 'VAR2\s+two long user'
    assertEquals "$?" "0";

    $YAKE_BIN VAR1=\"1 2 3 matchVar\" demo echo "matchMe" 2>&1 | grep -Eq 'VAR3 = tree VAR1=1 2 3 matchVar and VAR2=two 1 2 3 matchVar'
    assertEquals "$?" "0";

    $YAKE_BIN VAR1=\"1 2 3 matchVar\" demo echo "matchMe and me2" 2>&1 | grep -Eq 'matchMe and me2'
    assertEquals "$?" "0";
}

# change Yakefile name
testYakefile()
{
    mv Yakefile yakefile.yml
    $YAKE_BIN YAKEFILE=yakefile.yml hello_world | grep -Eq '^hello world'
    assertEquals "$?" "0";
    mv yakefile.yml Yakefile
}


##################################################################################################
##################################################################################################

oneTimeSetUp()
{
    cp ./Yakefile ./tests/Yakefile;
}

oneTimeTearDown()
{
    rm ./tests/Yakefile;
}

setUp()
{
    cd tests;
    export YAKE_BIN=../src/yake.sh;
}

tearDown()
{
    cd ..;
}