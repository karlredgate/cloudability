#!/usr/bin/env perl

use strict;
use warnings;

my %object = (
    contact         => 'contact',
    company         => 'company',
    street1         => 'street1',
    street2         => 'street2',
    city            => 'city',
    country         => 'country',
    zip_code        => 'zip_code',
    tel_number      => 'tel_number',
    fax_number      => 'fax_number',
    tax_number      => 'tax_number',
    url             => 'url',
    email           => 'email',
    brand           => 'brand',
    aws_access_key  => 'aws_access_key',
    aws_secret_key  => 'aws_secret_key',
    aws_account_num => 'aws_account_num',
    aws_cert_name   => 'aws_cert_name',
    aws_cert_text   => 'aws_cert_text',
);

use Test::More tests => 18;
use Models::Customer;
Models::Customer->connect();

# Store and retrieve an object to check all fields

my $inserted = Models::Customer->new( %object );
$inserted->insert();
my $retrieved = Models::Customer->row($inserted->{id});
$inserted->delete();
    
while (my ($field, $value) = each %object)
{
    is $retrieved->{$field}, $value, "retrieved $field is $value";
}

__END__
