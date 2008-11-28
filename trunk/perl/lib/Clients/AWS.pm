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
use Data::Volume;
{
    # Class static properties

    my $_AWS_CMD = '/usr/bin/aws';

=head2 Class Methods

=over 4

=item new($aws_owner_id)

Create a new Clients::AWS object for an Amazon AWS owner ID (e.g. 992046831893)

=cut
sub new
{
    my ($class, $aws_owner_id) = @_;
    $aws_owner_id ||= $ENV{AWS_OWNER_ID};
    die "no AWS owner ID specified" unless $aws_owner_id;

    # Make a new Clients::AWS object

    my $self = {
        aws_owner_id => $aws_owner_id,
    };

    # Return the new Clients::AWS object

    bless $self, $class;
}

=back

=head2 Object Methods

=over 4

=item command()

Run an AWS command and parse the results

=cut
sub command
{
    my ($self, $cmd) = @_;
    die "bad command \"$cmd\"" if $cmd =~ /;&&|\||\`/;

    if ($cmd =~ /^(run|run-instances?|tin|terminate-instances?)/)
    {
        my $instances = $self->parse_aws_command($cmd, 'instanceId');
        $self->sync_instances($instances);
    }
}

=item syncronize()

Syncronize the Cloudability database with Amazon AWS information

=cut
sub syncronize
{
    my ($self) = @_;

    my $images = $self->parse_aws_command('dim -o ' . $self->{aws_owner_id});
    $self->sync_images($images);

    my $instances = $self->parse_aws_command('din', 'instanceId');
    $self->sync_instances($instances);

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
            $self->copy_object($instance, $found);
            $found->update();
        }
        else
        {
            $instance->{account_id} ||= 0;
            $found = Data::Instance->new(%{$instance});
            $found->insert();
        }

        # Make sure we know the instance's host for SSH commands

        $found->know_host();
    }
    Data::Instance->disconnect();
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
            $volume->{account_id} = $instance->{account_id} || 0;
            Data::Volume->new(%{$volume})->insert();
        }
    }
    Data::Volume->disconnect();
}

}1;

=back

=head1 DEPENDENCIES

Data::Image, Data::Instance, Data::Volume

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
