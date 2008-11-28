#!/usr/bin/env perl

=head1 NAME

Data::InstanceConfig - Manages the configuration options of customer instances

=head1 VERSION

This document refers to version 1.0 of Data::InstanceConfig, released Nov 28, 2008

=head1 DESCRIPTION

Data::InstanceConfig manages the configuration options of all customer instances.
Be sure to call the class static method connect() before using Data::InstanceConfig objects and disconnect() once you've finished.

=head2 Properties

=over 4

=item instance_id

The instance being configured

=item field

The configuration field

=item value

The configuration value

=back

=cut
package Data::InstanceConfig;
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
    $class->fields(qw(instance_id field value));

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

=item get($instance_id)

Get an instance configuration as a hash ref of fields and values

=cut
sub get
{
    my ($class, $instance_id) = @_;
    die "no instance" unless $instance_id;

    my $sql = 'instance_id = ?';
    my $config = [];
    for (my $instance_config = $class->select($sql, $instance_id);
        $instance_config->{id};
        $instance_config = $class->next($sql))
    {
        my $field = $instance_config->{field};
        my $value = $instance_config->{value};
        $config->{$field} = $value;
    }

    return $config;
}

=item set($instance_id, $field, $value)

Set a configuration field value for an instance

=cut
sub set
{
    my ($class, $instance_id, $field, $value) = @_;

    my $sql = 'instance_id = ? and field = ?';
    my $instance_config = $class->select($sql, $instance_id, $field);
    if ($instance_config->{id})
    {
        if ($value)
        {
            $instance_config->{value} = $value;
            $instance_config->update();
        }
        else
        {
            $instance_config->delete();
        }
    }
    else
    {
        $instance_config->{instance_id} = $instance_id;
        $instance_config->{field} = $field;
        $instance_config->{value} = $value;
        $instance_config->insert();
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
