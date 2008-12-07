#!/usr/bin/env perl

=head1 NAME

Models::Image - Manages available AWS images for customers to run

=head1 VERSION

This document refers to version 1.0 of Models::Image, released Nov 07, 2008

=head1 DESCRIPTION

Models::Image manages available AWS images for customers to run.
Be sure to call the class static method connect() before using Models::Image
objects and disconnect() once you've finished.

=head2 Properties

=over 4

=item aws_image_id

The AWS image ID

=item aws_location

The AWS location of the image manifest file in the S3 storage service

=item aws_state

The AWS state of the image, for example "available"

=item aws_owner_id

The AWS owner ID for the image, for example "992046831893"

=item aws_is_public

Whether the AWS image is publicly available ('Y' or 'N')

=item aws_architecture

The AWS machine architecture of the image, for example "i386"

=item aws_type

The AWS image type, for example "machine"

=item aws_kernel_id

The AWS kernel ID for the image, for example "aki-a71cf9ce"

=item aws_ramdisk_id

The AWS ramdisk ID for the image, for example "ari-a51cf9cc"

=item name

A useful human name for the image, for example its operating system "Ubuntu 8.1"

=item description

A useful human description of the AWS image, for example its installed services

=back

=cut
package Models::Image;
$VERSION = "1.0";

use strict;
use base 'Models::Object';
{
    # Class static properties

    my $_Connection;

=head2 Class Methods

=over 4

=item connect(driver=>'mysql', database=>'dbname', user=>'username', password=>'pass')

Initialise a connection to the database with optional details

=cut
sub connect
{
    my ($class, %args) = @_;
    return $_Connection if $_Connection;

    $args{host} ||= $ENV{MASTER_SERVER};
    eval {
        $_Connection = $class->SUPER::connect(%args);
    }; if ($@) {
        $args{host} = $ENV{BACKUP_SERVER};
        $_Connection = $class->SUPER::connect(%args);
    }
    $class->fields(qw(aws_image_id aws_location aws_state aws_owner_id aws_is_public aws_architecture aws_type aws_kernel_id aws_ramdisk_id name description));

    return $_Connection;
}

=item disconnect()

Disconnect from the database cleanly

=cut
sub disconnect
{
    my ($class) = @_;
    return unless $_Connection;

    $_Connection = undef;
    $class->SUPER::disconnect();
}

=back

=head2 Object Methods

=over 4

=item None

=cut

}1;

=back

=head1 DEPENDENCIES

Models::Object

=head1 AUTHOR

Kevin Hutchinson <kevin.hutchinson@legendum.com>

=head1 COPYRIGHT

Copyright (c) 2008 Legendum LLC

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 3
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.
