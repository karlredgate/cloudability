#!/usr/bin/env perl

=head1 NAME

Models::Customer - Manages service customers

=head1 VERSION

This document refers to version 1.0 of Models::Customer, released Nov 07, 2008

=head1 DESCRIPTION

Models::Customer manages the details for all service customers.
Be sure to call the class static method connect() before using Models::Customer
objects and disconnect() once you've finished.

=head2 Properties

=over 4

=item contact

The customer's main contact name

=item company

The customer's company name

=item street1

The customer's street address, line 1

=item street2

The customer's street address, line 2

=item city

The customer's city

=item country

The customer's country

=item zip_code

The customer's zip code

=item tel_number

The customer's contact telephone number

=item fax_number

The customer's contact facsimile number

=item tax_number

The customer's sales tax number (e.g. VAT number in Europe)

=item url

The customer's service URL

=item email

The customer's customer service email address

=item brand

The customer's service brand name

=item aws_account_num

The customer's AWS account number (typically "nnnn-nnnn-nnnn")

=item aws_cert_name

The customer's X.509 certificate file name (for bundling new images)

=item aws_cert_text

The customer's X.509 certificate file text (for bundling new images)

=item max_addresses

The maximum number of addresses this customer may allocate

=item max_instances

The maximum number of instances this customer may allocate

=item max_snapshots

The maximum number of snapshots this customer may allocate

=item max_volumes

The maximum number of volumes this customer may allocate

=back

=cut
package Models::Customer;
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
    $class->fields(qw(contact company street1 street2 city country zip_code tel_number fax_number tax_number url email brand aws_account_num aws_cert_name aws_cert_text max_addresses max_instances max_snapshots max_volumes));

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
