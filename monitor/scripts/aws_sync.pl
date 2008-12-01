#!/usr/bin/env perl

=head1 NAME

aws_sync - Sync the Cloudability database with Amazon AWS resources

=head1 DESCRIPTION

This program syncs the Cloudability database with Amazon AWS resources.

=cut

use strict;
use warnings;

my $_AWS_CMD = "$ENV{CLOUDABILITY_HOME}/perl/aws.pl";

# Sync the Cloudability database with Amazon AWS resources

system "$_AWS_CMD 0 sync"; # remember only the master server syncs

exit 0; # success
__END__

=head1 DEPENDENCIES

The Cloudability perl program "~/perl/aws.pl"

=head1 AUTHOR

Kevin Hutchinson (kevin.hutchinson@legendum.com)

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
