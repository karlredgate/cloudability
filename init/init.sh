# Replace this with a list of initialization commands for a
# newly started server using placeholders instead of values:
# - "INSTANCE" is the AWS instance ID of the new instance
# - "HOST" is the public DNS hostname of the new instance
# - "KEY" is the path to the key file
# - "AWS" is the path to the AWS command
#
# For example:
#
# AWS attvol vol-a1b2c3d4 -i INSTANCE -d /dev/sdb
# scp -i KEY ~/perl/env.pl root@HOST:cloudability/perl/
# ssh -i KEY root@HOST cloudability/bin/cloudserver -restart
# ssh -i KEY root@HOST cloudability/bin/newuser admin:admin
# ssh -i KEY root@HOST /etc/init.d/mysql restart
