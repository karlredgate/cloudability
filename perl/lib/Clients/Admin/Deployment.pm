#!/usr/bin/env perl

=head1 NAME

Clients::Admin::Deployment - Perform admin actions on deployments

=head1 VERSION

This document refers to version 1.0 of Clients::Admin::Deployment, released Dec 06, 2008

=head1 DESCRIPTION

Clients::Admin::Deployment performs admin actions on deployments

=head2 Properties

=over 4

None

=back

=cut
package Clients::Admin::Deployment;
$VERSION = "1.0";

use strict;
use base 'Clients::Admin';
use Constants::AWS;
use Models::Deployment;
{
    # Class static properties

    # None

=head2 Class Methods

=over 4

=item new($self)

Create a new Clients::Admin::Deployment object

=cut
sub new
{
    my ($class, $self) = @_;

    # Return the new Clients::Admin::Deployment object

    bless $self, $class;
}

=back

=head2 Object Methods

=over 4

=item create($values)

Create a deployment

=cut
sub create
{
    my ($self, $values) = @_;
    my $account_id = $self->{account}{id};

    # Create a new deployment from the values

    Models::Deployment->connect();
    $values->{account_id} = $account_id;
    my $deployment = Models::Deployment->new(%{$values});
    $deployment->insert();
    Models::Deployment->disconnect();

    # Return the new deployment ID and deployment, unblessed for JSON

    return { status => 'ok', id => $deployment->{id}, deployment => $deployment->copy() };
}

=item select($values)

Select a deployment

=cut
sub select
{
    my ($self, $values) = @_;
    my $account_id = $self->{account}{id};
    my $status = $values->{status} || Constants::AWS::STATUS_ACTIVE;

    # Get the deployment

    Models::Deployment->connect();
    my @deployments = ();
    my $query = 'account_id = ? and status = ?';
    for (my $deployment = Models::Deployment->select($query, $account_id, $status);
            $deployment->{id};
            $deployment = Models::Deployment->next($query))
    {
        push @deployments, $deployment->copy(); # unbless for JSON
    }
    Models::Deployment->disconnect();

    die "no matching deployments" unless @deployments;

    return { status => 'ok', deployments => { deployment => \@deployments } };
}

=item update($values)

Update a deployment

=cut
sub update
{
    my ($self, $values) = @_;
    my $account_id = $self->{account}{id};
    my $deployment_id = $values->{deployment_id} or die "need a deployment ID";

    # Get the deployment to update

    Models::Deployment->connect();
    my $deployment = Models::Deployment->select('account_id = ? and id = ?', $account_id, $deployment_id);
    die "no matching deployment" unless $deployment->{id};

    # Update the deployment

    $values->{account_id} = $account_id;
    foreach my $key (keys %{$values})
    {
        $deployment->{$key} = $values->{$key};
    }
    $deployment->update();
    Models::Deployment->disconnect();

    return { status => 'ok', deployment => $deployment->copy() }; # unbless for JSON
}

=item delete($values)

Delete a deployment

=cut
sub delete
{
    my ($self, $values) = @_;
    my $account_id = $self->{account}{id};
    my $deployment_id = $values->{deployment_id} or die "need a deployment ID";

    # Get the deployment to delete

    Models::Deployment->connect();
    my $deployment = Models::Deployment->select('account_id = ? and id = ?', $account_id, $deployment_id);
    die "no matching deployment " unless $deployment->{id};

    # Delete the object

    $deployment->soft_delete();
    Models::Deployment->disconnect();

    return { status => 'ok' };
}

}1;

=back

=head1 DEPENDENCIES

Constants::AWS, Models::Deployment

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
