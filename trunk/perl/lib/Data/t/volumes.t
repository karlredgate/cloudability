#!/usr/bin/env perl -w

use strict;

my %object = (
    account_id      => 1,
    aws_volume_id   => 'aws_volume_id',
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
    status          => 'D',
);

use Test::More tests => 13;
use Data::Volume;
Data::Volume->connect();

# Store and retrieve an object to check all fields

my $inserted = Data::Volume->new( %object );
$inserted->insert();
my $retrieved = Data::Volume->row($inserted->{id});
$inserted->delete();
    
while (my ($field, $value) = each %object)
{
    is $retrieved->{$field}, $value, "retrieved $field is $value";
}

__END__
