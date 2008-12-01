#!/usr/bin/env perl -w

use strict;

my %object = (
    account_id  => 1,
    token_text  => 'token_text',
    call_count  => 2,
    call_limit  => 3,
    start_date  => '2008-01-01',
    end_date    => '2008-02-02',
    status      => 'A',
);

use Test::More tests => 7;
use Data::AccountToken;
Data::AccountToken->connect();

# Store and retrieve an object to check all fields

my $inserted = Data::AccountToken->new( %object );
$inserted->insert();
my $retrieved = Data::AccountToken->row($inserted->{id});
$inserted->delete();
    
while (my ($field, $value) = each %object)
{
    is $retrieved->{$field}, $value, "retrieved $field is $value";
}

__END__
