#!/usr/bin/env perl

=head1 NAME

Data::CloudJob - Manages jobs to be run by the Server::CloudEngine

=head1 VERSION

This document refers to version 1.0 of Data::CloudJob, released Nov 29, 2008

=head1 DESCRIPTION

Data::CloudJob manages the details for jobs to be run by Server::CloudEngine.
Be sure to call the class static method connect() before using Data::CloudJob
objects and disconnect() once you've finished.

=head2 Properties

=over 4

=item priority

The job priority

=item command

The command to run

=item result

The command result

=item submit_time

The time the job was submitted

=item start_time

The time the job was started

=item finish_time

The time the job was finished

=item source_server

The server that created the job

=item target_server

The server that should run the job

=item status

The status of the job

=back

=cut
package Data::CloudJob;
$VERSION = "1.0";

use strict;
use base 'Data::Object';
use Constants::AWS;
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
    $class->fields(qw(id priority command result submit_time start_time finish_time source_server target_server status));

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

=item submit(command => $command, priority => $priority)

Submit a new cloud job

=cut
sub submit
{
    my ($class, %args) = @_;

    # Default the job details

    $args{command} or die "no job command provided";
    $args{priority} ||= Constants::AWS::DEFAULT_JOB_PRIORITY;
    $args{submit_time} ||= time();
    $args{status} ||= Constants::AWS::STATUS_ACTIVE;

    # Submit the new cloud job

    Data::CloudJob->connect();
    my $cloud_job = Data::CloudJob->new(%args);
    $cloud_job->insert();
    Data::CloudJob->disconnect();

    return $cloud_job;
}

=back

=head2 Object Methods

=over 4

=item None

=cut

}1;

=back

=head1 DEPENDENCIES

Data::Object, Constants::General

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
