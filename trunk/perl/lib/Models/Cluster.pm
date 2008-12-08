#!/usr/bin/env perl

=head1 NAME

Models::Cluster - Manages the deployment of customer instances in clusters

=head1 VERSION

This document refers to version 1.0 of Models::Cluster, released Dec 07, 2008

=head1 DESCRIPTION

Models::Cluster manages the deployment of customer instances in clusters.
Be sure to call the class static method connect() before using Models::Cluster objects and disconnect() once you've finished.

=head2 Properties

=over 4

=item account_id

The account holder who created the cluster

=item deployment_id

The deployment ID which will be used to deploy the cluster

=item instances_max

The maximum numer of instances to run in the cluster

=item instances_min

The minimum number of instances to run in the cluster

=item run_hours_max

The maximum numer of hours to run any instance in the cluster

=item run_hours_min

The minimum number of hours to run any instance in the cluster

=item load_too_high

The load level at which to increase the number of running instances

=item load_too_low

The load level at which to terminate a running instance in the cluster

=item process_name

The name of the process to count (e.g. "apache" or "postfix")

=item proc_too_many

The process count at which to increase the number of running instances

=item proc_too_few

The process count at which to terminate a running instance in the cluster

=item pound_file

The Pound load balancer config file to use to run the cluster

=item name

A user-assigned name for the deployment, for example "Acme web server"

=item description

A user-assigned description for the deployment, for example "Site www.acme.com"

=item deleted_at

The date and time the cluster was deleted

=item status

The status of the deployment [A]ctive or [D]eleted

=back

=cut
package Models::Cluster;
$VERSION = "1.0";

use strict;
use base 'Models::Object';
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
    $class->fields(qw(account_id deployment_id instances_max instances_min run_hours_max run_hours_min load_too_high load_too_low process_name proc_too_many proc_too_few pound_file name description deleted_at status));

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

=item manage()

TODO: Manage a cluster

=cut
sub manage
{
    my ($self) = @_;

    # TODO
}

=item soft_delete()

Update the cluster to have a "deleted_at" time and a status of [D]eleted

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

Models::Object, Constants::AWS, Utils::Time

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
