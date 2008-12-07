#!/usr/bin/env perl

=head1 NAME

deploy.pl - Deploy a database-defined configuration onto a new AWS instance

=head1 SYNOPSIS

Use this program to deploy a predefined configuration onto a new AWS instance.

aws ACCOUNT_ID DEPLOYMENT (ID or name)

 Options:
  ACCOUNT_ID  the account holder running the command (cannot be zero)
  DEPLOYMENT  the deployment to deploy onto the new instance (ID or name)

=head1 DESCRIPTION

B<deploy.pl> deploys a database-defined configuration onto a new AWS instance

=cut

use strict;

BEGIN {
    $ENV{CLOUDABILITY_HOME} ||= $ENV{HOME} . '/cloudability';
    require "$ENV{CLOUDABILITY_HOME}/perl/env.pl";
}

use lib "$ENV{CLOUDABILITY_HOME}/perl/lib";
use Models::Deployment;
use Clients::AWS;

# Get the account ID and command from the command line

my ($account_id, $deployment) = @ARGV;
die "usage: $0 ACCOUNT_ID deployment" unless $account_id =~ /^\d+$/;
die "usage: $0 account_id DEPLOYMENT" unless $deployment =~ /^\w+$/;

# Find the deployment for the account holder

Models::Deployment->connect();
my $query = 'account_id = ? and ' . ($deployment =~ /^\d+$/ ?
                                    'id = ?' : 'name = ?');
my $deploying = Models::Deployment->select($query, $account_id, $deployment);
Models::Deployment->disconnect();
die "deployment $deployment not found" unless $deploying->{id};

# Run the deployment command

my $aws = Clients::AWS->new();
$aws->command($deploying->to_aws_command(), $account_id, $deploying->{id});

__END__

=head1 DEPENDENCIES

Models::Deployment, Clients::AWS, Timothy Kay's excellent "aws" script

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
