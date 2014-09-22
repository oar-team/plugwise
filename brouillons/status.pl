#!/usr/bin/perl
use strict;
use warnings;

use Device::Plugwise;

my $plugwise = Device::Plugwise->new(device => '/dev/ttyUSB0');
$plugwise->command('status', '7291CD'); # Enable Circle#ABCDEF
#my $output = $plugwise->status();
my $message = $plugwise->read(60);
my $key; my $value;
while (($key, $value) = each $message) {
  print $key, ":", $value, "\n";
#  delete $hash{$key}; # This is safe
}

#print $message, "\n";

print $message->{"schema"}, "\n";
foreach(@{$message->{"body"}}){
  print $_, "\n";
}

#print $message, "\n";



#$plugwise = Device::Plugwise->new(device => 'hostname:port');
#$plugwise->command('on', 'ABCDEF'); # Enable Circle#ABCDEF

