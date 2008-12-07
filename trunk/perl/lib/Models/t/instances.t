#!/usr/bin/env perl

use strict;
use warnings;

my $aws_instance_id = 'i-4064d929';

my %object = (
    account_id      => 1,
    cluster_id      => 0,
    deployment_id   => 1,
    aws_instance_id => $aws_instance_id,
    aws_image_id    => 'aws_image_id',
    aws_kernel_id   => 'aws_kernel_id',
    aws_ramdisk_id  => 'aws_ramdisk_id',
    aws_inst_state  => 'aws_inst_state',
    aws_inst_type   => 'aws_inst_type',
    aws_avail_zone  => 'aws_avail_zone',
    aws_key_name    => 'aws_key_name',
    aws_public_dns  => 'aws_public_dns',
    aws_private_dns => 'aws_private_dns',
    aws_started_at  => '2008-11-24 00:00:00',
    aws_finished_at => '2008-11-24 23:59:59',
    aws_term_reason => 'aws_term_reason',
    name            => 'name',
    description     => 'description',
    status          => 'R',
);

use Test::More tests => 19;
use Models::Instance;
Models::Instance->connect();

# Store and retrieve an object to check all fields

my $inserted = Models::Instance->new( %object );
$inserted->insert();
my $retrieved = Models::Instance->find_by_aws_instance_id($aws_instance_id);
$inserted->delete();
    
while (my ($field, $value) = each %object)
{
    is $retrieved->{$field}, $value, "retrieved $field is $value";
}

# TODO: Find a way to test the "deploy_to_host()" method without "system" calls

__END__
