#!/usr/bin/env perl -w

use strict;

my %object = (
    customer_id => 1,
    parent_id   => 2,
    status      => 'L',
    start_date  => '2008-01-01',
    end_date    => '2008-02-02',
    realname    => 'realname',
    username    => 'username',
    password    => 'password',
    email       => 'email',
    referrer    => 'referrer',
    comments    => 'comments',
);

use Test::More tests => 11;
use Data::Account;
Data::Account->connect();

# Store and retrieve a object to check all fields

my $inserted = Data::Account->new( %object );
$inserted->insert();
my $retrieved = Data::Account->row($inserted->{id});
$inserted->delete();
    
while (my ($field, $value) = each %object)
{
    is $retrieved->{$field}, $value, "retrieved $field is $value";
}

__END__
