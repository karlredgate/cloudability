#!/usr/bin/env perl

=head1 NAME

Clients::AWS -  Syncronize the Cloudability database with AWS information
                and run AWS commands to manage AWS resources (start/stop).

=head1 VERSION

This document refers to version 1.0 of Clients::AWS, released Nov 26, 2008

=head1 DESCRIPTION

Clients::AWS syncronizes the Cloudability database with AWS information
and runs AWS commands to manage AWS system resources (e.g. start/stop).

=head2 Properties

=over 4

None

=back

=cut
package Clients::AWS;
$VERSION = "1.0";

use strict;
use Constants::AWS;
use Data::Image;
use Data::Instance;
use Data::Snapshot;
use Data::Volume;
use Utils::LogFile;
{
    # Class static properties

    my $_AWS_CMD = '/usr/bin/aws';

=head2 Class Methods

=over 4

=item new([$aws_owner_id])

Create a new Clients::AWS object for an Amazon AWS owner ID (e.g. 992046831893)

=cut
sub new
{
    my ($class, $aws_owner_id) = @_;
    $aws_owner_id ||= $ENV{AWS_OWNER_ID};
    die "no AWS owner ID specified" unless $aws_owner_id;

    # Make a new Clients::AWS object

    my $self = {
        aws_owner_id    => $aws_owner_id,
        account_id      => 0, # see the command() method below
        log_file        => Utils::LogFile->new("$ENV{LOGS_DIR}/aws"),
    };

    # Return the new Clients::AWS object

    bless $self, $class;
}

=back

=head2 Object Methods

=over 4

=item command($cmd, [$account_id])

Run an AWS command and parse the results

=cut
sub command
{
    my ($self, $cmd, $account_id) = @_;
    die "bad command \"$cmd\"" if $cmd =~ /;&&|\||\`/;
    $self->{log_file}->info("Command $cmd");
    $self->{account_id} = $account_id || 0;

    my $objects = [];
    if ($cmd =~ /^(run|run-instances?|tin|terminate-instances?)/)
    {
        $objects = $self->parse_aws_command($cmd, 'instanceId');
        $self->sync_instances($objects);
    }
    elsif ($cmd =~ /^(csnap|create-snapshot)/)
    {
        $objects = $self->parse_aws_command($cmd, 'snapshotId');
        $self->sync_snapshots($objects);
    }
    elsif ($cmd =~ /^(delsnap|delete-snapshot)\s+(\S+)/)
    {
        system "$_AWS_CMD $cmd > /dev/null";
        my $snapshot = Data::Snapshot->find_by_aws_snapshot_id($2);
        $snapshot->soft_delete() if $snapshot->{id};
    }
    elsif ($cmd =~ /^(attvol|attach-volume|cvol|create-volume|detvol|detach-volume)/)
    {
        $objects = $self->parse_aws_command($cmd, 'volumeId');
        $self->sync_volumes($objects);
    }
    elsif ($cmd =~ /^(delvol|delete-volume)\s+(\S+)/)
    {
        system "$_AWS_CMD $cmd > /dev/null";
        my $volume = Data::Volume->find_by_aws_volume_id($2);
        $volume->soft_delete() if $volume->{id};
    }

    # Return the object list from a sync command

    return $objects;
}

=item syncronize()

Syncronize the Cloudability database with Amazon AWS information

=cut
sub syncronize
{
    my ($self) = @_;
    $self->{log_file}->info("Syncronizing images, instances, snapshots and volumes");

    my $images = $self->parse_aws_command('dim -o ' . $self->{aws_owner_id});
    $self->sync_images($images);

    my $instances = $self->parse_aws_command('din', 'instanceId');
    $self->sync_instances($instances);

    my $snapshots = $self->parse_aws_command('dsnap', 'snapshotId');
    $self->sync_snapshots($snapshots);

    my $volumes = $self->parse_aws_command('dvol', 'volumeId');
    $self->sync_volumes($volumes);
}

=item parse_aws_command($cmd, [$header])

Return a sites data structure formatted as JSON

=cut
sub parse_aws_command
{
    my ($self, $cmd, $header) = @_;

    open (AWS, "$_AWS_CMD $cmd|");
    my @data = grep /^[^+]/, <AWS>;
    close AWS;

    # Parse the first line as a header line always

    my $headers = shift @data;
    return if $headers =~ /^<\?xml/; #no rows
    my @headers = split /\s*\|\s*/, $headers;
    my @objects = ();
    foreach my $values (@data)
    {
        my @values = split /\s*\|\s*/, $values;

        # Some AWS commands return a variety of header line formats

        if ($header eq $values[1])
        {
            @headers = @values;
            next;
        }

        # Regular values so parse them against the last header line

        my $object = {};
        for (my $i = 1; $i < @headers; $i++)
        {
            my $aws_field = $headers[$i] or next;
            my $field = Constants::AWS::FIELDS->{$aws_field} or die "can't translate AWS field '$aws_field'";
            my $value = $values[$i];
            if ($field eq 'PARSE')
            {
                $self->parse_value($value, $object);
            }
            else
            {
                $object->{$field} = $value;
            }
        }
        push @objects, $object;
    }

    return \@objects;
}

=item parse_value($value, $object)

Parse a value made of "A=B C=D E=F" into new object values

=cut
sub parse_value
{
    my ($self, $value, $object) = @_;
    return unless $value;

    my @field_values = split /\s+/, $value;
    foreach my $field_value (@field_values)
    {
        my ($aws_field, $value) = split /=/, $field_value;
        my $field = Constants::AWS::FIELDS->{$aws_field} or die "can't translate AWS field '$aws_field' in '$field_value'";
        $object->{$field} = $value;
    }
}

=item copy_object($from, $to)

Copy object field values from one to another

=cut
sub copy_object
{
    my ($self, $from, $to) = @_;

    while (my ($field, $value) = each %{$from})
    {
        $to->{$field} = $value;
    }
}

=item sync_images($images)

Syncronize a list of images with the database

=cut
sub sync_images
{
    my ($self, $images) = @_;

    Data::Image->connect();
    foreach my $image (@{$images})
    {
        my $found = Data::Image->select('aws_image_id = ?', $image->{aws_image_id});
        if ($found->{id})
        {
            $self->copy_object($image, $found);
            $found->update();
        }
        else
        {
            Data::Image->new(%{$image})->insert();
        }
    }
    Data::Image->disconnect();
}

=item sync_instances($instances)

Syncronize a list of instances with the database

=cut
sub sync_instances
{
    my ($self, $instances) = @_;

    Data::Instance->connect();
    foreach my $instance (@{$instances})
    {
        $instance->{status} = Constants::AWS::STATES->{$instance->{aws_inst_state}} || Constants::AWS::STATUS_UNKNOWN;
        $instance->{aws_finished_at} = $1 if $instance->{aws_term_reason} =~ /\((.+) GMT\)/;
        $instance->{aws_public_dns} ||= '';
        $instance->{aws_private_dns} ||= '';
        my $found = Data::Instance->select('aws_instance_id = ?', $instance->{aws_instance_id});
        if ($found->{id})
        {
            # Initialize a host if it has just started running

            my $needs_to_init = 0;
            if ($instance->{status} eq Constants::AWS::STATUS_RUNNING
                && $found->{status} ne Constants::AWS::STATUS_RUNNING)
            {
                $needs_to_init = 1;
            }

            # Copy the instance state over to the found instance

            $self->copy_object($instance, $found);
            $found->update();
            $found->init_host() if $needs_to_init;
        }
        else
        {
            $instance->{account_id} = $self->{account_id} || 0;
            $found = Data::Instance->new(%{$instance});
            $found->insert();
        }

        # Make sure we know the instance's host for SSH commands

        $found->know_host();
    }
    Data::Instance->disconnect();
}

=item sync_snapshots($snapshots)

Syncronize a list of snapshots with the database

=cut
sub sync_snapshots
{
    my ($self, $snapshots) = @_;

    Data::Snapshot->connect();
    foreach my $snapshot (@{$snapshots})
    {
        my $found = Data::Snapshot->select('aws_snapshot_id = ?', $snapshot->{aws_snapshot_id});
        if ($found->{id})
        {
            $self->copy_object($snapshot, $found);
            $found->update();
        }
        else
        {
            my $volume = Data::Volume->find_by_aws_volume_id($snapshot->{aws_volume_id});
            $snapshot->{account_id} = $self->{account_id} || $volume->{account_id} || 0;
            $snapshot->{status} = Constants::AWS::STATUS_ACTIVE;
            Data::Snapshot->new(%{$snapshot})->insert();
        }
    }
    Data::Snapshot->disconnect();
}

=item sync_volumes($volumes)

Syncronize a list of volumes with the database

=cut
sub sync_volumes
{
    my ($self, $volumes) = @_;

    Data::Volume->connect();
    foreach my $volume (@{$volumes})
    {
        my $found = Data::Volume->select('aws_volume_id = ?', $volume->{aws_volume_id});
        if ($found->{id})
        {
            $self->copy_object($volume, $found);
            $found->update();
        }
        else
        {
            my $instance = Data::Instance->find_by_aws_instance_id($volume->{aws_instance_id});
            $volume->{account_id} = $self->{account_id} || $instance->{account_id} || 0;
            $volume->{status} = Constants::AWS::STATUS_ACTIVE;
            Data::Volume->new(%{$volume})->insert();
        }
    }
    Data::Volume->disconnect();
}

}1;

=back

=head1 DEPENDENCIES

Constants::AWS, Data::Image, Data::Instance, Data::Snapshot, Data::Volume, Utils::LogFile

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
