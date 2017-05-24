#!/usr/bin/env sh

# basic commands
testYake()
{
    assertEquals "`$YAKE_BIN hello_world`" $'hello world';

    assertEquals "`$YAKE_BIN run echo 1`" $'running...\n1';

}

# change Yakefile name
testYakefile()
{
    mv Yakefile yakefile.yml
    assertEquals "`$YAKE_BIN YAKEFILE=yakefile.yml hello_world`" $'hello world';
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