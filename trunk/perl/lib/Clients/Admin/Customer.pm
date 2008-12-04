#!/usr/bin/env perl

=head1 NAME

Clients::Admin::Customer - Perform admin actions on customers

=head1 VERSION

This document refers to version 1.0 of Clients::Admin::Customer, released Nov 29, 2008

=head1 DESCRIPTION

Clients::Admin::Customer performs admin actions on customers

=head2 Properties

=over 4

None

=back

=cut
package Clients::Admin::Customer;
$VERSION = "1.0";

use strict;
use base 'Clients::Admin';
use Data::Customer;
{
    # Class static properties

    # None

=head2 Class Methods

=over 4

=item new($self)

Create a new Clients::Admin::Customer object

=cut
sub new
{
    my ($class, $self) = @_;

    # Return the new Clients::Admin::Customer object

    bless $self, $class;
}

=back

=head2 Object Methods

=over 4

=item create($values)

Create a customer

=cut
sub create
{
    my ($self, $values) = @_;
    my $company = $values->{company} or die "no company name";

    # Check that the customer has not already been added

    Data::Customer->connect();
    my $customer = Data::Customer->select('company = ?', $company);
    die "customer already exists with name $company" if $customer->{id};

    # Create a new customer from the values, but use defaults

    $customer = Data::Customer->new(%{$values});

    # Insert the new customer

    $customer->insert();
    $customer = Data::Customer->row($customer->{id}); # get missing fields
    Data::Customer->disconnect();

    # Return the new customer ID and customer, unblessed for JSON

    return { status => 'ok', id => $customer->{id}, customer => $customer->copy() };
}

=item select($values)

Select a customer

=cut
sub select
{
    my ($self, $values) = @_;

    # Get a matching customer

    Data::Customer->connect();
    my $customer = $self->get_customer($values);
    Data::Customer->disconnect();

    return { status => 'ok', customer => $customer->copy() }; # unbless for JSON
}

=item update($values)

Update a customer

=cut
sub update
{
    my ($self, $values) = @_;

    # Get a matching customer

    Data::Customer->connect();
    my $customer = $self->get_customer($values);

    # Update the customer

    foreach my $key (keys %{$values})
    {
        $customer->{$key} = $values->{$key};
    }
    $customer->update();
    Data::Customer->disconnect();

    return { status => 'ok', customer => $customer->copy() }; # unbless for JSON
}

=item delete($values)

Delete a customer

=cut
sub delete
{
    my ($self, $values) = @_;

    # Get a matching customer

    Data::Customer->connect();
    my $customer = $self->get_customer($values);

    # Delete the object

    $customer->delete();
    Data::Customer->disconnect();

    return { status => 'ok' };
}

=item get_customer($values)

Get a customer matching an "id" or "company" value, belonging to this customer

=cut
sub get_customer
{
    my ($self, $values) =  @_;
    my $customer_id = $values->{id} || 0;
    my $company = $values->{company};
    die "need a customer id or company" unless $customer_id or $company;

    # Get the matching customer

    my $customer = $customer_id ? Data::Customer->row($customer_id)
                                : Data::Customer->select('company like ?', $company);
    die "no matching customer" unless $customer->{id};

    # Check the customer ID for permission

    die "no permission" if $customer->{id} != $self->{customer}{id}
                        && $self->{account}{id} != 1; # Account 1 is the admin

    # Return the customer

    return $customer;
}

}1;

=back

=head1 DEPENDENCIES

Data::Customer

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
