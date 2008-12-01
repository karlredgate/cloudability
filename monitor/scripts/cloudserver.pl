#!/usr/bin/env perl

=head1 NAME

cloudserver - Check that the Cloudability server processes are running

=head1 DESCRIPTION

This program checks that the Cloudability server processes are running.

=cut

use strict;
use warnings;

# Check the Cloudability server processes

my $cloudserver = "$ENV{CLOUDABILITY_HOME}/bin/cloudserver";
open (STATUS, "$cloudserver -status|");
my $return_code = 0;
while (<STATUS>)
{
	if (/not running/i)
	{
		$return_code = 1;
		print STDERR $_;
	}
}
close STATUS;

system "$cloudserver -start" if $return_code;

exit $return_code;
__END__

=head1 DEPENDENCIES

The Cloudability admin program "~/bin/cloudserver"

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
