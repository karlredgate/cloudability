#!/usr/bin/env perl

=head1 NAME

Models::Account - Manages customer accounts

=head1 VERSION

This document refers to version 1.0 of Models::Account, released Nov 07, 2008

=head1 DESCRIPTION

Models::Account manages the details for all customer accounts.
Be sure to call the class static method connect() before using Models::Account
objects and disconnect() once you've finished.

=head2 Properties

=over 4

=item customer_id

The account's reseller

=item parent_id

The account's parent

=item status

The accounts status

=item start_date

The date the account was first signed up

=item end_date

The end date for the account's subscription

=item name

The account holder's name

=item email

The account holder's email address

=item phone

The account holder's phone number

=item username

The account holder's user name

=item password

The account holder's password

=item referrer

How the account holder came to know about the service

=item comments

Any comments about the account

=back

=cut
package Models::Account;
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
    $class->fields(qw(customer_id parent_id status start_date end_date name email phone username password referrer comments));

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
