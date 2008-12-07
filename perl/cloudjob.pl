#!/usr/bin/env perl

=head1 NAME

cloudjob.pl - Execute a cloud job then update its CloudJob database object

=head1 SYNOPSIS

Use this program to execute a cloud job and upadte its database object state.

cloudjob.pl CLOUD_JOB_ID COMMAND

 Options:
  CLOUD_JOB_ID    the ID of the cloud job in the database
  COMMAND         the command to run

=head1 DESCRIPTION

B<cloudjob.pl> executes a cloud job then updates its CloudJob database object

=cut

use strict;

BEGIN {
    $ENV{CLOUDABILITY_HOME} ||= $ENV{HOME} . '/cloudability';
    require "$ENV{CLOUDABILITY_HOME}/perl/env.pl";
}

use lib "$ENV{CLOUDABILITY_HOME}/perl/lib";
use Constants::AWS;
use Models::CloudJob;

my $cloud_job_id = shift || 0;
my $command = join ' ', @ARGV;
die "usage: $0 CLOUD_JOB_ID command" unless $cloud_job_id > 0;
die "usage: $0 cloud_job_id COMMAND" unless $command;

# Run the job to get the result

my $result = '';
my $status = '';
my $stderr = "/tmp/cloudjob.$$";
eval {
    open (JOB, "$command 2>$stderr|");
    $result .= $_ while <JOB>;
    close JOB;
};

# Check for errors from the job

if (-s $stderr)
{
    open (ERROR, $stderr);
    $result .= $_ while <ERROR>;
    close ERROR;

    $status = Constants::AWS::STATUS_ERROR;
}
else
{
    $status = Constants::AWS::STATUS_TERMINATED;
}
unlink $stderr;
chomp $result;

# Update the cloud job's details

Models::CloudJob->connect();
my $cloud_job = Models::CloudJob->row($cloud_job_id);
$cloud_job->{finish_time} = time();
$cloud_job->{result} = $result;
$cloud_job->{status} = $status;
$cloud_job->update();
Models::CloudJob->disconnect();

__END__

=head1 DEPENDENCIES

Models::CloudJob

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
