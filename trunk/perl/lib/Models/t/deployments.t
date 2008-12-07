#!/usr/bin/env perl

use strict;
use warnings;

my %object = (
    account_id  => 1,
    deploy_file => 'example.sh',
    is_elasic   => 'N',
    name        => 'name',
    description => 'description',
    status      => 'A',
);

use Test::More tests => 6;
use Models::Deployment;
Models::Deployment->connect();

# Store and retrieve an object to check all fields

my $inserted = Models::Deployment->new( %object );
$inserted->insert();
my $retrieved = Models::Deployment->row($inserted->{id});
$inserted->delete();
    
while (my ($field, $value) = each %object)
{
    is $retrieved->{$field}, $value, "retrieved $field is $value";
}

__END__
