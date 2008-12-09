#!/usr/bin/env perl

use strict;

BEGIN {
    $ENV{CLOUDABILITY_HOME} ||= $ENV{HOME} . '/cloudability';
    require "$ENV{CLOUDABILITY_HOME}/perl/env.pl";
}

use lib "$ENV{CLOUDABILITY_HOME}/perl/lib";
use CGI qw/:cgi -debug/;
use Models::Account;
use Models::AccountToken;

# Return an error message to the user

sub error
{
    my $message = shift;
    print "Content-type: text/plain\n\nERROR: $message\n";
    exit;
}

# Get the query parameters

my $cgi = new CGI;
my %params = $cgi->Vars;
my $format = lc($params{format}) || 'xml';
my $username = $params{username} or error "no 'username' query parameter";
my $password = $params{password} or error "no 'password' query parameter";
my $request = $params{request} || '';
my $callback = $params{callback} || '';

# Which database are we using?

if (my $database = $params{database})
{
    $ENV{DB_DATABASE} .= "_$database";
}

# Store the remote host address

$ENV{HTTP_REMOTE_ADDR} = $cgi->remote_host();

# Wrap the code in an eval to catch errors

eval {

# Connect to the database

Models::Account->connect();
Models::AccountToken->connect();

# Get the account details

my $account = Models::Account->select("username = ? and password = ?", $username, $password);
my $account_id = $account->{id} or error "no user found with username '$username' and password '$password'";

# Get the token details, and make a new token if necessary

my $token = Models::AccountToken->select("account_id = ?", $account_id);
$token->create($account_id) unless $token->{api_token_id};
my $output = $token->generate(format  => $format,
                              request => $request);

# Disconnect from the database

Models::Account->disconnect();
Models::AccountToken->disconnect();

# Finally, write the output

$format = 'javascript' if $format eq 'json';
$output = "$callback($output)" if $callback;
print "Content-type: text/$format\n\n$output";

}; # End of the eval block
error $@ if $@;

__END__

=head1 DEPENDENCIES

Models::Account, Models::AccountToken

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
