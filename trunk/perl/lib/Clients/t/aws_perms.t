#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 1;
use Clients::AWS;

# Setup a customer account holder for testing

require "$ENV{CLOUDABILITY_HOME}/perl/lib/Clients/t/setup";
my ($customer, $account) = setup();

# Now test that permissions are checked before running AWS commands

Clients::AWS->set_aws_command("$ENV{CLOUDABILITY_HOME}/perl/lib/Clients/t/aws_mock");
my $aws = Clients::AWS->new($account->{id});

# TODO: Check that an account holder can't modify another's resources

is 1, 1, "ok";

clean();
__END__
