#!/usr/bin/env perl

=head1 NAME

Clients::Quota - Check allocated resources against a customer's resource quota

=head1 VERSION

This document refers to version 1.0 of Clients::Quota, released Dec 02, 2008

=head1 DESCRIPTION

Clients::Quota checks allocated resources against a customer's resource quota.

=head2 Properties

=over 4

None

=back

=cut
package Clients::Quota;
$VERSION = "1.0";

use strict;
use Constants::AWS;
use Models::Customer;
use Models::Account;
use Models::Address;
use Models::Instance;
use Models::Snapshot;
use Models::Volume;
{
    # Class static properties

    # None

=head2 Class Methods

=over 4

=item new($account_id)

Create a new Clients::Quota object for an account ID

=cut
sub new
{
    my ($class, $account_id) = @_;

    # Get account details

    Models::Account->connect();
    my $account = Models::Account->select('id = ?', $account_id);
    die "no account with ID $account_id" unless $account->{id};

    # Get customer details

    Models::Customer->connect();
    my $customer = Models::Customer->select('id = ?', $account->{customer_id});
    die "no customer with ID $account->{customer_id}" unless $customer->{id};

    # Get the IDs of all customer accounts

    my @account_ids;
    my $query = 'customer_id = ?';
    for (my $account = Models::Account->select($query, $customer->{id});
            $account->{id};
            $account = Models::Account->next($query))
    {
        push @account_ids, $account->{id};
    }
    die "no customer accounts" unless @account_ids;

    # Make a new Clients::Quota object

    my $self = {
        customer        => $customer,
        account_ids     => \@account_ids,
        max_addresses   => $customer->{max_addresses} || Constants::AWS::MAX_ADDRESSES,
        max_instances   => $customer->{max_instances} || Constants::AWS::MAX_INSTANCES,
        max_snapshots   => $customer->{max_snapshots} || Constants::AWS::MAX_SNAPSHOTS,
        max_volumes     => $customer->{max_volumes} || Constants::AWS::MAX_VOLUMES,
    };

    # Return the new Clients::Quota object

    bless $self, $class;
}

=back

=head2 Object Methods

=over 4

=item get_query()

Return a query like "account_id in (1, 2, 3)" by reading the account_ids list

=cut
sub get_query
{
    my ($self) = @_;
    my $account_ids = join ", ", @{$self->{account_ids}};
    return "account_id in ($account_ids)";
}

=item address_quota()

Return the number of addresses remaining in our quota

=cut
sub address_quota
{
    my ($self) = @_;

    my $has_addresses = 0;
    Models::Address->connect();
    my $query = $self->get_query();
    for (my $address = Models::Address->select($query);
            $address->{id};
            $address = Models::Address->next($query))
    {
        $has_addresses++ if $address->{status} eq Constants::AWS::STATUS_ACTIVE;
    }
    return $self->{max_addresses} - $has_addresses;
}

=item instance_quota()

Return the number of instances remaining in our quota

=cut
sub instance_quota
{
    my ($self) = @_;

    my $has_instances = 0;
    Models::Instance->connect();
    my $query = $self->get_query();
    for (my $instance = Models::Instance->select($query);
            $instance->{id};
            $instance = Models::Instance->next($query))
    {
        $has_instances++ if $instance->{status} eq Constants::AWS::STATUS_RUNNING;
    }
    return $self->{max_instances} - $has_instances;
}

=item snapshot_quota()

Return the number of snapshots remaining in our quota

=cut
sub snapshot_quota
{
    my ($self) = @_;

    my $has_snapshots = 0;
    Models::Snapshot->connect();
    my $query = $self->get_query();
    for (my $snapshot = Models::Snapshot->select($query);
            $snapshot->{id};
            $snapshot = Models::Snapshot->next($query))
    {
        $has_snapshots++ if $snapshot->{status} eq Constants::AWS::STATUS_ACTIVE;
    }
    return $self->{max_snapshots} - $has_snapshots;
}

=item volume_quota()

Return the number of volumes remaining in our quota

=cut
sub volume_quota
{
    my ($self) = @_;

    my $has_volumes = 0;
    Models::Volume->connect();
    my $query = $self->get_query();
    for (my $volume = Models::Volume->select($query);
            $volume->{id};
            $volume = Models::Volume->next($query))
    {
        $has_volumes++ if $volume->{status} eq Constants::AWS::STATUS_ACTIVE;
    }
    return $self->{max_volumes} - $has_volumes;
}

}1;

=back

=head1 DEPENDENCIES

Constants::AWS, Models::Customer, Models::Account, Models::Address, Models::Instance, Models::Snapshot, Models::Volume

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
