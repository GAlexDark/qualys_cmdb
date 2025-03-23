/*
  Copyright (c) Oleksii Gaienko, 2021
  Contact: galexsoftware@gmail.com

  Module name: PostgreSQL(R) gsw_security_audit DB import file
  Author(s): Oleksii Gaienko
  Reviewer(s):

  Abstract:
     SQL file for import data into DB.
 */
drop table if exists import.pbx;
CREATE TABLE IF NOT EXISTS import.pbx (
    id SERIAL NOT NULL primary key,
    searchcode VARCHAR default null,
    name VARCHAR default null,
    description VARCHAR default null,
    status VARCHAR default null,
    owner VARCHAR default null,
    manufacturer VARCHAR default null,
    model VARCHAR default null,
    serialnumber VARCHAR default null,
    inventorynumber VARCHAR default null,
    datasource VARCHAR default null,
    pbx_config VARCHAR default null,
    ipaddress VARCHAR default null,
    reliability_cat VARCHAR default null,
    vip VARCHAR default null,
    division_owner VARCHAR default null,
    division_owner_parent VARCHAR default null,
    division_owner_www VARCHAR default null,
    division_owner_mail VARCHAR default null,
    eos_model VARCHAR default null,
    eos_software VARCHAR default null,
    has_ip_array bool default false
) TABLESPACE gsw_tbs_import;
ALTER TABLE IF EXISTS import.pbx OWNER to gsw_datasetter;
COMMENT ON TABLE import.pbx IS 'PBX';
COMMENT ON COLUMN import.pbx.owner IS 'employeeid from ad.accounts';

drop table if exists cmdb.pbx;
CREATE TABLE IF NOT EXISTS cmdb.pbx (
    id SERIAL NOT NULL primary key,
    searchcode VARCHAR default null,
    name VARCHAR default null,
    description VARCHAR default null,
    status VARCHAR default null,
    owner_id INTEGER default null,
    --manufacturer VARCHAR default null,
    --model VARCHAR default null,
    manufacturer_info_id integer default null,
    serialnumber VARCHAR default null,
    inventorynumber VARCHAR default null,
    --datasource VARCHAR default null,
    datasource_id integer default null,
    pbx_config VARCHAR default null,
    ipaddress cidr default null,
    reliability_cat VARCHAR default null,
    vip cidr[] default null,
    division_owner VARCHAR default null,
    division_owner_parent VARCHAR default null,
    division_owner_www VARCHAR default null,
    division_owner_mail VARCHAR default null,
    eos_model date default null,
    eos_software date default null,
    short_name varchar default null,
    tags varchar[] default null
) TABLESPACE gsw_tbs_cmdb;
ALTER TABLE IF EXISTS cmdb.pbx OWNER to gsw_datasetter;
COMMENT ON TABLE cmdb.pbx IS 'PBX';
COMMENT ON COLUMN cmdb.pbx.owner_id IS 'employeeid from ad.accounts';