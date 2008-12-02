#!/usr/bin/env perl

=head1 NAME

Clients::AWS::API - Provide an API to AWS to run commands and get data

=head1 VERSION

This document refers to version 1.0 of Clients::AWS::API, released Nov 29, 2008

=head1 DESCRIPTION

Clients::AWS::API provides an API to AWS to run commands and get data.

=head2 Properties

=over 4

None

=back

=cut
package Clients::AWS::API;
$VERSION = "1.0";

use strict;
use base 'Clients::AWS';
use Data::CloudJob;
use Data::Customer;
use Data::Image;
use Data::Instance;
use Data::Volume;
use Data::Snapshot;
use XML::Simple;
use JSON;
{
    # Class static properties

    # None

=head2 Class Methods

=over 4

=item new([$aws_owner_id])

Create a new Clients::AWS::API object

=cut
sub new
{
    my ($class, $aws_owner_id) = @_;

    # Make a new Clients::AWS::API object

    my $self = $class->SUPER::new($aws_owner_id);

    # Return the new Clients::AWS::API object

    bless $self, $class;
}

=back

=head2 Object Methods

=over 4

=item command(command => $command, request => $request, format => $format)

Run an AWS command and parse the results

=cut
sub command
{
    my ($self, %args) = @_;
    my $command = $args{command} or die "no command";
    my $account = $args{account} or die "no account";

    my $objects;
    if ($command =~ /^(dim|describe-images|din|describe-instances|dsnap|describe-snapshots|dvol|describe-volumes)/)
    {
        # Get resource data from the sync database

        $objects = $self->describe_images($account) if $command =~ /^(dim|describe-images)/;
        $objects = $self->describe_instances($account) if $command =~ /^(din|describe-instances)/;
        $objects = $self->describe_snapshots($account) if $command =~ /^(dsnap|describe-snapshots)/;
        $objects = $self->describe_volumes($account) if $command =~ /^(dvol|describe-volumes)/;
    }
    else
    {
        # Submit a cloud job for processing ASAP

        my $job = Data::CloudJob->submit(command => "$ENV{CLOUDABILITY_HOME}/perl/aws.pl $account->{id} $command");
        $self->{object_type} = 'job';
        $objects = [ $job ];
    }

    $args{objects} = $objects;
    return $self->format(%args);
}

=item format(command => $command, request => $request, format => $format, objects => $objects)

Format some command output according the the chosen format parameter, e.g. "XML"

=cut
sub format
{
    my ($self, %args) = @_;
    my $format = $args{format} || 'xml';
    my $request = $args{request} || '';
    my $command = $args{command};
    my $objects = $args{objects};
    my $object_type = $self->{object_type} || 'object';

    my $aws = {
        "${object_type}s" => { $object_type => $objects },
        stats => { request     => $request,
                   command     => $command,
                   remote_addr => $ENV{HTTP_REMOTE_ADDR},
                   timestamp   => time() }
    };

    if ($format eq 'xml')
    {
        my $xml = new XML::Simple(RootName => 'aws');
        return $xml->XMLout($aws);
    }
    elsif ($format eq 'csv')
    {
        # TODO
    }
    elsif ($format eq 'html')
    {
        # TODO
    }
    elsif ($format eq 'json')
    {
        my $json = new JSON;
        return $json->objToJson($aws);
    }
}

=item describe_images($account)

Return a list of image objects in our database sync of Amazon AWS resources

=cut
sub describe_images
{
    my ($self, $account) = @_;
    $self->{object_type} = 'image';

    my @images;
    Data::Image->connect();
    for (my $image = Data::Image->select();
            $image->{id};
            $image = Data::Image->next())
    {
        push @images, $image;
    }
    Data::Image->disconnect();

    return \@images;
}

=item describe_instances($account)

Return a list of instance objects in our database sync of Amazon AWS resources

=cut
sub describe_instances
{
    my ($self, $account) = @_;
    $self->{object_type} = 'instance';

    my @instances;
    Data::Instance->connect();
    my $query = 'account_id = ?';
    for (my $instance = Data::Instance->select($query, $account->{id});
            $instance->{id};
            $instance = Data::Instance->next($query))
    {
        push @instances, $instance;
    }
    Data::Instance->disconnect();

    return \@instances;
}

=item describe_snapshots($account)

Return a list of snapshot objects in our database sync of Amazon AWS resources

=cut
sub describe_snapshots
{
    my ($self, $account) = @_;
    $self->{object_type} = 'snapshot';

    my @snapshots;
    Data::Snapshot->connect();
    my $query = 'account_id = ?';
    for (my $snapshot = Data::Snapshot->select($query, $account->{id});
            $snapshot->{id};
            $snapshot = Data::Snapshot->next($query))
    {
        push @snapshots, $snapshot;
    }
    Data::Snapshot->disconnect();

    return \@snapshots;
}

=item describe_volumes($account)

Return a list of volume objects in our database sync of Amazon AWS resources

=cut
sub describe_volumes
{
    my ($self, $account) = @_;
    $self->{object_type} = 'volume';

    my @volumes;
    Data::Volume->connect();
    my $query = 'account_id = ?';
    for (my $volume = Data::Volume->select($query, $account->{id});
            $volume->{id};
            $volume = Data::Volume->next($query))
    {
        push @volumes, $volume;
    }
    Data::Volume->disconnect();

    return \@volumes;
}

}1;

=back

=head1 DEPENDENCIES

Clients::AWS, Data::CloudJob, Data::Customer, Data::Image, Data::Instance, Data::Snapshot, Data::Volume, XML::Simple, JSON

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