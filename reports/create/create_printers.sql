/*
  Copyright (c) Oleksii Gaienko, 2021
  Contact: galexsoftware@gmail.com

  Module name: PostgreSQL(R) gsw_security_audit DB import file
  Author(s): Oleksii Gaienko
  Reviewer(s):

  Abstract:
     SQL file for import data into DB.
 */
 CREATE TABLE IF NOT EXISTS import.printers (
    id SERIAL NOT NULL primary key,
    searchcode varchar default null,
    name varchar default null,
    description varchar default null,
    status varchar default null,
    owner varchar default null,
    manufacturer varchar default null,
    model varchar default null,
    serialnumber varchar default null,
    ipaddress varchar default null,
    vip varchar default null,
    net varchar default null,
    inventorynumber varchar default null,
    userid varchar default null
) TABLESPACE gsw_tbs_import;
ALTER TABLE IF EXISTS import.printers OWNER to gsw_datasetter;
COMMENT ON TABLE import.printers IS 'Printers';
COMMENT ON COLUMN import.printers.owner IS 'employeeid from ad.accounts';

drop table if exists cmdb.printers;
CREATE TABLE IF NOT EXISTS cmdb.printers (
    id SERIAL NOT NULL primary key,
    searchcode varchar default null,
    name varchar default null,
    description varchar default null,
    status varchar default null,
    owner_id integer default null,
    --manufacturer varchar default null,
    --model varchar default null,
    manufacturer_info_id integer default null,
    serialnumber varchar default null,
    ipaddress cidr default null,
    vip cidr[] default null,
    net varchar default null,
    inventorynumber varchar default null,
    user_id integer default null,
    short_name varchar default null,
    tags varchar[] default null
) TABLESPACE gsw_tbs_cmdb;
ALTER TABLE IF EXISTS cmdb.printers OWNER to gsw_datasetter;
COMMENT ON TABLE cmdb.printers IS 'Printers';
COMMENT ON COLUMN cmdb.printers.owner_id IS 'employeeid from ad.accounts';