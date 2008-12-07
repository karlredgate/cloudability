#!/usr/bin/env perl

use strict;
use warnings;

my %object = (
    aws_image_id    => 'aws_image_id',
    aws_location    => 'aws_location',
    aws_state       => 'aws_state',
    aws_owner_id    => 'aws_owner_id',
    aws_is_public   => 'Y',
    aws_architecture => 'aws_architecture',
    aws_type        => 'aws_type',
    aws_kernel_id   => 'aws_kernel_id',
    aws_ramdisk_id  => 'aws_ramdisk_id',
    name            => 'name',
    description     => 'description',
);

use Test::More tests => 11;
use Models::Image;
Models::Image->connect();

# Store and retrieve an object to check all fields

my $inserted = Models::Image->new( %object );
$inserted->insert();
my $retrieved = Models::Image->row($inserted->{id});
$inserted->delete();
    
while (my ($field, $value) = each %object)
{
    is $retrieved->{$field}, $value, "retrieved $field is $value";
}

__END__
