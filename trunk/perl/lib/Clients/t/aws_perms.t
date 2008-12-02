#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 1;
use Clients::AWS;

Clients::AWS->set_aws_cmd("$ENV{CLOUDABILITY_HOME}/perl/lib/Clients/t/aws_mock");
my $aws = Clients::AWS->new();

# TODO: Check that an account holder can't modify another's resources
is 1, 1, "ok";

__END__
