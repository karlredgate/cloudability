#!/usr/bin/env perl

=head1 NAME

Clients::Admin::Cluster - Perform admin actions on clusters

=head1 VERSION

This document refers to version 1.0 of Clients::Admin::Cluster, released Dec 06, 2008

=head1 DESCRIPTION

Clients::Admin::Cluster performs admin actions on clusters

=head2 Properties

=over 4

None

=back

=cut
package Clients::Admin::Cluster;
$VERSION = "1.0";

use strict;
use base 'Clients::Admin';
use Constants::AWS;
use Models::Cluster;
{
    # Class static properties

    # None

=head2 Class Methods

=over 4

=item new($self)

Create a new Clients::Admin::Cluster object

=cut
sub new
{
    my ($class, $self) = @_;

    # Return the new Clients::Admin::Cluster object

    bless $self, $class;
}

=back

=head2 Object Methods

=over 4

=item create($values)

Create a cluster

=cut
sub create
{
    my ($self, $values) = @_;
    my $account_id = $self->{account}{id};

    # Create a new cluster from the values

    Models::Cluster->connect();
    $values->{account_id} = $account_id;
    my $cluster = Models::Cluster->new(%{$values});
    $cluster->insert();
    Models::Cluster->disconnect();

    # Return the new cluster ID and cluster, unblessed for JSON

    return { status => 'ok', id => $cluster->{id}, cluster => $cluster->copy() };
}

=item select($values)

Select a cluster

=cut
sub select
{
    my ($self, $values) = @_;
    my $account_id = $self->{account}{id};
    my $status = $values->{status} || Constants::AWS::STATUS_ACTIVE;

    # Get the cluster

    Models::Cluster->connect();
    my @clusters = ();
    my $query = 'account_id = ? and status = ?';
    for (my $cluster = Models::Cluster->select($query, $account_id, $status);
            $cluster->{id};
            $cluster = Models::Cluster->next($query))
    {
        push @clusters, $cluster->copy(); # unbless for JSON
    }
    Models::Cluster->disconnect();

    die "no matching clusters" unless @clusters;

    return { status => 'ok', clusters => { cluster => \@clusters } };
}

=item update($values)

Update a cluster

=cut
sub update
{
    my ($self, $values) = @_;
    my $account_id = $self->{account}{id};
    my $cluster_id = $values->{cluster_id} or die "need a cluster ID";

    # Get the cluster to update

    Models::Cluster->connect();
    my $cluster = Models::Cluster->select('account_id = ? and id = ?', $account_id, $cluster_id);
    die "no matching cluster" unless $cluster->{id};

    # Update the cluster

    $values->{account_id} = $account_id;
    foreach my $key (keys %{$values})
    {
        $cluster->{$key} = $values->{$key};
    }
    $cluster->update();
    Models::Cluster->disconnect();

    return { status => 'ok', cluster => $cluster->copy() }; # unbless for JSON
}

=item delete($values)

Delete a cluster

=cut
sub delete
{
    my ($self, $values) = @_;
    my $account_id = $self->{account}{id};
    my $cluster_id = $values->{cluster_id} or die "need a cluster ID";

    # Get the cluster to delete

    Models::Cluster->connect();
    my $cluster = Models::Cluster->select('account_id = ? and id = ?', $account_id, $cluster_id);
    die "no matching cluster " unless $cluster->{id};

    # Delete the object

    $cluster->soft_delete();
    Models::Cluster->disconnect();

    return { status => 'ok' };
}

}1;

=back

=head1 DEPENDENCIES

Constants::AWS, Models::Cluster

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
