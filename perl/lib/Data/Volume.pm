#!/usr/bin/env perl

=head1 NAME

Data::Volume - Manages customer account volumes, to hold customer data securely

=head1 VERSION

This document refers to version 1.0 of Data::Volume, released Nov 07, 2008

=head1 DESCRIPTION

Data::Volume manages customer account volumes, to hold customer data securely.
Be sure to call the class static method connect() before using Data::Volume
objects and disconnect() once you've finished.

=head2 Properties

=over 4

=item account_id

The volume owner's account ID

=item aws_volume_id

The AWS volume ID, for example "vol-164ca97f"

=item aws_size

The AWS volume size in GB, for example 100 (can be up to 1000)

=item aws_avail_zone

The AWS volume availability zone, for example "us-east-1a"

=item aws_status

The AWS volume status, for example "available", "deleting" or "deleted"

=item aws_device

When attached, the device the AWS volume is attached to, e.g. "/dev/sdx"

=item aws_instance_id

When attached, the AWS instance ID to which the AWS volume is attached

=item aws_attached_at

When attached, the date and time the AWS volume was attached to the instance

=item aws_created_at

The AWS date and time the volume was created

=back

=cut
package Data::Volume;
$VERSION = "1.0";

use strict;
use base 'Data::Object';
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
    $class->fields(qw(account_id aws_volume_id aws_size aws_avail_zone aws_status aws_device aws_instance_id aws_attached_at aws_created_at));

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

=item find_by_aws_volume_id($aws_volume_id)

Find a volume in the database by its AWS volume ID

=cut
sub find_by_aws_volume_id
{
    my ($self, $aws_volume_id) = @_;
    my $class = ref $self || $self;

    $class->connect();
    my $volume = $class->select('aws_volume_id = ?', $aws_volume_id);
    #$class->disconnect();

    return $volume;
}

}1;

=back

=head1 DEPENDENCIES

Data::Object

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
