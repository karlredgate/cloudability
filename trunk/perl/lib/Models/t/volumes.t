#!/usr/bin/env perl

use strict;
use warnings;
use Constants::AWS;

my $aws_volume_id = 'vol-1fbe5a76';

my %object = (
    account_id      => 1,
    aws_volume_id   => $aws_volume_id,
    aws_size        => 10,
    aws_avail_zone  => 'aws_avail_zone',
    aws_status      => 'aws_status',
    aws_device      => 'aws_device',
    aws_instance_id => 'aws_instance_id',
    aws_attached_at => '2008-11-25 12:34:56',
    aws_created_at  => '2008-11-24 00:00:00',
    name            => 'name',
    description     => 'description',
    deleted_at      => '2008-11-30 12:34:56',
    status          => Constants::AWS::STATUS_ACTIVE,
);

use Test::More tests => 13;
use Models::Volume;
Models::Volume->connect();

# Store and retrieve an object to check all fields

my $inserted = Models::Volume->new( %object );
$inserted->insert();

# Test the "soft_delete()" method

$inserted->soft_delete();
$object{status} = Constants::AWS::STATUS_DELETED;
$object{deleted_at} = $inserted->{deleted_at};

# Retrieve the "soft_deleted" object and really delete it

my $retrieved = Models::Volume->find_by_aws_volume_id($aws_volume_id);
$inserted->delete();
    
while (my ($field, $value) = each %object)
{
    is $retrieved->{$field}, $value, "retrieved $field is $value";
}

__END__
