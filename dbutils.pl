#!/usr/bin/perl
package dbutils;
$VERSION = v0.0.1;

use Carp;
use strict;
use warnings;
use DBI;


# connecte à la base de donner et retourne le connecteur
sub connecttodb {
  return DBI->connect("DBI:mysql:database=plugwise;host=localhost", "boutserin", "bouh");
#    or die "Cannot connect: " . $DBI::errstr;
}

# (re)initialise la base de données
sub initbdd {
  my $dbh = connecttodb();
  $dbh->do("DROP TABLE IF EXISTS record, circlegroup, circle");
  $dbh->do("CREATE TABLE IF NOT EXISTS record (id INTEGER AUTO_INCREMENT UNIQUE, circleid VARCHAR(10), date DATETIME, value FLOAT, recdate DATETIME, PRIMARY KEY (circleid, date))");
  $dbh->do("CREATE TABLE IF NOT EXISTS circlegroup (id INTEGER AUTO_INCREMENT UNIQUE, name VARCHAR(20), circleid VARCHAR(10))");
  $dbh->do("CREATE TABLE IF NOT EXISTS circle (id INTEGER AUTO_INCREMENT UNIQUE, name VARCHAR(20), address VARCHAR(10) PRIMARY KEY, hystoryindex INTEGER DEFAULT -1)");
  $dbh->disconnect();
}

# retourne la consommation du groupe de circle $group à la date $date
sub getgroupconsoatdate {
  my($group, $date) = @_;

  my $stmt = "SELECT sum(value) FROM record, circlegroup WHERE record.circleid = circlegroup.circleid AND circlegroup.name = $group AND record.date = $date";
  return selectfromdb($stmt);
}

# envoie un select à mysql et retourne le résultat
# Le résultat est une référence sur un tableau avec sur chaque ligne une référence sur un hash contenant les noms du champ en clefs associées à leur valeur
sub selectfromdb {
  my $stmt = shift(@_);
  my $results = [];

  my $dbh = connecttodb();

  my $sth = $dbh->prepare($stmt);
  $sth->execute();

  my $i = 0;
  while (my $ref = $sth->fetchrow_hashref()) {
    $results->[$i] = $ref;
    $i++;
  }

  $sth->finish();

  $dbh->disconnect();

  return $results; 
}

# enregistre la valeur $value de la date $date pour le circle $circle
sub record {
  my($circle, $date, $value, $recdate) = @_;

#  my $test = getrecord($circle, $date);
#  if $test->[0]->{'value'}

  my $dbh = connecttodb();
  $dbh->do("INSERT INTO record WHERE (circleid, date, value, recdate) = ($circle, $date, $value, $recdate);");
  $dbh->disconnect();
}

sub getrecord {
  my($circle, $date) = @_;
  my $results;

  my $stmt = "SELECT value FROM record, circle WHERE record.circleid = circle.address AND record.date = $date AND circle.name = $circle";
  $results = selectfromdb($stmt);


  return $results;
}

1;

