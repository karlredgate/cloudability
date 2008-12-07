# c10y.sql
#
# This file creates a Cloudability (c10y) database to measure
# resource allocation for customers in the Amazon (AWS) cloud.

create table if not exists cloud_jobs
(
    id              INTEGER UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    priority        TINYINT UNSIGNED NOT NULL DEFAULT 100,
    command         VARCHAR(255) NOT NULL,
    result          TEXT,
    submit_time     INTEGER UNSIGNED DEFAULT 0,
    start_time      INTEGER UNSIGNED DEFAULT 0,
    finish_time     INTEGER UNSIGNED DEFAULT 0,
    source_server   VARCHAR(255),
    target_server   VARCHAR(255),
    status          CHAR(1) NOT NULL DEFAULT 'A'
) MAX_ROWS = 4294967296;

create table if not exists customers
(
    id              INTEGER UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    contact         VARCHAR(255) NOT NULL,
    company         VARCHAR(255) NOT NULL,
    street1         VARCHAR(255) NOT NULL,
    street2         VARCHAR(255),
    city            VARCHAR(40) NOT NULL,
    country         VARCHAR(40) NOT NULL,
    zip_code        VARCHAR(40),
    tel_number      VARCHAR(40),
    fax_number      VARCHAR(40),
    tax_number      VARCHAR(40),
    url             VARCHAR(40) NOT NULL,
    email           VARCHAR(40) NOT NULL,
    brand           VARCHAR(40) NOT NULL,
    aws_access_key  VARCHAR(255),
    aws_secret_key  VARCHAR(255),
    aws_account_num VARCHAR(255),
    aws_cert_name   VARCHAR(255),
    aws_cert_text   MEDIUMTEXT,
    max_addresses   SMALLINT DEFAULT 0,
    max_instances   SMALLINT DEFAULT 0,
    max_snapshots   SMALLINT DEFAULT 0,
    max_volumes     SMALLINT DEFAULT 0,

    KEY             company (company)
) MAX_ROWS = 4294967296;

create table if not exists addresses
(
    id              INTEGER UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    account_id      INTEGER UNSIGNED NOT NULL,
    aws_public_ip   VARCHAR(255) NOT NULL,
    aws_instance_id VARCHAR(255),
    name            VARCHAR(255),
    description     MEDIUMTEXT,
    created_at      DATETIME,
    deleted_at      DATETIME,
    status          CHAR(1) NOT NULL DEFAULT 'A',

    KEY             account_id (account_id),
    KEY             aws_public_ip (aws_public_ip)
) MAX_ROWS = 4294967296;

create table if not exists images
(
    id              INTEGER UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    aws_image_id    VARCHAR(255) NOT NULL,
    aws_location    VARCHAR(255) NOT NULL,
    aws_state       VARCHAR(255) NOT NULL,
    aws_owner_id    VARCHAR(255) NOT NULL,
    aws_is_public   ENUM('Y', 'N') NOT NULL,
    aws_architecture VARCHAR(255) NOT NULL,
    aws_type        VARCHAR(255) NOT NULL,
    aws_kernel_id   VARCHAR(255) NOT NULL,
    aws_ramdisk_id  VARCHAR(255) NOT NULL,
    name            VARCHAR(255),
    description     MEDIUMTEXT,

    KEY             aws_image_id (aws_image_id)
) MAX_ROWS = 4294967296;

create table if not exists instances
(
    id              INTEGER UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    account_id      INTEGER UNSIGNED NOT NULL,
    cluster_id      INTEGER UNSIGNED NOT NULL,
    deployment_id   INTEGER UNSIGNED NOT NULL,
    aws_instance_id VARCHAR(255) NOT NULL,
    aws_image_id    VARCHAR(255) NOT NULL,
    aws_kernel_id   VARCHAR(255) NOT NULL,
    aws_ramdisk_id  VARCHAR(255) NOT NULL,
    aws_inst_state  VARCHAR(255) NOT NULL,
    aws_inst_type   VARCHAR(255) NOT NULL,
    aws_avail_zone  VARCHAR(255) NOT NULL,
    aws_key_name    VARCHAR(255) NOT NULL,
    aws_public_dns  VARCHAR(255) NOT NULL,
    aws_private_dns VARCHAR(255) NOT NULL,
    aws_started_at  DATETIME NOT NULL,
    aws_finished_at DATETIME,
    aws_term_reason VARCHAR(255),
    name            VARCHAR(255),
    description     MEDIUMTEXT,
    status          CHAR(1) NOT NULL DEFAULT 'R',

    KEY             account_id (account_id),
    KEY             cluster_id (cluster_id),
    KEY             deployment_id (deployment_id),
    KEY             aws_instance_id (aws_instance_id),
    KEY             aws_image_id (aws_image_id)
) MAX_ROWS = 4294967296;

create table if not exists deployments
(
    id              INTEGER UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    account_id      INTEGER UNSIGNED NOT NULL,
    aws_image_id    VARCHAR(255) NOT NULL,
    aws_inst_type   VARCHAR(255) NOT NULL,
    aws_avail_zone  VARCHAR(255) NOT NULL,
    aws_sec_group   VARCHAR(255) NOT NULL,
    aws_key_name    VARCHAR(255) NOT NULL,
    deploy_file     VARCHAR(255) NOT NULL,
    is_elasic       ENUM('Y','N'),
    name            VARCHAR(255),
    description     MEDIUMTEXT,
    status          CHAR(1) NOT NULL DEFAULT 'A',

    KEY             account_id (account_id)
) MAX_ROWS = 4294967296;

create table if not exists clusters
(
    id              INTEGER UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    account_id      INTEGER UNSIGNED NOT NULL,
    deployment_id   INTEGER UNSIGNED NOT NULL,
    instances_max   SMALLINT UNSIGNED NOT NULL,
    instances_min   SMALLINT UNSIGNED,
    run_hours_max   SMALLINT UNSIGNED,
    run_hours_min   SMALLINT UNSIGNED,
    load_too_high   DECIMAL(4,2) UNSIGNED,
    load_too_low    DECIMAL(4,2) UNSIGNED,
    process_name    VARCHAR(255),
    proc_too_many   SMALLINT UNSIGNED,
    proc_too_few    SMALLINT UNSIGNED,
    is_balanced     ENUM('Y','N') NOT NULL DEFAULT 'N',
    name            VARCHAR(255),
    description     MEDIUMTEXT,
    status          CHAR(1) NOT NULL DEFAULT 'A',

    KEY             account_id (account_id),
    KEY             deployment_id (deployment_id)
) MAX_ROWS = 4294967296;

create table if not exists volumes
(
    id              INTEGER UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    account_id      INTEGER UNSIGNED NOT NULL,
    aws_volume_id   VARCHAR(255) NOT NULL,
    aws_size        SMALLINT UNSIGNED NOT NULL,
    aws_avail_zone  VARCHAR(255) NOT NULL,
    aws_status      VARCHAR(255) NOT NULL,
    aws_device      VARCHAR(255),
    aws_instance_id VARCHAR(255),
    aws_is_attached ENUM('Y', 'N') NOT NULL,
    aws_attached_at DATETIME,
    aws_created_at  DATETIME,
    name            VARCHAR(255),
    description     MEDIUMTEXT,
    deleted_at      DATETIME,
    status          CHAR(1) NOT NULL DEFAULT 'A',

    KEY             account_id (account_id),
    KEY             aws_volume_id (aws_volume_id),
    KEY             aws_instance_id (aws_instance_id)
) MAX_ROWS = 4294967296;

create table if not exists snapshots
(
    id              INTEGER UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    account_id      INTEGER UNSIGNED NOT NULL,
    aws_snapshot_id VARCHAR(255) NOT NULL,
    aws_volume_id   VARCHAR(255) NOT NULL,
    aws_status      VARCHAR(255) NOT NULL,
    aws_started_at  DATETIME,
    aws_progress    VARCHAR(255),
    name            VARCHAR(255),
    description     MEDIUMTEXT,
    deleted_at      DATETIME,
    status          CHAR(1) NOT NULL DEFAULT 'A',

    KEY             account_id (account_id),
    KEY             aws_volume_id (aws_volume_id),
    KEY             aws_snapshot_id (aws_snapshot_id)
) MAX_ROWS = 4294967296;

create table if not exists accounts
(
    id              INTEGER UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    customer_id     INTEGER UNSIGNED NOT NULL,
    parent_id       INTEGER UNSIGNED NOT NULL DEFAULT 0,
    status          CHAR(1) NOT NULL DEFAULT 'A',
    start_date      DATE NOT NULL,
    end_date        DATE,
    name            VARCHAR(255) NOT NULL,
    email           VARCHAR(255) NOT NULL,
    phone           VARCHAR(255) NOT NULL,
    username        VARCHAR(255) NOT NULL,
    password        VARCHAR(255) NOT NULL,
    referrer        MEDIUMTEXT,
    comments        MEDIUMTEXT,

    KEY             parent_id (parent_id),
    KEY             name (name)
) MAX_ROWS = 4294967296;

create table if not exists account_configs
(
    id              INTEGER UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    account_id      INTEGER UNSIGNED NOT NULL,
    field           VARCHAR(255) NOT NULL,
    value           MEDIUMTEXT NOT NULL DEFAULT '',

    KEY             account_id (account_id)
) MAX_ROWS = 4294967296;

create table if not exists account_tokens
(
    id              INTEGER UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    account_id      INTEGER UNSIGNED NOT NULL,
    token_text      VARCHAR(255) NOT NULL,
    call_count      INTEGER UNSIGNED NOT NULL DEFAULT 0,
    call_limit      INTEGER UNSIGNED NOT NULL DEFAULT 0,
    start_date      DATE,
    end_date        DATE,
    status          CHAR(1) NOT NULL DEFAULT 'A',

    KEY             account_id (account_id),
    KEY             token_text (token_text)
) MAX_ROWS = 4294967296;

create table if not exists sessions
(
    session_id      VARCHAR(40) PRIMARY KEY,
    ip_address      VARCHAR(16) NOT NULL,
    user_agent      VARCHAR(50) NOT NULL,
    last_activity   INTEGER UNSIGNED NOT NULL,
    user_data       TEXT NOT NULL,

    KEY             ip_address (ip_address),
    KEY             last_activity (last_activity)
) MAX_ROWS = 4294967296;

# end of c10y.sql
