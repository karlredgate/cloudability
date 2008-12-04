#!/usr/bin/env perl

use strict;

BEGIN {
    $ENV{CLOUDABILITY_HOME} ||= $ENV{HOME} . '/cloudability';
    require "$ENV{CLOUDABILITY_HOME}/perl/env.pl";
}

use lib "$ENV{CLOUDABILITY_HOME}/perl/lib";
use CGI qw/:cgi -debug/;
use Data::AccountToken;
use Clients::Label;

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
my $entity = $params{entity}; # don't "lc"
my $id = lc($params{id});
my $name = $params{name}; # don't "lc"
my $desc = $params{desc} || $params{description}; # don't "lc"
my $format = lc($params{format}) || 'xml';
my $token_text = $params{token} or error "no 'token' query parameter";
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

Data::AccountToken->connect();

# Select the API token

my $token = Data::AccountToken->select('token_text = ?', $token_text);
my $account_id = $token->{account_id} or error "no token found with ID '$token_text'";

# Check the token call

my $error = $token->call();
error "sorry, cannot call token '$token_text': $error" if $error;

# Perform an admin action on an entity with some data

my $label = Clients::Label->new($account_id);
my $output = $label->set(   entity  => $entity,
                            id      => $id,
                            name    => $name,
                            desc    => $desc,
                            format  => $format,
                            request => $request );

# Disconnect from the database

Data::AccountToken->disconnect();

# Finally, write the result

$output = "$callback($output)" if $callback && $format eq 'json';
$format = 'javascript' if $format eq 'json';
print "Content-type: text/$format\n\n$output";

}; # End of the eval block
error $@ if $@;

__END__

=head1 DEPENDENCIES

Data::AccountToken, Clients::Label

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
