#!/usr/bin/env perl

use strict;
use warnings;

my %object = (
    account_id  => 1,
    field       => 'field',
    value       => 'value',
);

use Test::More tests => 3;
use Data::AccountConfig;
Data::AccountConfig->connect();

# Store and retrieve an object to check all fields

my $inserted = Data::AccountConfig->new( %object );
$inserted->insert();
my $retrieved = Data::AccountConfig->row($inserted->{id});
$inserted->delete();
    
while (my ($field, $value) = each %object)
{
    is $retrieved->{$field}, $value, "retrieved $field is $value";
}

__END__
