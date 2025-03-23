/*
  Copyright (c) Oleksii Gaienko, 2021
  Contact: galexsoftware@gmail.com

  Module name: PostgreSQL(R) gsw_security_audit DB import file
  Author(s): Oleksii Gaienko
  Reviewer(s):

  Abstract:
     SQL file for import data into DB.
 */
drop table if exists import.typelib;
CREATE TABLE IF NOT EXISTS import.typelib (
    id SERIAL NOT NULL primary key,
    searchcode varchar default null,
    name varchar default null,
    description varchar default null,
    status varchar default null,
    owner varchar default null,
    ipaddress varchar default null,
    vip varchar default null,
    manufacturer varchar default null,
    model varchar default null
) TABLESPACE gsw_tbs_import;
ALTER TABLE IF EXISTS import.typelib OWNER to gsw_datasetter;
COMMENT ON TABLE import.typelib IS 'Tape Library';
COMMENT ON COLUMN import.typelib.owner IS 'employeeid from ad.accounts';

drop table if exists cmdb.typelib;
CREATE TABLE IF NOT EXISTS cmdb.typelib (
    id SERIAL NOT NULL primary key,
    searchcode varchar default null,
    name varchar default null,
    description varchar default null,
    status varchar default null,
    owner_id INTEGER default null,
    ipaddress cidr default null,
    vip cidr[] default null,
    --manufacturer varchar default null,
    --model varchar default null,
    manufacturer_info_id integer default null,
    short_name varchar default null,
    tags varchar[] default null
) TABLESPACE gsw_tbs_cmdb;
ALTER TABLE IF EXISTS cmdb.typelib OWNER to gsw_datasetter;
COMMENT ON TABLE cmdb.typelib IS 'Tape Library';
COMMENT ON COLUMN cmdb.typelib.owner_id IS 'employeeid from ad.accounts';