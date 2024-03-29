#!/usr/bin/env perl

=head1 NAME

Models::AccountConfig - Manages the configuration options of customer accounts

=head1 VERSION

This document refers to version 1.0 of Models::AccountConfig, released Nov 07, 2008

=head1 DESCRIPTION

Models::AccountConfig manages the configuration options of all customer accounts.
Be sure to call the class static method connect() before using Models::AccountConfig objects and disconnect() once you've finished.

=head2 Properties

=over 4

=item account_id

The account being configured

=item field

The configuration field

=item value

The configuration value

=back

=cut
package Models::AccountConfig;
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
    $class->fields(qw(account_id field value));

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

=item get($account_id)

Get an account configuration as a hash ref of fields and values

=cut
sub get
{
    my ($class, $account_id) = @_;
    die "no account" unless $account_id;

    my $sql = 'account_id = ?';
    my $config = {};
    for (my $account_config = $class->select($sql, $account_id);
        $account_config->{id};
        $account_config = $class->next($sql))
    {
        my $field = $account_config->{field};
        my $value = $account_config->{value};
        $config->{$field} = $value;
    }

    return $config;
}

=item set($account_id, $field, $value)

Set a configuration field value for an account

=cut
sub set
{
    my ($class, $account_id, $field, $value) = @_;

    my $sql = 'account_id = ? and field = ?';
    my $account_config = $class->select($sql, $account_id, $field);
    if ($account_config->{id})
    {
        if ($value)
        {
            $account_config->{value} = $value;
            $account_config->update();
        }
        else
        {
            $account_config->delete();
        }
    }
    else
    {
        $account_config->{account_id} = $account_id;
        $account_config->{field} = $field;
        $account_config->{value} = $value;
        $account_config->insert();
    }
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
