#!/usr/bin/perl
use strict;
use warnings;

use Device::Plugwise;

my $plugwise = Device::Plugwise->new(device => '/dev/ttyUSB0');

#$plugwise->command('history', '7291CD', 1);


#for(my $i = 0; $i <= 10; $i++) {

# $plugwise->command('history', '7291CD', $i);
$plugwise->command('history', '7291CD', 787);
 my $message = $plugwise->read(60);
 my $key; my $value;
# while (($key, $value) = each $message) {
#   print $key, ":", $value, "\n";
 #  delete $hash{$key}; # This is safe
# }

#print $message, "\n";

# print $message->{"schema"}, "\n";
 foreach(@{$message->{"body"}}){
   print $_, "\n";
 }
#}

#$plugwise = Device::Plugwise->new(device => 'hostname:port');
#$plugwise->command('on', 'ABCDEF'); # Enable Circle#ABCDEF

