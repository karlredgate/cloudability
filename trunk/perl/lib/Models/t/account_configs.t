#!/usr/bin/env perl

use strict;
use warnings;

my $account_id = 1;

my %object = (
    account_id  => $account_id,
    field       => 'field',
    value       => 'value',
);

use Test::More tests => 6;
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

# Test that "get" and "set" work

my $config;
Models::AccountConfig->set($account_id, 'this', 'that');
$config = Models::AccountConfig->get($account_id);
is $config->{this}, 'that', "get field 'this' has value 'that'";

Models::AccountConfig->set($account_id, 'this', 'other');
$config = Models::AccountConfig->get($account_id);
is $config->{this}, 'other', "get field 'this' has value 'other'";

Models::AccountConfig->set($account_id, 'this', '');
$config = Models::AccountConfig->get($account_id);
is $config->{this}, undef, "get field 'this' has undefined value";

__END__
