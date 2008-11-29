#!/usr/bin/env perl

use strict;

BEGIN {
    $ENV{CLOUDABILITY_HOME} ||= $ENV{HOME} . '/cloudability';
    require "$ENV{CLOUDABILITY_HOME}/perl/env.pl";
}

use lib "$ENV{CLOUDABILITY_HOME}/perl/lib";
use Clients::AWS;

my $aws = Clients::AWS->new();
my $account_id = shift || 0; die "bad account ID" unless $account_id =~ /\d+/;
my $cmd = join ' ', @ARGV;
if ($cmd)
{
    # Command so run it
    $aws->command($cmd, $account_id);
}
else
{
    # No command so sync
    $aws->syncronize();
}

__END__

=head1 DEPENDENCIES

Clients::AWS

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
