/*
  Copyright (c) Oleksii Gaienko, 2021
  Contact: galexsoftware@gmail.com

  Module name: PostgreSQL(R) gsw_security_audit DB import file
  Author(s): Oleksii Gaienko
  Reviewer(s):

  Abstract:
     SQL file for import data into DB.
 */

drop table if exists import.virtual_servers;
CREATE TABLE import.virtual_servers(
    id SERIAL NOT NULL primary key,
    searchcode VARCHAR DEFAULT NULL,
    name VARCHAR DEFAULT NULL,
    description VARCHAR DEFAULT NULL,
    status VARCHAR DEFAULT NULL,
    owner VARCHAR DEFAULT NULL,
    cpucores VARCHAR DEFAULT NULL,
    ram VARCHAR DEFAULT NULL,
    ipaddress VARCHAR DEFAULT NULL,
    vip VARCHAR DEFAULT NULL,
    os VARCHAR DEFAULT NULL,
    patchlevel VARCHAR DEFAULT NULL,
    avsoft VARCHAR DEFAULT NULL,
    avversion VARCHAR DEFAULT NULL,
    datasource VARCHAR DEFAULT NULL,
    eos_software VARCHAR DEFAULT NULL
) TABLESPACE gsw_tbs_import;
ALTER TABLE IF EXISTS import.virtual_servers OWNER to gsw_datasetter;
COMMENT ON TABLE import.virtual_servers IS 'Virtual servers';
COMMENT ON COLUMN import.virtual_servers.owner IS 'employeeid from ad.accounts';
COMMENT ON COLUMN import.virtual_servers.status IS 'ToDo: change VARCHAR to INTEGER';

drop table if exists cmdb.virtual_servers;
CREATE TABLE cmdb.virtual_servers(
    id SERIAL NOT NULL primary key,
    searchcode VARCHAR default null,
    name VARCHAR default null,
    description VARCHAR default null,
    status VARCHAR default null,
    owner_id INTEGER default null,
    --cpucores VARCHAR default null,
    --ram VARCHAR default null,
    hardware_info_id integer default null,
    ipaddress cidr default null,
    vip cidr[] default null,
    os VARCHAR default null,
    patchlevel VARCHAR default null,
    --avsoft VARCHAR default null,
    --avversion VARCHAR default null,
    --datasource VARCHAR default null,
    av_info_id integer default null,
    datasource_id integer default null,
    eos_software DATE default null,
    short_name varchar default null,
    tags VARCHAR[] default null
) TABLESPACE gsw_tbs_cmdb;
ALTER TABLE IF EXISTS cmdb.virtual_servers OWNER to gsw_datasetter;
COMMENT ON TABLE cmdb.virtual_servers IS 'Virtual servers';
COMMENT ON COLUMN cmdb.virtual_servers.owner_id IS 'employeeid from ad.accounts';
COMMENT ON COLUMN cmdb.virtual_servers.status IS 'ToDo: change VARCHAR to INTEGER';