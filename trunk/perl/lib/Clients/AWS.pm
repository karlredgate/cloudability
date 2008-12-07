#!/usr/bin/env perl

=head1 NAME

Clients::AWS -  Synchronize the Cloudability database with AWS information
                and run AWS commands to manage AWS resources (start/stop).

=head1 VERSION

This document refers to version 1.0 of Clients::AWS, released Nov 26, 2008

=head1 DESCRIPTION

Clients::AWS synchronizes the Cloudability database with AWS information
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
use Clients::Quota;
use Models::Address;
use Models::Image;
use Models::Instance;
use Models::Snapshot;
use Models::Volume;
use Utils::Time;
use Utils::LogFile;
{
    # Class static properties

    my $_AWS_COMMAND = "$ENV{CLOUDABILITY_HOME}/bin/aws";
    my $_AWS_WRAPPER = "$ENV{CLOUDABILITY_HOME}/perl/aws.pl"; # for deploy files

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
        deployment_id   => 0, # see the command() method below
        log_file        => Utils::LogFile->new("$ENV{LOGS_DIR}/aws"),
    };

    # Return the new Clients::AWS object

    bless $self, $class;
}

=item set_aws_command($aws_command)

Set the AWS command, for example use a "mock" command for unit testing

=cut
sub set_aws_command
{
    my ($class, $aws_command) = @_;
    $_AWS_COMMAND = $aws_command;
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
    die "bad command \"$cmd\"" if $cmd =~ /;|&|\||`|>|</; # no ";&|`><" allowed
    $self->{log_file}->info("Command $cmd");
    $self->{account_id} = $account_id || 0;
    my $quota = Clients::Quota->new($account_id);

    my $objects = [];
    if ($cmd =~ /^(allad|allocate-address)/)
    {
        die "no address quota" unless $quota->address_quota();
        $objects = $self->parse_aws_command($cmd, 'publicIp');
        $self->check_for_error($objects);
        $self->sync_addresses($objects);
    }
    elsif ($cmd =~ /^(aad|associate-address|disad|disassociate-address)/)
    {
        $objects = $self->parse_aws_command($cmd);
        $self->check_for_error($objects);
        $objects = $self->parse_aws_command('din', 'instanceId'); # for new DNS
        $self->sync_instances($objects);
    }
    elsif ($cmd =~ /^(rad|release-address)\s+(\S+)/)
    {
        $objects = $self->parse_aws_command($cmd);
        $self->check_for_error($objects);
        my $address = Models::Address->find_by_public_ip($2);
        $address->soft_delete() if $address->{id};
    }
    elsif ($cmd =~ /^(run|run-instances?|tin|terminate-instances?)/)
    {
        if ($cmd =~ /^run/)
        {
            die "no instance quota" unless $quota->instance_quota() > 0;
        }
        $self->{deployment_id} = $1 if $cmd =~ /-d\s+(\S+)/;
        $objects = $self->parse_aws_command($cmd, 'instanceId');
        $self->check_for_error($objects);
        $self->sync_instances($objects);
    }
    elsif ($cmd =~ /^(csnap|create-snapshot)/)
    {
        die "no snapshot quota" unless $quota->snapshot_quota();
        $objects = $self->parse_aws_command($cmd, 'snapshotId');
        $self->check_for_error($objects);
        $self->sync_snapshots($objects);
    }
    elsif ($cmd =~ /^(delsnap|delete-snapshot)\s+(\S+)/)
    {
        $objects = $self->parse_aws_command($cmd, 'snapshotId');
        $self->check_for_error($objects);
        my $snapshot = Models::Snapshot->find_by_aws_snapshot_id($2);
        $snapshot->soft_delete() if $snapshot->{id};
    }
    elsif ($cmd =~ /^(attvol|attach-volume|cvol|create-volume|detvol|detach-volume)/)
    {
        if ($cmd =~ /^c/) # create volume
        {
            die "no volume quota" unless $quota->volume_quota();
        }
        $objects = $self->parse_aws_command($cmd, 'volumeId');
        $self->check_for_error($objects);
        $self->sync_volumes($objects);
    }
    elsif ($cmd =~ /^(delvol|delete-volume)\s+(\S+)/)
    {
        $objects = $self->parse_aws_command($cmd, 'volumeId');
        $self->check_for_error($objects);
        my $volume = Models::Volume->find_by_aws_volume_id($2);
        $volume->soft_delete() if $volume->{id};
    }
    else
    {
        $self->{log_file}->error("command \"$cmd\" could not be parsed");
        die "command \"$cmd\" could not be parsed";
    }

    # Return the object list from a sync command

    return $objects;
}

=item sync_with_aws()

Synchronize the Cloudability database with Amazon AWS information

=cut
sub sync_with_aws
{
    my ($self) = @_;
    $self->{log_file}->info("Synchronizing images, instances, snapshots and volumes");

    my $images = $self->parse_aws_command('dim -o ' . $self->{aws_owner_id});
    $self->sync_images($images);

    my $addresses = $self->parse_aws_command('dad', 'publicIp');
    $self->sync_addresses($addresses);

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
    $header ||= '';

    # Run the AWS command to read data from Amazon

    open (AWS, "$_AWS_COMMAND $cmd|");
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
                eval { $self->parse_value($value, $object); };
                $self->{log_file}->error("$aws_field: $@") if $@;
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

=item check_for_error($objects)

Check an object list to see if we've got an error message as the first object

=cut
sub check_for_error
{
    my ($self, $objects) = @_;
    my $error = $objects->[0] or return;
    if ($error->{error_code})
    {
        my $message = "$error->{error_code}: $error->{error_message}";
        $self->{log_file}->error($message);
        die "error $message";
    }
}

=item sync_images($images)

Synchronize a list of images with the database

=cut
sub sync_images
{
    my ($self, $images) = @_;

    Models::Image->connect();
    foreach my $image (@{$images})
    {
        $image->{aws_is_public} = $image->{aws_is_public} eq 'true' ? 'Y' : 'N';

        my $found = Models::Image->select('aws_image_id = ?', $image->{aws_image_id});
        if ($found->{id})
        {
            $self->copy_object($image, $found);
            $found->update();
        }
        else
        {
            Models::Image->new(%{$image})->insert();
        }
    }
    #Models::Image->disconnect();
}

=item sync_addresses($addresses)

Synchronize a list of addresses with the database

=cut
sub sync_addresses
{
    my ($self, $addresses) = @_;

    Models::Address->connect();
    foreach my $address (@{$addresses})
    {
        my $found = Models::Address->select('aws_public_ip = ?', $address->{aws_public_ip});
        if ($found->{id})
        {
            # Nothing to do - the only field is the public IP address
        }
        else
        {
            $address->{account_id} = $self->{account_id} || 0;
            $address->{created_at} = Utils::Time->get_date_time();
            $address->{status} = Constants::AWS::STATUS_ACTIVE;
            Models::Address->new(%{$address})->insert();
        }
    }
    #Models::Address->disconnect();
}

=item sync_instances($instances)

Synchronize a list of instances with the database

=cut
sub sync_instances
{
    my ($self, $instances) = @_;

    Models::Instance->connect();
    foreach my $instance (@{$instances})
    {
        $instance->{aws_inst_state} ||= 'unknown';
        $instance->{status} = Constants::AWS::STATES->{$instance->{aws_inst_state}};
        $instance->{aws_finished_at} = $1 if $instance->{aws_term_reason}
                       && $instance->{aws_term_reason} =~ /\((.+) GMT\)/;
        $instance->{aws_avail_zone} ||= '';
        $instance->{aws_public_dns} ||= '';
        $instance->{aws_private_dns} ||= '';
        my $found = Models::Instance->select('aws_instance_id = ?', $instance->{aws_instance_id});
        if ($found->{id})
        {
            # Deploy to a host if it has just started running

            my $needs_to_deploy = 0;
            if ($instance->{status} eq Constants::AWS::STATUS_RUNNING
                && $found->{status} ne Constants::AWS::STATUS_RUNNING)
            {
                $needs_to_deploy = 1;
            }

            # Copy the instance state over to the found instance

            $self->copy_object($instance, $found);
            $found->update();
            $found->deploy_to_host($_AWS_WRAPPER) if $needs_to_deploy;
        }
        else
        {
            $instance->{account_id} = $self->{account_id} || 0;
            $instance->{deployment_id} = $self->{deployment_id} || 0;
            $found = Models::Instance->new(%{$instance});
            $found->insert();
        }

        # Make sure we know the instance's host for SSH commands

        eval { $found->know_host(); };
        $self->{log_file}->warn("know_host: $@") if $@;
    }
    #Models::Instance->disconnect();
}

=item sync_snapshots($snapshots)

Synchronize a list of snapshots with the database

=cut
sub sync_snapshots
{
    my ($self, $snapshots) = @_;

    Models::Snapshot->connect();
    foreach my $snapshot (@{$snapshots})
    {
        my $found = Models::Snapshot->select('aws_snapshot_id = ?', $snapshot->{aws_snapshot_id});
        if ($found->{id})
        {
            $self->copy_object($snapshot, $found);
            $found->update();
        }
        else
        {
            my $volume = Models::Volume->find_by_aws_volume_id($snapshot->{aws_volume_id});
            $snapshot->{account_id} = $self->{account_id} || $volume->{account_id} || 0;
            $snapshot->{status} = Constants::AWS::STATUS_ACTIVE;
            Models::Snapshot->new(%{$snapshot})->insert();
        }
    }
    #Models::Snapshot->disconnect();
}

=item sync_volumes($volumes)

Synchronize a list of volumes with the database

=cut
sub sync_volumes
{
    my ($self, $volumes) = @_;

    Models::Volume->connect();
    foreach my $volume (@{$volumes})
    {
        my $found = Models::Volume->select('aws_volume_id = ?', $volume->{aws_volume_id});
        if ($found->{id})
        {
            $self->copy_object($volume, $found);
            $found->update();
        }
        else
        {
            my $instance = Models::Instance->find_by_aws_instance_id($volume->{aws_instance_id});
            $volume->{account_id} = $self->{account_id} || $instance->{account_id} || 0;
            $volume->{status} = Constants::AWS::STATUS_ACTIVE;
            Models::Volume->new(%{$volume})->insert();
        }
    }
    #Models::Volume->disconnect();
}

}1;

=back

=head1 DEPENDENCIES

Constants::AWS, Clients::Quota, Models::Image, Models::Instance, Models::Snapshot, Models::Volume, Utils::Time, Utils::LogFile

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
