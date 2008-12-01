#!/usr/bin/env perl

=head1 NAME

Data::Address - Manages customer IP addresses, to provide DNS into Amazon AWS

=head1 VERSION

This document refers to version 1.0 of Data::Address, released Nov 30, 2008

=head1 DESCRIPTION

Data::Address manages customer IP addresses, to provide DNS into Amazon AWS.
Be sure to call the class static method connect() before using Data::Address
objects and disconnect() once you've finished.

=head2 Properties

=over 4

=item account_id

The IP address owner's account ID

=item aws_public_ip

The public IP address

=item name

A user-assigned name for the IP address, for example "Acme main public IP"

=item description

A user-assigned description for the IP address, for example "Site www.acme.com"

=item created_at

The date and time the IP address was created

=item deleted_at

The date and time the IP address was deleted

=item status

The status of the IP address, for example [A]ctive or [D]eleted

=back

=cut
package Data::Address;
$VERSION = "1.0";

use strict;
use base 'Data::Object';
use Constants::AWS;
use Utils::Time;
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
    $class->fields(qw(account_id aws_public_ip name description created_at deleted_at status));

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

=item find_by_public_ip($public_ip)

Find an IP address in the database by its public IP (e.g. '75.101.151.221')

=cut
sub find_by_public_ip
{
    my ($self, $aws_public_ip) = @_;
    my $class = ref $self || $self;

    $class->connect();
    my $address = $class->select('aws_public_ip = ?', $aws_public_ip);
    #$class->disconnect();

    return $address;
}

=item soft_delete()

Update the IP address to have a "deleted_at" time and a status of [D]eleted

=cut
sub soft_delete
{
    my ($self) = @_;
    $self->{deleted_at} = Utils::Time->get_date_time();
    $self->{status} = Constants::AWS::STATUS_DELETED;
    $self->update();
}

}1;

=back

=head1 DEPENDENCIES

Data::Object, Constants::AWS, Utils::Time

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
