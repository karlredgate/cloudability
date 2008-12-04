#!/usr/bin/env perl

=head1 NAME

Clients::Label - Label AWS resources and return results as XML by default

=head1 VERSION

This document refers to version 1.0 of Clients::Label, released Dec 03, 2008

=head1 DESCRIPTION

Clients::Label labels AWS resources and returns results as XML by default.

=head2 Properties

=over 4

None

=back

=cut
package Clients::Label;
$VERSION = "1.0";

use strict;
use Data::Address;
use Data::Instance;
use Data::Snapshot;
use Data::Volume;
use XML::Simple;
use JSON;
{
    # Class static properties

    # None

=head2 Class Methods

=over 4

=item new($account_id)

Create a new Clients::Label object

=cut
sub new
{
    my ($class, $account_id) = @_;
    die "need an account id" unless $account_id =~ /^\d+$/;

    # Make a new Clients::Admin object

    my $self = {
        account_id  => $account_id,
    };

    bless $self, $class;
}

=back

=head2 Object Methods

=over 4

=item set(entity => $entity, id => $id, name => $name, desc => $desc, [format => $format])

Set a name and description label on a particilar entity with an ID,
and return the results in a particular format, e.g. XML.

=cut
sub set
{
    my ($self, %args) = @_;
    my $entity  = $args{entity} or die "no entity specified";
    my $id      = $args{id} or die "no entity ID specified";
    my $name    = $args{name} or die "no label name specified";
    my $desc    = $args{desc} or die "no label description specified";
    my $format  = lc $args{format} || 'xml';
    my $request = $args{request} || '';

    # Get the result of the updating the name and description

    my $label = { update => {
                    entity      => $entity,
                    id          => $id,
                    name        => $name,
                    description => $desc,
                    result  => { error => 'unknown entity or action' },
                },
              };

    # Apply the label to the entity with the specified ID

    $entity = lc $entity; $id = lc $id;
    eval {
        my $obj;
        $obj = $self->label('Data::Address', 'aws_public_ip', $id, $name, $desc)
                                                    if $entity eq 'address';

        $obj = $self->label('Data::Instance', 'aws_instance_id', $id, $name, $desc)
                                                    if $entity eq 'instance';

        $obj = $self->label('Data::Snapshot', 'aws_snapshot_id', $id, $name, $desc)
                                                    if $entity eq 'snapshot';

        $obj = $self->label('Data::Volume', 'aws_volume_id', $id, $name, $desc)
                                                    if $entity eq 'volume';

        $label->{update}{result} = { status => 'ok', $entity => $obj } if $obj;
    };

    # Report errors by extracting the messag, file and line number

    if ($@)
    {
        my $error = $@; chomp $error;
        my ($file, $line) = ($1, $2) if $error =~ s/ at (\/[\w\/\.]+) line (\d+).*$//;
        $label->{update}{result} = { error => $error, file => $file, line => $line } if $@;
    }

    # Add the request stats

    $label->{stats} = { request     => $request,
                        remote_addr => $ENV{HTTP_REMOTE_ADDR},
                        timestamp   => time() };

    # Format the details

    my $output = '';
    $output = $self->xml_result($label) if $format eq 'xml';
    $output = $self->csv_result($label) if $format eq 'csv';
    $output = $self->html_result($label) if $format eq 'html';
    $output = $self->json_result($label) if $format eq 'json';

    # Return the sites

    return $output;
}

=item label($klass, $id_field, $id, $name, $desc)

Set a name and description label on an AWS resource object found with an ID

=cut
sub label
{
    my ($self, $klass, $id_field, $id, $name, $desc) = @_;

    # Use either a numeric ID or an AWS ID to be more user-friendly

    $klass->connect();
    my $object = $id =~ /^\d+$/ ? $klass->row($id)
                                : $klass->select("$id_field = ?", $id);
    $klass->disconnect();

    die "cannot find ID $id" unless $object->{id};

    $object->{name} = $name;
    $object->{description} = $desc;
    $object->update();

    return $object->copy(); # unbless for JSON
}

=item xml_result($label)

Return a sites data structure formatted as XML

=cut
sub xml_result
{
    my ($self, $label) = @_;
    my $xml = new XML::Simple(RootName => 'label');
    return '<?xml version="1.0" encoding="UTF-8"?>' . "\n\n" . $xml->XMLout($label);
}

=item csv_result($label)

Return a sites data structure formatted as CSV

=cut
sub csv_result
{
    my ($self, $label) = @_;
    my $csv = '';

    # TODO

    return $csv;
}

=item html_result($label)

Return a sites data structure formatted as HTML

=cut
sub html_result
{
    my ($self, $label) = @_;
    my $html = '';

    # TODO

    return $html;
}

=item json_result($label)

Return a sites data structure formatted as JSON

=cut
sub json_result
{
    my ($self, $label) = @_;
    my $json = new JSON;
    return $json->objToJson($label);
}

}1;

=back

=head1 DEPENDENCIES

Data::Address, Data::Instance, Data::Snapshot, Data::Volume, XML::Simple, JSON

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
