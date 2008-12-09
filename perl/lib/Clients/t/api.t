#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 2;
use JSON;

use constant TIMEOUT        => 10; # seconds
use constant TOKEN_LENGTH   => 32; # characters

# Setup a customer account holder for testing

require "$ENV{CLOUDABILITY_HOME}/perl/lib/Clients/t/setup";
my ($customer, $account) = setup();

# Get an API token for the account holder

open (TOKEN, "|$ENV{WEB_DIR}/api/token.cgi>/tmp/c10y-token.json");
print TOKEN "username=username\n";
print TOKEN "password=password\n";
print TOKEN "database=test\n";
print TOKEN "format=json\n";
print TOKEN "";
close TOKEN;
open (TMP, "/tmp/c10y-token.json");
my @json = grep /{/, <TMP>; close TMP;
unlink "/tmp/c10y-token.json";
my $token = JSON->new()->jsonToObj($json[0]);
my $token_text = $token->{token}{text};

# Test that we got a good API token from "token.cgi"

is length($token_text), TOKEN_LENGTH, "API token looks good from token.cgi";

# Update the account name using "admin.cgi"

open (ADMIN, "|$ENV{WEB_DIR}/api/admin.cgi>/tmp/c10y-admin.json");
print ADMIN "token=$token_text\n";
print ADMIN "entity=Account\n";
print ADMIN "action=update\n";
print ADMIN "database=test\n";
print ADMIN "format=json\n";
print ADMIN 'values={\"username\":\"username\",\"name\":\"Kevin\"}' . "\n";
print ADMIN "";
close ADMIN;
open (TMP, "/tmp/c10y-admin.json");
@json = grep /{/, <TMP>; close TMP;
unlink "/tmp/c10y-admin.json";
my $admin = JSON->new()->jsonToObj($json[0]);

# Test that we got a good status returned by "admin.cgi"

is $admin->{admin}{result}{status}, 'ok', "Status is ok from admin.cgi";

# TODO: Test "labal.cgi"

clean();
__END__
