#!/usr/bin/env perl

=head1 NAME

Clients::Admin::InstanceConfig - Perform admin actions on instance configs

=head1 VERSION

This document refers to version 1.0 of Clients::Admin::InstanceConfig, released Nov 28, 2008

=head1 DESCRIPTION

Clients::Admin::InstanceConfig performs admin actions on instance configs

=head2 Properties

=over 4

None

=back

=cut
package Clients::Admin::InstanceConfig;
$VERSION = "1.0";

use strict;
use base 'Clients::Admin';
use Data::InstanceConfig;
use Data::Instance; # to check account permissions
{
    # Class static properties

    # None

=head2 Class Methods

=over 4

=item new($self)

Create a new Clients::Admin::InstanceConfig object

=cut
sub new
{
    my ($class, $self) = @_;

    # Return the new Clients::Admin::InstanceConfig object

    bless $self, $class;
}

=back

=head2 Object Methods

=over 4

=item create($values)

Create an instance config

=cut
sub create
{
    my ($self, $values) = @_;
    my $account_id = $self->{account}{id};
    my $instance_id = $values->{instance_id} or die "need an instance ID";
    my $field = $values->{field} or die "need an instance config 'field'";
    my $value = $values->{value} ||= '';

    # Check that the account has permission to admin this instance

    $instance_id = $self->check_permission($account_id, $instance_id)
                                                or die "no permission";

    # Create a new instance config from the values, unless it already exists

    Data::InstanceConfig->connect();
    my $instance_config = Data::InstanceConfig->select('instance_id = ? and field = ?', $instance_id, $field);
    die "instance config already exists" if $instance_config->{id};
    $values->{instance_id} = $instance_id;
    $instance_config = new Data::InstanceConfig(%{$values});
    $instance_config->insert();
    Data::InstanceConfig->disconnect();

    # Return the new instance config ID and instance config, unblessed for JSON

    return { status => 'ok', id => $instance_config->{id}, instance_config => $instance_config->copy() };
}

=item select($values)

Select an instance config

=cut
sub select
{
    my ($self, $values) = @_;
    my $account_id = $self->{account}{id};
    my $instance_id = $values->{instance_id} or die "need an instance ID";
    my $field = $values->{field} || '%';

    # Check that the account has permission to admin this instance

    $instance_id = $self->check_permission($account_id, $instance_id)
                                                or die "no permission";

    # Get the instance config

    Data::InstanceConfig->connect();
    my @instance_configs = ();
    my $query = 'instance_id = ? and field like ?';
    for (my $instance_config = Data::InstanceConfig->select($query, $instance_id, $field);
            $instance_config->{id};
            $instance_config = Data::InstanceConfig->next($query))
    {
        push @instance_configs, $instance_config->copy(); # unbless for JSON
    }
    Data::InstanceConfig->disconnect();

    die "no matching instance configs" unless @instance_configs;

    return { status => 'ok', instance_configs => { instance_config => \@instance_configs } };
}

=item update($values)

Update a instance config

=cut
sub update
{
    my ($self, $values) = @_;
    my $account_id = $self->{account}{id};
    my $instance_id = $values->{instance_id} or die "need an instance ID";
    my $field = $values->{field} or die "need an instance config 'field'";
    my $value = $values->{value} || '';

    # Check that the account has permission to admin this instance

    $instance_id = $self->check_permission($account_id, $instance_id)
                                                or die "no permission";

    # Get the instance config to update

    Data::InstanceConfig->connect();
    my $instance_config = Data::InstanceConfig->select('instance_id = ? and field = ?', $instance_id, $field);
    die "no matching instance config" unless $instance_config->{id};

    # Update the instance config value

    $instance_config->{value} = $value;
    $instance_config->update();
    Data::InstanceConfig->disconnect();

    return { status => 'ok', instance_config => $instance_config->copy() }; # unbless for JSON
}

=item delete($values)

Delete an instance config

=cut
sub delete
{
    my ($self, $values) = @_;
    my $account_id = $self->{account}{id};
    my $instance_id = $values->{instance_id} or die "need an instance ID";

    # Check that the account has permission to admin this instance

    $instance_id = $self->check_permission($account_id, $instance_id)
                                                or die "no permission";

    # Get the instance config to delete

    Data::InstanceConfig->connect();
    my $instance_config = Data::InstanceConfig->select('instance_id = ?', $instance_id);
    die "no matching instance config" unless $instance_config->{id};

    # Delete the object

    $instance_config->delete();
    Data::InstanceConfig->disconnect();

    return { status => 'ok' };
}

=item check_permission($account_id, $instance_id)

Check whether an account has permission to admin an instance, and return its ID

=cut
sub check_permission
{
    my ($self, $account_id, $instance_id) = @_;

    # Find an instance matching both an account ID and an instance ID

    Data::Instance->connect();
    my $query = 'account_id = ? and '
              . ($instance_id =~ /^i/ ? 'aws_instance_id' : 'id') . ' = ?';
    my $instance = Data::Instance->select($query, $account_id, $instance_id);
    Data::Instance->disconnect();

    # Return the instance ID

    return $instance->{id};
}

}1;

=back

=head1 DEPENDENCIES

Data::InstanceConfig

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
