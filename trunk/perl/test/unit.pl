#!/usr/bin/env perl

use strict;

BEGIN {
    $ENV{CLOUDABILITY_HOME} ||= $ENV{HOME} . '/cloudability';
    require "$ENV{CLOUDABILITY_HOME}/perl/env.pl";
}

use lib "$ENV{CLOUDABILITY_HOME}/perl/lib";
use Test::Harness;
use Getopt::Long;

# Use the test database

$ENV{DB_DATABASE} = 'c10y_test';

# What are we testing?

my $constants = 0;
my $clients = 0;
my $servers = 0;
my $models = 0;
my $utils = 0;
my $all = 0;
GetOptions("constants" => \$constants,
           "clients"   => \$clients,
           "servers"   => \$servers,
           "models"    => \$models,
           "utils"     => \$utils,
           "all"       => \$all);

die "usage: $0 --all --constants --clients --servers --models --utils"
    unless $all || $constants || $clients || $servers || $models || $utils;

# Look in a perl lib directory for unit tests to run

sub unit_test
{
	my $dir = shift or die "no directory to unit test";
	chdir "$ENV{CLOUDABILITY_HOME}/perl/lib/$dir/t";
	opendir (DIR, '.');
	my @tests = grep /\.t$/, readdir(DIR);
	closedir DIR;
	runtests @tests; 
}

# Run the unit tests

unit_test('Constants') if $constants || $all;
unit_test('Clients') if $clients || $all;
unit_test('Servers') if $servers || $all;
unit_test('Models') if $models || $all;
unit_test('Utils') if $utils || $all;

__END__

=head1 DEPENDENCIES

All the test files in the "t" subdirectories

=head1 AUTHOR

Kevin Hutchinson <kevin.hutchinson@legendum.com>

=head1 COPYRIGHT

Copyright (c) 2008 Legendum, LLC.

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 3
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.
