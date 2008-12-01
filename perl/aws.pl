#!/usr/bin/env perl

=head1 NAME

aws.pl - Run a "sync" of the AWS data, or run a regular "aws" command

=head1 SYNOPSIS

Use this program to synchronize the AWS data, or run a regular "aws" command.

aws ACCOUNT_ID COMMAND

 Options:
  ACCOUNT_ID      the account holder running the command (or "0")
  COMMAND         the command to run (e.g. "sync" or "din")

=head1 DESCRIPTION

B<aws.pl> runs a "sync" of the AWS data, or runs regular "aws" commands

=cut

use strict;

BEGIN {
    $ENV{CLOUDABILITY_HOME} ||= $ENV{HOME} . '/cloudability';
    require "$ENV{CLOUDABILITY_HOME}/perl/env.pl";
}

use lib "$ENV{CLOUDABILITY_HOME}/perl/lib";
use Clients::AWS;

my $aws = Clients::AWS->new();

# Get the account ID and command from the command line

my $account_id = shift||0;
my $cmd = join ' ', @ARGV;
die "usage: $0 ACCOUNT_ID command" unless $account_id =~ /^\d+$/;
die "usage: $0 account_id COMMAND" unless $cmd;

# Perform a sync or run a regular "aws" command and read its data

if ($cmd eq 'sync')
{
    die "Only $ENV{MASTER_SERVER} can sync the database with AWS"
        unless $ENV{MASTER_SERVER} =~ /^(localhost|$ENV{HOSTNAME})/;
    $aws->syncronize();
}
else
{
    $aws->command($cmd, $account_id);
}

__END__

=head1 DEPENDENCIES

Clients::AWS, Timothy Kay's excellent "aws" script to manage Amazon AWS

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
