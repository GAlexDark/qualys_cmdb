/*
  Copyright (c) Oleksii Gaienko, 2021
  Contact: galexsoftware@gmail.com

  Module name: PostgreSQL(R) gsw_security_audit DB import file
  Author(s): Oleksii Gaienko
  Reviewer(s):

  Abstract:
     SQL file for import data into DB.
 */
drop table if exists import.ipphones;
CREATE TABLE IF NOT EXISTS import.ipphones (
    id SERIAL NOT NULL primary key,
    searchcode varchar default null,
    name varchar default null,
    description varchar default null,
    status varchar default null,
    owner varchar default null,
    serialnumber varchar default null,
    inventorynumber varchar default null,
    manufacturer varchar default null,
    model varchar default null,
    ipaddress varchar default null,
    firmware varchar default null,
    update_ownerid varchar default null,
    update_managerid varchar default null,
    datasource varchar default null,
    eos_model varchar default null,
    eos_software varchar default null
) TABLESPACE gsw_tbs_import;
ALTER TABLE IF EXISTS import.ipphones OWNER to gsw_datasetter;
COMMENT ON TABLE import.ipphones IS 'IP-Phones';
COMMENT ON COLUMN import.ipphones.owner IS 'employeeid from ad.accounts';

drop table if exists cmdb.ipphones;
CREATE TABLE IF NOT EXISTS cmdb.ipphones (
    id SERIAL NOT NULL primary key,
    searchcode varchar default null,
    name varchar default null,
    description varchar default null,
    status varchar default null,
    owner_id integer default null,
    serialnumber varchar default null,
    inventorynumber varchar default null,
    --manufacturer varchar default null,
    --model varchar default null,
    manufacturer_info_id integer default null,
    ipaddress cidr default null,
    firmware varchar default null,
    update_owner_id integer default null,
    update_manager_id integer default null,
    --datasource varchar default null,
    datasource_id integer default null,
    eos_model date default null,
    eos_software date default null,
    short_name varchar default null,
    tags varchar[] default null
) TABLESPACE gsw_tbs_cmdb;
ALTER TABLE IF EXISTS cmdb.ipphones OWNER to gsw_datasetter;
COMMENT ON TABLE cmdb.ipphones IS 'IP-Phones';
COMMENT ON COLUMN cmdb.ipphones.owner_id IS 'employeeid from ad.accounts';