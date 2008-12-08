#!/usr/bin/env perl -w

use strict;

use Test::More tests => 10;
use Constants::AWS;

my $fields = Constants::AWS::FIELDS;
ok (keys(%{$fields}) > 25), 'AWS fields map is well populated';
is Constants::AWS::STATUS_ACTIVE, 'A', 'Active status is "A"';
is Constants::AWS::STATUS_DELETED, 'D', 'Deleted status is "D"';
is Constants::AWS::STATUS_ERROR, 'E', 'Error status is "E"';
is Constants::AWS::STATUS_HALTING, 'H', 'Halting status is "H"';
is Constants::AWS::STATUS_PENDING, 'P', 'Pending status is "P"';
is Constants::AWS::STATUS_RUNNING, 'R', 'Running status is "R"';
is Constants::AWS::STATUS_SUSPENDED, 'S', 'Suspended status is "S"';
is Constants::AWS::STATUS_TERMINATED, 'T', 'Terminated status is "T"';
is Constants::AWS::STATUS_UNKNOWN, 'U', 'Unknown status is "U"';

__END__
