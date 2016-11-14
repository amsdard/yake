#!/usr/bin/env perl

use strict;
use warnings FATAL => 'all';

use Cwd;
use YAML::XS 'LoadFile';
use Data::Dumper;

# GLOBAL SETTINGS
my $settings = {
    YAKEFILE => "Yakefile",
    BIN => $0,
    CMD => "",
};

# PARSE ARGUMENTS
my $CMDNAME = "";
my @CMDARR = ();
my $CMDSETTINGS = {};
foreach my $argCmd (@ARGV) {
    if ($CMDNAME eq "" && index($argCmd, '=') != -1) {
        my @cmdTab = split /\=/, $argCmd;
        if ($#cmdTab == "1" && $cmdTab[0] ne "" && $cmdTab[0] =~ /[a-zA-Z0-9\_]/) {
            $CMDSETTINGS->{$cmdTab[0]} = $cmdTab[1];
        }
    } elsif ($CMDNAME eq "") {
        $CMDNAME = $argCmd;
    } else {
        push @CMDARR, $argCmd;
    }
}
if ($settings->{'CMD'} eq "") {
    $settings->{'CMD'} = join(' ', @CMDARR);
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
foreach my $varName (keys %{$settings})
{
    while( my( $sName, $sValue ) = each %{$commands->{'_config'}} ){
        $sName = "\$$sName";
        $settings->{$varName} =~ s/\Q$sName/$sValue/g;
    }
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
    $command = join(" && ", @{$commands->{$CMDNAME}});
} else {
    $command = $commands->{$CMDNAME};
}

while( my( $varName, $varValue ) = each %{$settings} ){
    $varName = "\$$varName";
    $command =~ s/\Q$varName/$varValue/g;
}

print $command . "\n";