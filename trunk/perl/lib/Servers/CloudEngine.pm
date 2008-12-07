#!/usr/bin/env perl

=head1 NAME

Servers::CloudEngine - Assign/run cloud jobs on this server, returning status

=head1 VERSION

This document refers to version 1.0 of Servers::CloudEngine, released Nov 29, 2008

=head1 DESCRIPTION

Servers::CloudEngine assigns/runs jobs on this local server, returning status

=head2 Properties

=over 4

None

=back

=cut
package Servers::CloudEngine;
$VERSION = "1.0";

use strict;
use Models::CloudJob;
use Utils::LogFile;
use IO::Socket;
{
    # Class static properties

    use constant SECS_TO_SLEEP => 10;   # how long to wait before finding jobs
    use constant LOAD_TOO_HIGH => 1.0;  # don't run jobs when we're overloaded
    use constant JOBS_TO_START => 5;    # how many jobs to initiate at a time
    use constant PRIORITY_BIAS => 100;  # multiples of the priority in seconds

    # Get the local IP address

    $ENV{HOST_IP} = inet_ntoa(inet_aton($ENV{HOSTNAME}));

=head2 Class Methods

=over 4

=item new()

Create a new Servers::CloudEngine object

=cut
sub new
{
    my ($class) = @_;

    my $self = {
        log_file => Utils::LogFile->new("$ENV{LOGS_DIR}/cloudengine"),
    };
    $self->{log_file}->alert("Created");

    bless $self, $class;
}

=item load_avg()

Get the local server's load average

=cut
sub load_avg
{
    open (LOAD_AVG, '/proc/loadavg');
    my $load_avg = <LOAD_AVG>; close LOAD_AVG;
    my ($now, $then, $later) = split /\s+/, $load_avg;
    return $now;
}

=back

=head2 Object Methods

=over 4

=item run()

Find, assign and run cloud jobs on the local server

=cut
sub run
{
    my ($self) = @_;
    my $lowest_job_id = 0;

    while (1)
    {
        # Wait then check the load average

        sleep SECS_TO_SLEEP + int(rand($$)) % SECS_TO_SLEEP;
        next if load_avg() >= LOAD_TOO_HIGH;

        # Find jobs that are ready to run

        Models::CloudJob->connect();
        Models::CloudJob->sql("lock tables cloud_jobs write");
        my @jobs = $self->find_jobs($lowest_job_id); $lowest_job_id = 0;
        @jobs = $self->sort_jobs(@jobs);
        my $jobs_started = 0;
        foreach my $job (@jobs)
        {
            my $time = time();

            # Keep track of the lowest job id to be run

            my $cloud_job_id = $job->{id};
            $lowest_job_id ||= $cloud_job_id;
            $lowest_job_id = $cloud_job_id if $lowest_job_id > $cloud_job_id;

            # Skip the job if we're not the target server

            my $target_server = $job->{target_server} || '';
            next if $target_server
                 && $target_server ne $ENV{HOSTNAME}
                 && $target_server ne $ENV{HOST_IP};

            # Run the job

            if ($jobs_started < JOBS_TO_START)
            {
                # Check that we can run the command

                my $command = $job->{command};
                my @parts = split /\s+/, $command;
                next unless -x $parts[0];

                # Update the job's running status

                $job->{start_time} = $time;
                $job->{status} = 'R';
                $job->update();

                # Run the job in the background

                system("$ENV{CLOUDABILITY_HOME}/perl/cloudjob.pl $cloud_job_id $command &");
                $jobs_started++;
                $self->{log_file}->info("Running job $cloud_job_id: $command");
            }
        }
        Models::CloudJob->sql("unlock tables");
        Models::CloudJob->disconnect();
    }
}

=item find_jobs($lowest_job_id)

Find jobs that need running

=cut
sub find_jobs
{
    my ($self, $lowest_job_id) = @_;
    my @jobs;

    my $query = "id > ? and status = ?";
    for (my $cloud_job = Models::CloudJob->select($query, $lowest_job_id, Constants::AWS::STATUS_ACTIVE);
            $cloud_job->{id};
            $cloud_job = Models::CloudJob->next($query, $lowest_job_id))
    {
        push @jobs, $cloud_job;
    }

    return @jobs;
}

=item sort_jobs($jobs)

Sort jobs that need running

=cut
sub sort_jobs
{
    my ($self, @jobs) = @_;

    my $sorter = sub {
        $a->{submit_time} - $a->{priority} * PRIORITY_BIAS <=>
        $b->{submit_time} - $b->{priority} * PRIORITY_BIAS;
    };

    return sort $sorter @jobs;
}

=item DESTROY

Log the death of the object

=cut
sub DESTROY
{
    my ($self) = @_;
    $self->{log_file}->alert("Destroyed");
}

}1;

=back

=head1 DEPENDENCIES

Models::CloudJob, Utils::LogFile, IO::Socket

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
