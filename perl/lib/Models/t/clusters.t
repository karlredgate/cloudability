#!/usr/bin/env perl

use strict;
use warnings;

my %object = (
    account_id      => 1,
    deployment_id   => 2,
    instances_max   => 10,
    instances_min   => 2,
    run_hours_max   => 24,
    run_hours_min   => 1,
    load_too_high   => '2.50',
    load_too_low    => '0.10',
    process_name    => 'apache',
    proc_too_many   => 200,
    proc_too_few    => 20,
    pound_file      => 'apache.cfg',
    name            => 'Apache cluster',
    description     => 'A simple apache cluster',
    status          => 'A',
);

use Test::More tests => 16;
use Models::Cluster;
Models::Cluster->connect();

# Store and retrieve an object to check all fields

my $inserted = Models::Cluster->new( %object );
$inserted->insert();

# Test the "soft_delete()" method

$inserted->soft_delete();
$object{status} = Constants::AWS::STATUS_DELETED;
$object{deleted_at} = $inserted->{deleted_at};

# Retrieve the "soft_deleted" object and really delete it

my $retrieved = Models::Cluster->row($inserted->{id});
$inserted->delete();
    
while (my ($field, $value) = each %object)
{
    is $retrieved->{$field}, $value, "retrieved $field is $value";
}

__END__
