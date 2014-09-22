#!/usr/bin/perl
use strict;
use warnings;

use Device::Plugwise;

my $plugwise = Device::Plugwise->new(device => '/dev/ttyUSB0');

$plugwise->command('on', '7291CD'); # Enable Circle#ABCDEF
my $message = "";
$message = $plugwise->read();
print $message, "\n";

#$plugwise = Device::Plugwise->new(device => 'hostname:port');
#$plugwise->command('on', 'ABCDEF'); # Enable Circle#ABCDEF

