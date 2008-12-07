#!/usr/bin/env perl

=head1 NAME

Clients::Admin - Perform admin actions and return results as XML by default

=head1 VERSION

This document refers to version 1.0 of Clients::Admin, released Oct 20, 2008

=head1 DESCRIPTION

Clients::Admin performs admin actions and returns results as XML by default.

=head2 Properties

=over 4

None

=back

=cut
package Clients::Admin;
$VERSION = "1.0";

use strict;
use Models::Customer;
use Models::Account;
use XML::Simple;
use JSON;
{
    # Class static properties

    # None

=head2 Class Methods

=over 4

=item factory($account_id, $entity)

Create a new Clients::Admin subclassed object for a particular entity e.g. 'Account'

=cut
sub factory
{
    my ($class, $account_id, $entity) = @_;
    die "need an account id" unless $account_id =~ /^\d+$/;
    die "need an entity" unless $entity =~ /^\w+$/;

    # Get account details

    Models::Account->connect();
    my $account = Models::Account->select('id = ?', $account_id);
    Models::Account->disconnect();

    # Get customer details

    Models::Customer->connect();
    my $customer = Models::Customer->select('id = ?', $account->{customer_id});
    Models::Customer->disconnect();

    # Make a new Clients::Admin object

    my $self = {
        customer        => $customer,
        account         => $account,
        entity          => $entity,
    };

    # Subclass the object for the entity

    eval "require Clients::Admin::$entity;"; die $@ if $@;
    eval "\$self = Clients::Admin::$entity->new(\$self);";
    die $@ if $@;
    return $self;
}

=back

=head2 Object Methods

=over 4

=item perform(action => $action, entity => $entity, $values => $values, [format => $format])

Perform an admin action on an entity with particular values,
and return the results in a particular format, e.g. XML.

=cut
sub perform
{
    my ($self, %args) = @_;
    my $action  = lc $args{action} or die "no action specified";
    my $values  = $args{values} or die "no values specified";
    my $format  = lc $args{format} || 'xml';
    my $request = $args{request} || '';

    # Decode the values passed in JSON format

    $values = JSON->new()->jsonToObj($values);

    # Get the result of the action

    my $api = { admin => {
                    action  => $action,
                    entity  => $self->{entity},
                    values  => $values,
                    result  => { error => 'unknown entity or action' },
                },
              };

    # Check that the action is a legal method call

    eval {
        $api->{admin}{result} = $self->$action($values);
    } if $action =~ /^(create|select|update|delete)$/;

    # Report errors by extracting the messag, file and line number

    if ($@)
    {
        my $error = $@; chomp $error;
        my ($file, $line) = ($1, $2) if $error =~ s/ at (\/[\w\/\.]+) line (\d+).*$//;
        $api->{admin}{result} = { error => $error, file => $file, line => $line } if $@;
    }

    # Add the request stats

    $api->{stats} = {   request     => $request,
                        remote_addr => $ENV{HTTP_REMOTE_ADDR},
                        timestamp   => time() };

    # Format the details

    my $output = '';
    $output = $self->xml_result($api) if $format eq 'xml';
    $output = $self->csv_result($api) if $format eq 'csv';
    $output = $self->html_result($api) if $format eq 'html';
    $output = $self->json_result($api) if $format eq 'json';

    # Return the sites

    return $output;
}

=item xml_result($api)

Return a sites data structure formatted as XML

=cut
sub xml_result
{
    my ($self, $api) = @_;
    my $xml = new XML::Simple(RootName => 'api');
    return '<?xml version="1.0" encoding="UTF-8"?>' . "\n\n" . $xml->XMLout($api);
}

=item csv_result($api)

Return a sites data structure formatted as CSV

=cut
sub csv_result
{
    my ($self, $api) = @_;
    my $csv = '';

    # TODO

    return $csv;
}

=item html_result($api)

Return a sites data structure formatted as HTML

=cut
sub html_result
{
    my ($self, $api) = @_;
    my $html = '';

    # TODO

    return $html;
}

=item json_result($api)

Return a sites data structure formatted as JSON

=cut
sub json_result
{
    my ($self, $api) = @_;
    my $json = new JSON;
    return $json->objToJson($api);
}

}1;

=back

=head1 DEPENDENCIES

Models::Customer, Models::Account, XML::Simple, JSON

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
