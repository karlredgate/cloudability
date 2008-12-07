#!/usr/bin/env perl

use strict;
use warnings;
use Constants::AWS;

my $aws_snapshot_id = 'snap-2383604a';

my %object = (
    account_id      => 1,
    aws_snapshot_id => $aws_snapshot_id,
    aws_volume_id   => 'aws_volume_id',
    aws_status      => 'aws_status',
    aws_started_at  => '2008-11-25 12:34:56',
    aws_progress    => '100%',
    name            => 'name',
    description     => 'description',
    deleted_at      => '2008-11-30 12:34:56',
    status          => Constants::AWS::STATUS_ACTIVE,
);

use Test::More tests => 10;
use Models::Snapshot;
Models::Snapshot->connect();

# Store and retrieve an object to check all fields

my $inserted = Models::Snapshot->new( %object );
$inserted->insert();

# Test the "soft_delete()" method

$inserted->soft_delete();
$object{status} = Constants::AWS::STATUS_DELETED;
$object{deleted_at} = $inserted->{deleted_at};

# Retrieve the "soft_deleted" object and really delete it

my $retrieved = Models::Snapshot->find_by_aws_snapshot_id($aws_snapshot_id);
$inserted->delete();
    
while (my ($field, $value) = each %object)
{
    is $retrieved->{$field}, $value, "retrieved $field is $value";
}

__END__
