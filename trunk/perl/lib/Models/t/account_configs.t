#!/usr/bin/env perl

use strict;
use warnings;

my %object = (
    account_id  => 1,
    field       => 'field',
    value       => 'value',
);

use Test::More tests => 3;
use Models::AccountConfig;
Models::AccountConfig->connect();

# Store and retrieve an object to check all fields

my $inserted = Models::AccountConfig->new( %object );
$inserted->insert();
my $retrieved = Models::AccountConfig->row($inserted->{id});
$inserted->delete();
    
while (my ($field, $value) = each %object)
{
    is $retrieved->{$field}, $value, "retrieved $field is $value";
}

__END__
