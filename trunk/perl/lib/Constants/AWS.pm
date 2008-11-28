#!/usr/bin/env perl

=head1 NAME

Constants::AWS - Contains AWS constants, e.g. meta-data field names

=head1 VERSION

This document refers to version 1.0 of Constants::AWS, released Nov 26, 2008

=head1 DESCRIPTION

Constants::AWS contains Amazon Web Services constants, e.g. field names

=head2 Properties

=over 4

None

=back

=cut
package Constants::AWS;
$VERSION = "1.0";

use strict;

use constant FIELDS => {
    architecture    => 'aws_architecture',
    attachTime      => 'aws_attached_at',
    attachmentSet   => 'PARSE',
    availabilityZone => 'aws_avail_zone',
    code            => 'aws_code',
    createTime      => 'aws_created_at',
    device          => 'aws_device',
    dnsName         => 'aws_public_dns',
    imageId         => 'aws_image_id',
    imageLocation   => 'aws_location',
    imageOwnerId    => 'aws_owner_id',
    imageState      => 'aws_state',
    imageType       => 'aws_type',
    instanceId      => 'aws_instance_id',
    instanceState   => 'PARSE',
    instanceType    => 'aws_inst_type',
    isPublic        => 'aws_is_public',
    item            => 'aws_item', # not used
    kernelId        => 'aws_kernel_id',
    keyName         => 'aws_key_name',
    launchTime      => 'aws_started_at',
    name            => 'aws_inst_state',
    privateDnsName  => 'aws_private_dns',
    placement       => 'PARSE',
    ramdiskId       => 'aws_ramdisk_id',
    reason          => 'aws_term_reason',
    shutdownState   => 'PARSE',
    size            => 'aws_size',
    status          => 'aws_status',
    volumeId        => 'aws_volume_id',
};

# Instance, account and account token status values

use constant STATUS_ACTIVE          => 'A';
use constant STATUS_PENDING         => 'P';
use constant STATUS_RUNNING         => 'R';
use constant STATUS_SUSPENDED       => 'S';
use constant STATUS_TERMINATED      => 'T';
use constant STATUS_UNKNOWN         => 'U';

use constant STATES => {
    pending         => Constants::AWS::STATUS_PENDING,
    running         => Constants::AWS::STATUS_RUNNING,
    terminated      => Constants::AWS::STATUS_TERMINATED,
};

=back

=head1 DEPENDENCIES

None

=head1 AUTHOR

Kevin Hutchinson <kevin.hutchinson@legendum.com>

=head1 COPYRIGHT

Copyright (c) 2008 Legendum, LLC

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 3
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.
