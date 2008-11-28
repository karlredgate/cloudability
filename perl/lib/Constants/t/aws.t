#!/usr/bin/env perl -w

use strict;

use Test::More tests => 5;
use Constants::AWS;

my $fields = Constants::AWS::FIELDS;
ok (keys(%{$fields}) > 25), 'AWS fields map is well populated';
is Constants::AWS::STATUS_ACTIVE, 'A', 'Active status is "A"';
is Constants::AWS::STATUS_RUNNING, 'R', 'Running status is "R"';
is Constants::AWS::STATUS_SUSPENDED, 'S', 'Suspended status is "S"';
is Constants::AWS::STATUS_TERMINATED, 'T', 'Terminated status is "T"';

__END__
