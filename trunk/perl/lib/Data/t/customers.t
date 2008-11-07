#!/usr/bin/env perl -w

use strict;

my %object = (
    contact    => 'contact',
    company    => 'company',
    street1    => 'street1',
    street2    => 'street2',
    city       => 'city',
    country    => 'country',
    zip_code   => 'zip_code',
    tel_number => 'tel_number',
    fax_number => 'fax_number',
    vat_number => 'vat_number',
    url        => 'url',
    email      => 'email',
    brand      => 'brand',
);

use Test::More tests => 13;
use Data::Customer;
Data::Customer->connect();

# Store and retrieve a object to check all fields

my $inserted = Data::Customer->new( %object );
$inserted->insert();
my $retrieved = Data::Customer->row($inserted->{id});
$inserted->delete();
    
while (my ($field, $value) = each %object)
{
    is $retrieved->{$field}, $value, "retrieved $field is $value";
}

__END__
