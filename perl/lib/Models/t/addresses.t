#!/usr/bin/env perl

use strict;
use warnings;
use Constants::AWS;

my $public_ip = '111.222.333.444';

my %object = (
    account_id      => 1,
    aws_public_ip   => $public_ip,
    aws_instance_id => 'aws_instance_id',
    name            => 'name',
    description     => 'description',
    created_at      => '2008-11-30 11:22:33',
    status          => Constants::AWS::STATUS_ACTIVE,
);

use Test::More tests => 11;
use Models::Address;
Models::Address->connect();

# Store and retrieve an object to check all fields

my $inserted = Models::Address->new( %object );
$inserted->insert();

# Test find_by_public_ip()

my $found = Models::Address->find_by_public_ip($public_ip);
is $found->{aws_public_ip}, $public_ip, "find_by_public_ip() finds an address";

# Test soft_delete()

$found->soft_delete();
is $found->{status}, Constants::AWS::STATUS_DELETED, "soft_delete() status 'D'";
ok $found->{deleted_at}, "soft_delete() sets the 'deleted_at' field";

# Update the reference test object

$object{status} = $found->{status};
$object{deleted_at} = $found->{deleted_at};

# Test retrieving the fields

my $retrieved = Models::Address->row($inserted->{id});
$inserted->delete();
    
while (my ($field, $value) = each %object)
{
    is $retrieved->{$field}, $value, "retrieved $field is $value";
}

__END__
