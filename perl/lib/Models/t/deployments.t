#!/usr/bin/env perl

use strict;
use warnings;

my %object = (
    account_id      => 1,
    aws_image_id    => 'aws_image_id',
    aws_inst_type   => 'aws_inst_type',
    aws_avail_zone  => 'aws_avail_zone',
    aws_sec_group   => 'aws_sec_group',
    aws_key_name    => 'aws_key_name',
    deploy_file     => 'example.sh',
    is_elasic       => 'N',
    name            => 'name',
    description     => 'description',
    status          => 'A',
);

use Test::More tests => 12;
use Models::Deployment;
Models::Deployment->connect();

# Store and retrieve an object to check all fields

my $inserted = Models::Deployment->new( %object );
$inserted->insert();

# Test the "soft_delete()" method

$inserted->soft_delete();
$object{status} = Constants::AWS::STATUS_DELETED;
$object{deleted_at} = $inserted->{deleted_at};

# Retrieve the "soft_deleted" object and really delete it

my $retrieved = Models::Deployment->row($inserted->{id});
$inserted->delete();
    
while (my ($field, $value) = each %object)
{
    is $retrieved->{$field}, $value, "retrieved $field is $value";
}

__END__
