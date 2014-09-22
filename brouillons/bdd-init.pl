#!/usr/bin/perl
use strict;
use warnings;
use DBI;


my $dbh = DBI->connect('DBI:mysql:plugwise:localhost', 'boutserin', 'bouh')
  or die "Cannot connect: " . $DBI::errstr;

$dbh->do("DROP TABLE IF EXISTS record, circlegroup, circle");
$dbh->do("CREATE TABLE IF NOT EXISTS record (id INTEGER AUTO_INCREMENT UNIQUE, circleid VARCHAR(10), date DATETIME, value FLOAT, recdate DATETIME, PRIMARY KEY (circleid, date))");
$dbh->do("CREATE TABLE IF NOT EXISTS circlegroup (id INTEGER AUTO_INCREMENT UNIQUE, name VARCHAR(20), circleid VARCHAR(10))");
$dbh->do("CREATE TABLE IF NOT EXISTS circle (id INTEGER AUTO_INCREMENT UNIQUE, name VARCHAR(20), address VARCHAR(10) PRIMARY KEY, hystoryindex INTEGER DEFAULT -1)");


