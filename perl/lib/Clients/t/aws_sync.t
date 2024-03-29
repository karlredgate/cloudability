#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 32;
use Clients::AWS;
use Models::Image;
use Models::Address;
use Models::Instance;
use Models::Snapshot;
use Models::Volume;

# Setup a customer account holder for testing

require "$ENV{CLOUDABILITY_HOME}/perl/lib/Clients/t/setup";
my ($customer, $account) = setup();

# Set-up some test objects to check the results

my $images = {
    'ami-050de96c' => {
        aws_image_id    => 'ami-050de96c',
        aws_location    => 'cloudability-images/cloudability-02.manifest.xml',
        aws_state       => 'available',
        aws_owner_id    => '992046831893',
        aws_is_public   => 'N',
        aws_architecture => 'i386',
        aws_type        => 'machine',
        aws_kernel_id   => 'aki-a71cf9ce',
        aws_ramdisk_id  => 'ari-a51cf9cc',
    },
};

my $addresses = {
    '75.101.151.221' => {
        aws_public_ip   => '75.101.151.221',
        aws_instance_id => 'i-f63a889f',
    },
};

my $instances = {
    'i-f63a889f' => {
        aws_instance_id => 'i-f63a889f',
        aws_image_id    => 'ami-af7793c6',
        aws_inst_state  => 'running',
        aws_private_dns => 'domU-12-31-39-00-5D-C4.compute-1.internal',
        aws_public_dns  => 'ec2-75-101-151-221.compute-1.amazonaws.com',
        aws_key_name    => 'c10y-keypair',
        aws_inst_type   => 'm1.small',
        aws_started_at  => '2008-12-01 03:41:08',
        aws_avail_zone  => 'us-east-1a',
        aws_kernel_id   => 'aki-a71cf9ce',
        aws_ramdisk_id  => 'ari-a51cf9cc',
    },
};

my $snapshots = {
    'snap-f85fbf91' => {
        aws_snapshot_id => 'snap-f85fbf91',
        aws_volume_id   => 'vol-34bf5b5d',
        aws_status      => 'completed',
        aws_started_at  => '2008-12-02 02:51:22',
        aws_progress    => '100%',
    },
};

my $volumes = {
    'vol-e8bb5f81' => {
        aws_volume_id   => 'vol-e8bb5f81',
        aws_size        => 1,   
        aws_avail_zone  => 'us-east-1a',
        aws_status      => 'deleting',
        aws_created_at  => '2008-12-02 03:12:23',
    },
};

# Set the AWS object to use the "aws_mock" test command to read our "out" files

my $aws = Clients::AWS->new($account->{id});
Clients::AWS->set_aws_command("$ENV{CLOUDABILITY_HOME}/perl/lib/Clients/t/aws_mock");

# Connect to the database

Models::Image->connect();
Models::Address->connect();
Models::Instance->connect();
Models::Snapshot->connect();
Models::Volume->connect();

# Delete any old data from the test database

Models::Image->sql("delete from images");
Models::Address->sql("delete from addresses");
Models::Instance->sql("delete from instances");
Models::Snapshot->sql("delete from snapshots");
Models::Volume->sql("delete from volumes");

# Run the synchronize command on mock data

$aws->sync_with_aws();
my $check;

# Run tests to compare the database with the mock data we used

my $image = Models::Image->select('aws_image_id = ?', 'ami-050de96c');
$check = $images->{'ami-050de96c'};
while (my ($field, $value) = each %{$check})
{
    is $image->{$field}, $value, "image: retrieved $field is $value";
}

my $address = Models::Address->select('aws_public_ip = ?', '75.101.151.221');
$check = $addresses->{'75.101.151.221'};
while (my ($field, $value) = each %{$check})
{
    is $address->{$field}, $value, "address: retrieved $field is $value";
}

my $instance = Models::Instance->select('aws_instance_id = ?', 'i-f63a889f');
$check = $instances->{'i-f63a889f'};
while (my ($field, $value) = each %{$check})
{
    is $instance->{$field}, $value, "instance: retrieved $field is $value";
}

my $snapshot = Models::Snapshot->select('aws_snapshot_id = ?', 'snap-f85fbf91');
$check = $snapshots->{'snap-f85fbf91'};
while (my ($field, $value) = each %{$check})
{
    is $snapshot->{$field}, $value, "snapshot: retrieved $field is $value";
}

my $volume = Models::Volume->select('aws_volume_id = ?', 'vol-e8bb5f81');
$check = $volumes->{'vol-e8bb5f81'};
while (my ($field, $value) = each %{$check})
{
    is $volume->{$field}, $value, "volume: retrieved $field is $value";
}

clean();
__END__
