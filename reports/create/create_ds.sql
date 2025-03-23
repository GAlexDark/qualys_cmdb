/*
  Copyright (c) Oleksii Gaienko, 2021
  Contact: galexsoftware@gmail.com

  Module name: PostgreSQL(R) gsw_security_audit DB import file
  Author(s): Oleksii Gaienko
  Reviewer(s):

  Abstract:
     SQL file for import data into DB.
 */

drop table if exists import.ds;
CREATE TABLE IF NOT EXISTS import.ds (
    id SERIAL NOT NULL primary key,
    searchcode VARCHAR DEFAULT NULL,
    name VARCHAR DEFAULT NULL,
    description VARCHAR DEFAULT NULL,
    status VARCHAR DEFAULT NULL,
    owner VARCHAR DEFAULT NULL, --integer
    manufacturer VARCHAR DEFAULT NULL,
    model VARCHAR DEFAULT NULL,
    technomapid_model varchar DEFAULT NULL,
    eos_model VARCHAR DEFAULT NULL,
    serialnumber VARCHAR DEFAULT NULL,
    ipaddress VARCHAR DEFAULT NULL,
    vip VARCHAR DEFAULT NULL,
    firmware VARCHAR DEFAULT NULL,
    eos_software VARCHAR DEFAULT NULL
) TABLESPACE gsw_tbs_import;
ALTER TABLE IF EXISTS import.ds OWNER to gsw_datasetter;
COMMENT ON TABLE import.ds IS 'Disks Storages';
COMMENT ON COLUMN import.ds.owner IS 'employeeid from ad.accounts';

drop table if exists cmdb.ds;
CREATE TABLE IF NOT EXISTS cmdb.ds (
    id SERIAL NOT NULL primary key,
    searchcode VARCHAR DEFAULT NULL,
    name VARCHAR DEFAULT NULL,
    description VARCHAR DEFAULT NULL,
    status VARCHAR DEFAULT NULL,
    owner_id integer default null,
    --manufacturer VARCHAR DEFAULT NULL,
    --model VARCHAR DEFAULT NULL,
    manufacturer_info_id integer default null,
    technomapid_model varchar DEFAULT NULL,
    eos_model DATE DEFAULT NULL,
    serialnumber VARCHAR DEFAULT NULL,
    ipaddress cidr DEFAULT NULL,
    vip cidr[] DEFAULT NULL,
    firmware VARCHAR DEFAULT NULL,
    eos_software DATE DEFAULT NULL,
    short_name varchar default null,
    tags varchar[] default null
) TABLESPACE gsw_tbs_cmdb;
ALTER TABLE IF EXISTS cmdb.ds OWNER to gsw_datasetter;
COMMENT ON TABLE cmdb.ds IS 'Disks Storages';
COMMENT ON COLUMN cmdb.ds.owner_id IS 'employeeid from ad.accounts';