#!/usr/bin/env perl

use strict;
use warnings;
use Constants::AWS;

my $account_id = 1;

my %object = (
    account_id  => $account_id,
    token_text  => 'token_text',
    call_count  => 2,
    call_limit  => 3,
    start_date  => '2008-01-01',
    end_date    => '2020-02-02',
    status      => 'A',
);

use Test::More tests => 9;
use Models::AccountToken;
Models::AccountToken->connect();

# Store and retrieve an object to check all fields

my $inserted = Models::AccountToken->new( %object );
$inserted->insert();

# Test calling the account token

my $status = $inserted->call(); die $status if $status;
$object{call_count}++; # ...coz it has been called

# Check the retrieved fields have the right values

my $retrieved = Models::AccountToken->row($inserted->{id});
$inserted->delete();
    
while (my ($field, $value) = each %object)
{
    is $retrieved->{$field}, $value, "retrieved $field is $value";
}

# Test creating a new account token with "create()"

my $created = Models::AccountToken->new(); $created->create($account_id);
is $created->{status}, Constants::AWS::STATUS_ACTIVE, "create() makes a token";
is $created->{call_count}, 0, "created token has not been called yet";
$created->delete();

__END__
