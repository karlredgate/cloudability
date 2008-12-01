#!/usr/bin/env perl -w

use strict;

my %object = (
    account_id      => 1,
    aws_public_ip   => 'aws_public_ip',
    name            => 'name',
    description     => 'description',
    created_at      => '2008-11-30 11:22:33',
    deleted_at      => '2008-11-30 22:33:44',
    status          => 'D',
);

use Test::More tests => 7;
use Data::Address;
Data::Address->connect();

# Store and retrieve an object to check all fields

my $inserted = Data::Address->new( %object );
$inserted->insert();
my $retrieved = Data::Address->row($inserted->{id});
$inserted->delete();
    
while (my ($field, $value) = each %object)
{
    is $retrieved->{$field}, $value, "retrieved $field is $value";
}

__END__
