#!/usr/bin/env perl

=head1 NAME

Models::Instance - Manages customer account instances

=head1 VERSION

This document refers to version 1.0 of Models::Instance, released Nov 07, 2008

=head1 DESCRIPTION

Models::Instance manages the details for all customer account instances.
Be sure to call the class static method connect() before using Models::Instance
objects and disconnect() once you've finished.

=head2 Properties

=over 4

=item account_id

The account running the instance

=item deployment_id

The deployment used to configure the instance

=item aws_instance_id

The AWS instance ID

=item aws_image_id

The AWS image ID

=item aws_kernel_id

The AWS kernel ID

=item aws_ramdisk_id

The AWS ramdisk ID

=item aws_inst_state

The AWS instance state

=item aws_inst_type

The AWS instance type (e.g. "m1.small")

=item aws_avail_zone

The AWS availability zone (placement)

=item aws_key_name

The AWS key name for root access

=item aws_public_dns

The AWS public DNS for the instance

=item aws_private_dns

The AWS private DNS for the instance

=item aws_started_at

The AWS time the instance started running

=item aws_finished_at

The AWS time the instance finished running

=item aws_term_reason

The AWS image termination reason

=item name

A user-assigned name for the instance, for example "Acme web server"

=item description

A user-assigned description for the instance, for example "Site www.acme.com"

=item status

The status of the image [P]ending, [R]unning, [S]hutting down or [T]erminated

=back

=cut
package Models::Instance;
$VERSION = "1.0";

use strict;
use base 'Models::Object';
use Constants::AWS;
{
    # Class static properties

    my $_Connection;
    my $_KNOW_HOST_CMD = "$ENV{CLOUDABILITY_HOME}/bin/knowhost";

=head2 Class Methods

=over 4

=item connect(driver=>'mysql', database=>'dbname', user=>'username', password=>'pass')

Initialise a connection to the database with optional details

=cut
sub connect
{
    my ($class, %args) = @_;
    return $_Connection if $_Connection;

    $args{host} ||= $ENV{MASTER_SERVER};
    eval {
        $_Connection = $class->SUPER::connect(%args);
    }; if ($@) {
        $args{host} = $ENV{BACKUP_SERVER};
        $_Connection = $class->SUPER::connect(%args);
    }
    $class->fields(qw(account_id deployment_id aws_instance_id aws_image_id aws_kernel_id aws_ramdisk_id aws_inst_state aws_inst_type aws_avail_zone aws_key_name aws_public_dns aws_private_dns aws_started_at aws_finished_at aws_term_reason name description status));

    return $_Connection;
}

=item disconnect()

Disconnect from the database cleanly

=cut
sub disconnect
{
    my ($class) = @_;
    return unless $_Connection;

    $_Connection = undef;
    $class->SUPER::disconnect();
}

=back

=head2 Object Methods

=over 4

=item find_by_aws_instance_id($aws_instance_id)

Find an instance in the database by its AWS instance ID

=cut
sub find_by_aws_instance_id
{
    my ($self, $aws_instance_id) = @_;
    my $class = ref $self || $self;

    $class->connect();
    my $instance = $class->select('aws_instance_id = ?', $aws_instance_id);
    #$class->disconnect();

    return $instance;
}

=item deploy_host($aws_cmd)

Deploy to a host that has just started running by running a "deploy file"

=cut
sub deploy_to_host
{
    my ($self, $aws_cmd) = @_;
    return if $self->{status} ne Constants::AWS::STATUS_RUNNING;
    die "no AWS public DNS host name" unless $self->{aws_public_dns};

    $self->know_host(); # so we don't get prompted for SSH/SCP configmations
    Models::Deployment->connect();
    my $deployment = Models::Deployment->row($self->{deployment_id});
    my $deploy_file = $deployment->{deploy_file} || Constants::AWS::DEPLOY_FILE;
    my $key_file = $self->key_file();
    open (DEPLOY_FILE, "$ENV{DEPLOY_DIR}/$deploy_file") or die "no deploy file";
    while (my $command = <DEPLOY_FILE>)
    {
        # Substitute "INSTANCE", "HOST", "KEY" and "AWS" in the command line

        $command =~ s/INSTANCE/$self->{aws_instance_id}/g;
        $command =~ s/HOST/$self->{aws_public_dns}/g;
        $command =~ s/KEY/$key_file/g;
        $command =~ s/AWS/$aws_cmd $self->{account_id}/g;
        $command =~ s/\s*#.*$//; # strip any line comments

        # Run the command line

        system $command;
    }
    close DEPLOY_FILE;
}

=item know_host()

Make sure we know the instance's host for SSH commands

=cut
sub know_host
{
    my ($self) = @_;
    return if $self->{status} ne Constants::AWS::STATUS_RUNNING;
    die "no AWS public DNS host name" unless $self->{aws_public_dns};

    my $key_file = $self->key_file();
    system "$_KNOW_HOST_CMD $key_file $self->{aws_public_dns} >/dev/null";
}

=item key_file()

Return the full file path to the key file for this instance

=cut
sub key_file
{
    my ($self) = @_;
    my $key_name = $self->{aws_key_name} or die "no 'aws_key_name'";
    return "$ENV{KEYS_DIR}/$key_name.pem";
}

}1;

=back

=head1 DEPENDENCIES

Models::Object

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
