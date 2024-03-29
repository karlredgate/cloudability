#!/usr/bin/env perl

use strict;
use warnings;

my %object = (
    customer_id => 1,
    parent_id   => 2,
    status      => 'L',
    start_date  => '2008-01-01',
    end_date    => '2008-02-02',
    name        => 'name',
    email       => 'email',
    phone       => 'phone',
    username    => 'username',
    password    => 'password',
    referrer    => 'referrer',
    comments    => 'comments',
);

use Test::More tests => 12;
use Models::Account;
Models::Account->connect();

# Store and retrieve an object to check all fields

my $inserted = Models::Account->new( %object );
$inserted->insert();
my $retrieved = Models::Account->row($inserted->{id});
$inserted->delete();
    
while (my ($field, $value) = each %object)
{
    is $retrieved->{$field}, $value, "retrieved $field is $value";
}

__END__
