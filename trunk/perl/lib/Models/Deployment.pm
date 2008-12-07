#!/usr/bin/env perl

=head1 NAME

Models::Deployment - Manages the deployment of customer instances

=head1 VERSION

This document refers to version 1.0 of Models::Deployment, released Nov 28, 2008

=head1 DESCRIPTION

Models::Deployment manages the deployment of customer instances.
Be sure to call the class static method connect() before using Models::Deployment objects and disconnect() once you've finished.

=head2 Properties

=over 4

=item account_id

The account holder who created the deployment

=item deploy_file

The deployment script file to use when deploying

=item name

A user-assigned name for the deployment, for example "Acme web server"

=item description

A user-assigned description for the deployment, for example "Site www.acme.com"

=item status

The status of the deployment [A]ctive or [D]eleted

=back

=cut
package Models::Deployment;
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
    $class->fields(qw(account_id deploy_file is_elasic name description status));

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
