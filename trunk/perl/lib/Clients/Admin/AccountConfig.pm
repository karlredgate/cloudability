#!/usr/bin/env perl

=head1 NAME

Clients::Admin::AccountConfig - Perform admin actions on account configs

=head1 VERSION

This document refers to version 1.0 of Clients::Admin::AccountConfig, released Nov 28, 2008

=head1 DESCRIPTION

Clients::Admin::AccountConfig performs admin actions on account configs

=head2 Properties

=over 4

None

=back

=cut
package Clients::Admin::AccountConfig;
$VERSION = "1.0";

use strict;
use base 'Clients::Admin';
use Models::AccountConfig;
{
    # Class static properties

    # None

=head2 Class Methods

=over 4

=item new($self)

Create a new Clients::Admin::AccountConfig object

=cut
sub new
{
    my ($class, $self) = @_;

    # Return the new Clients::Admin::AccountConfig object

    bless $self, $class;
}

=back

=head2 Object Methods

=over 4

=item create($values)

Create an account config

=cut
sub create
{
    my ($self, $values) = @_;
    my $account_id = $self->{account}{id};
    my $field = $values->{field} or die "need an account config 'field'";
    my $value = $values->{value} ||= '';

    # Create a new account config from the values, unless it already exists

    Models::AccountConfig->connect();
    my $account_config = Models::AccountConfig->select('account_id = ? and field = ?', $account_id, $field);
    die "account config already exists" if $account_config->{id};
    $values->{account_id} = $account_id;
    $account_config = Models::AccountConfig->new(%{$values});
    $account_config->insert();
    Models::AccountConfig->disconnect();

    # Return the new account config ID and account config unblessed for JSON

    return { status => 'ok', id => $account_config->{id}, account_config => $account_config->copy() };
}

=item select($values)

Select an account config

=cut
sub select
{
    my ($self, $values) = @_;
    my $account_id = $self->{account}{id};
    my $field = $values->{field} || '%';

    # Get the account config

    Models::AccountConfig->connect();
    my @account_configs = ();
    my $query = 'account_id = ? and field like ?';
    for (my $account_config = Models::AccountConfig->select($query, $account_id, $field);
            $account_config->{id};
            $account_config = Models::AccountConfig->next($query))
    {
        push @account_configs, $account_config->copy(); # unbless for JSON
    }
    Models::AccountConfig->disconnect();

    die "no matching account configs" unless @account_configs;

    return { status => 'ok', account_configs => { account_config => \@account_configs } };
}

=item update($values)

Update a account config

=cut
sub update
{
    my ($self, $values) = @_;
    my $account_id = $self->{account}{id};
    my $field = $values->{field} or die "need an account config 'field'";
    my $value = $values->{value} || '';

    # Get the account config to update

    Models::AccountConfig->connect();
    my $account_config = Models::AccountConfig->select('account_id = ? and field = ?', $account_id, $field);
    die "no matching account config" unless $account_config->{id};

    # Update the account config value

    $account_config->{value} = $value;
    $account_config->update();
    Models::AccountConfig->disconnect();

    return { status => 'ok', account_config => $account_config->copy() }; # unbless for JSON
}

=item delete($values)

Delete an account config

=cut
sub delete
{
    my ($self, $values) = @_;
    my $account_id = $self->{account}{id};

    # Get the account config to delete

    Models::AccountConfig->connect();
    my $account_config = Models::AccountConfig->select('account_id = ?', $account_id);
    die "no matching account config" unless $account_config->{id};

    # Delete the object

    $account_config->delete();
    Models::AccountConfig->disconnect();

    return { status => 'ok' };
}

}1;

=back

=head1 DEPENDENCIES

Models::AccountConfig

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
