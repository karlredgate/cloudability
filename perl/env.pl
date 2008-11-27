#!/usr/bin/env perl

use warnings;
use Sys::Hostname;

$ENV{AWS_OWNER_ID}    = '992046831893'; # TODO: Change this to your AWS owner ID
$ENV{DB_USER}         = 'root';
$ENV{DB_PASSWORD}     = '';
$ENV{DB_DATABASE}     = 'c10y';
$ENV{HOSTNAME}        = hostname();
$ENV{LOGGING_LEVEL}   ||= 2; # info and above
$ENV{LOGS_DIR}        = "$ENV{CLOUDABILITY_HOME}/logs";
$ENV{DATA_DIR}        = "$ENV{CLOUDABILITY_HOME}/data";
$ENV{GEOIP_DIR}       = "$ENV{CLOUDABILITY_HOME}/geoip";
$ENV{GEOIP_CITY_FILE} = 'GeoLiteCity.dat';
$ENV{MASTER_SERVER}   ||= 'localhost';
$ENV{BACKUP_SERVER}   ||= 'localhost';
