#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 4;
use Clients::Quota;
use Data::Customer;
use Data::Account;
use Data::Address;
use Data::Instance;
use Data::Snapshot;
use Data::Volume;

# Connect to the database

Data::Customer->connect();
Data::Account->connect();
Data::Address->connect();
Data::Instance->connect();
Data::Snapshot->connect();
Data::Volume->connect();

# Delete any old data from the test database

Data::Customer->sql("delete from customers");
Data::Account->sql("delete from accounts");
Data::Address->sql("delete from addresses");
Data::Instance->sql("delete from instances");
Data::Snapshot->sql("delete from snapshots");
Data::Volume->sql("delete from volumes");

# Insert a new customer and two accounts

my $customer = {
    contact         => 'Administrator',
    company         => 'Customer',
    street1         => '1 Main Street',
    city            => 'Cloudville',
    country         => 'USA',
    url             => 'www.customer.com',
    brand           => 'Customer',
    email           => 'support@customer.com',
    max_addresses   => 1,
    max_instances   => 1,
    max_snapshots   => 1,
    max_volumes     => 3,
};
$customer = Data::Customer->new(%{$customer});
$customer->insert();

my $account = {
    customer_id     => $customer->{id},
    parent_id       => 0,
    status          => 'A',
    start_date      => '2008-12-01',
    name            => 'name',
    email           => 'email@domain.com',
    phone           => '123-1234-5678',
    username        => 'username',
    password        => 'password',
};
my $account1 = Data::Account->new(%{$account});
$account1->insert();
my $account2 = Data::Account->new(%{$account});
$account2->insert();

# Now we can make a quota object for an account

my $quota = Clients::Quota->new($account1->{id});

# Insert some test addresses

my $addresses = [
    {
        account_id      => $account1->{id},
        aws_public_ip   => '111.222.111.222',
        status          => 'A',
    },
    {
        account_id      => $account2->{id},
        aws_public_ip   => '123.123.123.123',
        status          => 'A',
    },
    {
        account_id      => $account2->{id},
        aws_public_ip   => '222.111.222.111',
        status          => 'D',
    },
];
foreach my $address (@{$addresses})
{
    Data::Address->new(%{$address})->insert();
}

# The customer has a quota for 1 address, but has 2 active addresses (quota -1)

is $quota->address_quota(), -1, "negative address quota";

# Insert some test instances

my $instances = [
    {
        account_id      => $account2->{id},
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
        status          => Constants::AWS::STATUS_RUNNING,
    },
];
foreach my $instance (@{$instances})
{
    Data::Instance->new(%{$instance})->insert();
}

# The customer has a quota for 1 instance, and has 1 active instance (quota 0)

is $quota->instance_quota(), 0, "no instance quota";

# Insert some test snapshots

my $snapshots = [
    {
        account_id      => $account1->{id},
        aws_snapshot_id => 'snap-f85fbf91',
        aws_volume_id   => 'vol-34bf5b5d',
        aws_status      => 'completed',
        aws_started_at  => '2008-12-02 02:51:22',
        aws_progress    => '100%',
        status          => Constants::AWS::STATUS_ACTIVE,
    },
    {
        account_id      => $account2->{id},
        aws_snapshot_id => 'snap-f85fbf91',
        aws_volume_id   => 'vol-34bf5b5d',
        aws_status      => 'completed',
        aws_started_at  => '2008-12-02 02:51:22',
        aws_progress    => '100%',
        status          => Constants::AWS::STATUS_DELETED,
    },
];
foreach my $snapshot (@{$snapshots})
{
    Data::Snapshot->new(%{$snapshot})->insert();
}

# The customer has a quota for 1 snapshot, and has 1 active snapshot (quota 0)

is $quota->snapshot_quota(), 0, "no snapshot quota";

# Insert some test volumes

my $volumes = [
    {
        account_id      => $account1->{id},
        aws_volume_id   => 'vol-e8bb5f81',
        aws_size        => 1,   
        aws_avail_zone  => 'us-east-1a',
        aws_status      => 'deleting',
        aws_created_at  => '2008-12-02 03:12:23',
        status          => Constants::AWS::STATUS_ACTIVE,
    },
    {
        account_id      => $account2->{id},
        aws_volume_id   => 'vol-e8bb5f81',
        aws_size        => 1,   
        aws_avail_zone  => 'us-east-1a',
        aws_status      => 'deleting',
        aws_created_at  => '2008-12-02 03:12:23',
        status          => Constants::AWS::STATUS_ACTIVE,
    },
];
foreach my $volume (@{$volumes})
{
    Data::Volume->new(%{$volume})->insert();
}

# The customer has a quota for 3 volume, and has 2 active volumes (quota 1)

is $quota->volume_quota(), 1, "positive volume quota";

__END__
