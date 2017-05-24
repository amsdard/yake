#!/usr/bin/env perl

use constant {
    VERSION => '2.0',
    YAKE_URL => 'http://yake.app',
    VAR_MODE => 1,
    VALUE_MODE => 2,
    VALUE_QUOT_MODE => 3,
    VALUE_DQUOT_MODE => 4,
    PARAM_MODE => 5,
    CMD_MODE => 6
};

use strict;
use warnings FATAL => 'all';

use Cwd;
use YAML::XS 'LoadFile';
use Data::Dumper;

# GLOBAL SETTINGS
my $settings = {
    YAKEFILE => "Yakefile",
    FORCE_ALL => 0,
    BIN => $0,
    CMD => "",
};

# helpers
sub  trim { my $s = shift; $s =~ s/^\s+|\s+$//g; return $s };
sub ltrim { my $s = shift; $s =~ s/^\s|\-+//;       return $s };

# PARSE ARGUMENTS
my $CMDNAME = "";
my $CMDSETTINGS = {};
my $CMDPARAMS = {};
my $argsMode = VAR_MODE;
my $vStorageVar = "";
my $vStorage = undef;

foreach my $v (split //, "@ARGV ") {
    if ($argsMode eq VALUE_MODE or $argsMode eq VALUE_QUOT_MODE or $argsMode eq VALUE_DQUOT_MODE) {
        my $endChar = " ";
        if ($argsMode eq VALUE_QUOT_MODE) {
            $endChar = "'";
        } elsif ($argsMode eq VALUE_DQUOT_MODE) {
            $endChar = '"';
        }

        if (defined $vStorage and $v eq $endChar) {
            $CMDSETTINGS->{$vStorageVar} = $vStorage;
            $vStorage = undef;
            $vStorageVar = "";
            $argsMode = VAR_MODE;
            next;
        }
    }

    if ($argsMode eq PARAM_MODE and defined $vStorage and ($v eq " " or $v eq "=")) {
        $CMDPARAMS->{ltrim $vStorage} = 1;
        $vStorage = undef;
        $argsMode = VAR_MODE;
        next;
    }

    if ($argsMode eq VAR_MODE) {
        if (defined $vStorage) {
            if ($v eq '=') {
                $vStorageVar = $vStorage;   $vStorage = undef;
                $argsMode = VALUE_MODE;
                next;
            } elsif ($v eq " ") {
                $CMDNAME = trim $vStorage;   $vStorage = undef;
                $argsMode = CMD_MODE;
                next;
            } elsif ($v eq '-') {
                $argsMode = PARAM_MODE;
            }
        }
    } elsif ($argsMode == VALUE_MODE) {
        if ( ! defined $vStorage) {
            if ($v eq "'") {
                $argsMode = VALUE_QUOT_MODE;
                next;
            } elsif ($v eq '"') {
                $argsMode = VALUE_DQUOT_MODE;
                next;
            }
        }
    }

    if (defined $vStorage) {
        $vStorage .= $v;
    } else {
        $vStorage = $v;
    }
}

if (defined $vStorage) {
    if ($argsMode == CMD_MODE) {
        $settings->{'CMD'} = $vStorage;
    } else {
        $CMDNAME = $vStorage;
    }
}

#print Dumper($CMDNAME, $CMDSETTINGS, $CMDPARAMS, $settings->{'CMD'}, $argsMode);exit 1;

if ( $CMDPARAMS->{'version'} ) {
    my $versionUrl = YAKE_URL . "/VERSION";
    my $currVarsion = `curl -m 5 -sSf $versionUrl`;
    print $currVarsion;
    print "Do not use params with regular usage\n";
    exit 1;
}
if ( $CMDPARAMS->{'help'} or (keys $CMDPARAMS > 0 and $CMDNAME ne "") or $CMDNAME eq "" ) {
    print "Usage: $CMDSETTINGS->{BIN} [options...] <task> <CMD>\n";
    print "\t--version\t see Yake version and check updates\n";
    print "\t--help\t\t show docs \n";
    print "\t--upgrade\t execute Yake upgrade to latest version \n";
    print "\t--debug\t\t do not execute task, show script params and full command as text (able to use with <task> only) \n";
    exit 1;
}

# LOAD Yakefile
my $pwd = cwd();
my $yakefile = "$pwd/$settings->{YAKEFILE}";
if (! -f $yakefile) {
    print "Cant find \"$settings->{YAKEFILE}\" in Your current directory\n";
    exit 1;
}
my $commands = LoadFile($yakefile);
if ( ! exists $commands->{$CMDNAME} ) {
    print "Cant find \"$CMDNAME\" task in Your \"$settings->{YAKEFILE}\"\n";
    exit 1;
}

# LOAD USER's YAKEFILE CONFIG
if ( exists $commands->{'_config'} ) {
    my $configType = ref($commands->{'_config'});
    if ( $configType ne "HASH" ) {
        print "Your \"_config\" section must be an object, \"$configType\" found.\n";
        exit 1;
    }
    while( my( $varName, $varValue ) = each %{$commands->{'_config'}} ){
        my $varValueType = ref($varValue);
        if ( $varValueType ne "" ) {
            print "Your config \"$varName\" value must be string, \"$varValueType\" found.\n";
            exit 1;
        }
        $settings->{$varName} = $varValue;
    }
}

# OVERWRITE YAKEFILE CONFIG
while( my( $varName, $varValue ) = each %{$CMDSETTINGS} ){
    $settings->{$varName} = $varValue;
}

# COMPLETE CONFIG VARIBLES
my $found = 1;
while ($found > 0) {
    $found = 0;
    foreach my $varName (keys %{$settings}) {
        foreach my $varSubName (keys %{$settings}) {
            my $sName = "\$$varSubName";
            my $sValue = $settings->{$varSubName};
            my $varFounds = () = $settings->{$varName} =~ /\Q$sName/g;
            if ($varFounds > 0) {
                $found++;
            }
            $settings->{$varName} =~ s/\Q$sName/$sValue/g;
        }
    }
}

# ADD CONFIG OVERWRITTIES TO BIN PATH
while( my( $varName, $varValue ) = each %{$CMDSETTINGS} ){
    $settings->{'BIN'} .= " $varName=$varValue"
}

# SHOW CONFIG IF REQUESTED
if ($CMDNAME eq "_config") {
    foreach my $varName (sort keys %{$settings}) {
        my $varValue = $settings->{$varName};
        print "$varName=$varValue\n";
    }
    exit 1;
}

# GENERATE COMMAND
my $commandType = ref($commands->{$CMDNAME});
if ( ! ($commandType eq "" or $commandType eq "ARRAY") ) {
    print "Your task \"$CMDNAME\" must be an array or a string, \"$commandType\" found.\n";
    exit 1;
}
my $command = "";
if ($commandType eq "ARRAY") {
    $command = join(($settings->{'FORCE_ALL'} ? ' || true' : '')." && ", @{$commands->{$CMDNAME}});
} else {
    $command = $commands->{$CMDNAME};
}
$command .= $settings->{'FORCE_ALL'} ? ' || true' : '';

my $cmdFound = 1;
while ($cmdFound > 0) {
    $cmdFound = 0;
    while( my( $varName, $varValue ) = each %{$settings} ){
        $varName = "\$$varName";
        my $varFounds = () = $command =~ /\Q$varName/g;
        if ($varFounds > 0) {
            $cmdFound++;
        }
        $command =~ s/\Q$varName/$varValue/g;
    }
}

print $command . "\n";