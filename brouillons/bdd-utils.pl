#!/usr/bin/perl
use strict;
use warnings;
use DBI;


# connecte à la base de donner et retourne le connecteur
sub connect {
  return DBI->connect('DBI:mysql:plugwise:localhost', 'boutserin', 'bouh')
    or die "Cannot connect: " . $DBI::errstr;
}

# (re)initialise la base de données
sub initbdd {
  my $dbh = connect();
  $dbh->do("DROP TABLE IF EXISTS record, circlegroup, circle");
  $dbh->do("CREATE TABLE IF NOT EXISTS record (id INTEGER AUTO_INCREMENT UNIQUE, circleid VARCHAR(10), date DATE, value FLOAT, recdate DATE, PRIMARY KEY (circleid, date))");
  $dbh->do("CREATE TABLE IF NOT EXISTS circlegroup (id INTEGER AUTO_INCREMENT UNIQUE, name VARCHAR(20), circleid VARCHAR(10))");
  $dbh->do("CREATE TABLE IF NOT EXISTS circle (id INTEGER AUTO_INCREMENT UNIQUE, name VARCHAR(20), address VARCHAR(10) PRIMARY KEY, hystoryindex INTEGER)");
  $dbh->disconnect();
}

# retourne la consommation du groupe de circle $group à la date $date
sub getgroupconsoatdate {
  my($group, $date) = @_;

  my $stmt = "SELECT sum(value) FROM record, circlegroup WHERE record.circleid = circlegroup.circleid AND circlegroup.name = $group AND record.date = $date";
  return select($stmt);
}

# envoie un select à mysql et retourne le résultat
sub select {
  my $stmt = shift(@_);
  my $results;

  my $dbh = connect();

  my $sth = $dbh->prepare($stmt);
  $sth->execute();

  while (my $ref = $sth->fetchrow_hashref()) {
    print "Found a row: id = $ref->{'id'}, name = $ref->{'name'}\n";
  }
  $sth->finish();

  $dbh->disconnect();

  return 
}

# enregistre la valeur $value de la date $date pour le circle $circle
sub record {
  my($circle, $date, $value) = @_;

  

}

sub getrecord {
  my($circle, $date) = @_

  my $dbh = connect();

  my $stmt = "SELECT value FROM record, value WHERE record.circleid = circle.address AND record.date = $date AND circle.name = $circle";
  my $sth = $dbh->prepare($stmt);
  $sth->execute();
  

}

