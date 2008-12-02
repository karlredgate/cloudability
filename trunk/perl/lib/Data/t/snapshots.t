#!/usr/bin/env perl

use strict;
use warnings;

my %object = (
    account_id      => 1,
    aws_snapshot_id => 'aws_snapshot_id',
    aws_volume_id   => 'aws_volume_id',
    aws_status      => 'aws_status',
    aws_started_at  => '2008-11-25 12:34:56',
    aws_progress    => '100%',
    name            => 'name',
    description     => 'description',
    deleted_at      => '2008-11-30 12:34:56',
    status          => 'D',
);

use Test::More tests => 10;
use Data::Snapshot;
Data::Snapshot->connect();

# Store and retrieve an object to check all fields

my $inserted = Data::Snapshot->new( %object );
$inserted->insert();
my $retrieved = Data::Snapshot->row($inserted->{id});
$inserted->delete();
    
while (my ($field, $value) = each %object)
{
    is $retrieved->{$field}, $value, "retrieved $field is $value";
}

__END__
