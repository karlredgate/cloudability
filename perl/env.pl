#!/usr/bin/env perl

use warnings;
use Sys::Hostname;

$ENV{MASTER_SERVER}   = 'localhost';
$ENV{BACKUP_SERVER}   = 'localhost';
$ENV{DB_USER}         = 'root';
$ENV{DB_PASSWORD}     = '';
$ENV{DB_DATABASE}     = 'c10y';
$ENV{HOSTNAME}        = hostname();
$ENV{LOGGING_LEVEL}   ||= 2; # info and above, unless already set by the user
$ENV{WEB_DIR}         = "$ENV{CLOUDABILITY_HOME}/web";
$ENV{LOGS_DIR}        = "$ENV{CLOUDABILITY_HOME}/logs";
$ENV{KEYS_DIR}        = "$ENV{CLOUDABILITY_HOME}/keys";
$ENV{POUND_DIR}       = "$ENV{CLOUDABILITY_HOME}/pound";
$ENV{DEPLOY_DIR}      = "$ENV{CLOUDABILITY_HOME}/deploy";
