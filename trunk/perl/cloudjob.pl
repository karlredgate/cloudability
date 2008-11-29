#!/usr/bin/env perl

use strict;

BEGIN {
    $ENV{CLOUDABILITY_HOME} ||= $ENV{HOME} . '/cloudability';
    require "$ENV{CLOUDABILITY_HOME}/perl/env.pl";
}

use lib "$ENV{CLOUDABILITY_HOME}/perl/lib";
use Constants::AWS;
use Data::CloudJob;

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

Data::CloudJob->connect();
my $cloud_job = Data::CloudJob->row($cloud_job_id);
$cloud_job->{finish_time} = time();
$cloud_job->{result} = $result;
$cloud_job->{status} = $status;
$cloud_job->update();
Data::CloudJob->disconnect();

__END__

=head1 DEPENDENCIES

Data::CloudJob

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
