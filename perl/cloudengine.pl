#!/usr/bin/env perl

=head1 NAME

cloudengine.pl - Run the CloudEngine server module to execute cloud jobs

=head1 SYNOPSIS

Use this program to run the CloudEngien server and execute cloud jobs.

cloudengine.pl

 Options: None

=head1 DESCRIPTION

B<cloudengine.pl> runs the CloudEngine server module to execute cloud jobs

=cut

use strict;

BEGIN {
    $ENV{CLOUDABILITY_HOME} ||= $ENV{HOME} . '/cloudability';
    require "$ENV{CLOUDABILITY_HOME}/perl/env.pl";
}

use lib "$ENV{CLOUDABILITY_HOME}/perl/lib";
use Servers::CloudEngine;
my $cloud_engine = Servers::CloudEngine->new();
$cloud_engine->run();

__END__

=head1 DEPENDENCIES

Servers::CloudEngine

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
