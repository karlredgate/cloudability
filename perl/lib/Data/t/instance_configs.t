#!/usr/bin/env perl -w

use strict;

my %object = (
    instance_id => 1,
    field       => 'field',
    value       => 'value',
);

use Test::More tests => 3;
use Data::InstanceConfig;
Data::InstanceConfig->connect();

# Store and retrieve a object to check all fields

my $inserted = Data::InstanceConfig->new( %object );
$inserted->insert();
my $retrieved = Data::InstanceConfig->row($inserted->{id});
$inserted->delete();
    
while (my ($field, $value) = each %object)
{
    is $retrieved->{$field}, $value, "retrieved $field is $value";
}

__END__
