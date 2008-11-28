#!/usr/bin/env perl

=head1 NAME

Data::Snapshot - Manages snapshots of volumes, to hold customer data securely

=head1 VERSION

This document refers to version 1.0 of Data::Snapshot, released Nov 28, 2008

=head1 DESCRIPTION

Data::Snapshot manages snapshots of volumes, to hold customer data securely.
Be sure to call the class static method connect() before using Data::Volume
objects and disconnect() once you've finished.

=head2 Properties

=over 4

=item account_id

The volume owner's account ID

=item aws_snapshot_id

The AWS snapshot ID, for example "snap-68719101"

=item aws_volume_id

The AWS volume ID, for example "vol-164ca97f"

=item aws_status

The AWS snapshot status, for example "completed"

=item aws_started_at

The time when the snapshot was taken

=item aws_progress

How much of the snapshot has been completed so far, for example "100%"

=back

=cut
package Data::Snapshot;
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
    $class->fields(qw(account_id aws_snapshot_id aws_volume_id aws_status aws_started_at aws_progress));

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

=item find_by_aws_snapshot_id($aws_snapshot_id)

Find a snapshot in the database by its AWS snapshot ID

=cut
sub find_by_aws_snapshot_id
{
    my ($self, $aws_snapshot_id) = @_;
    my $class = ref $self || $self;

    $class->connect();
    my $snapshot = $class->select('aws_snapshot_id = ?', $aws_snapshot_id);
    #$class->disconnect();

    return $snapshot;
}


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
