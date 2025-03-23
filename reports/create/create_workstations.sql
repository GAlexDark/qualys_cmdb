/*
  Copyright (c) Oleksii Gaienko, 2021
  Contact: galexsoftware@gmail.com

  Module name: PostgreSQL(R) gsw_security_audit DB import file
  Author(s): Oleksii Gaienko
  Reviewer(s):

  Abstract:
     SQL file for import data into DB.
 */
 CREATE TABLE IF NOT EXISTS import.workstations (
    id SERIAL NOT NULL primary key,
    searchcode VARCHAR DEFAULT NULL,
    name VARCHAR DEFAULT NULL,
    description VARCHAR DEFAULT NULL,
    status VARCHAR DEFAULT NULL,
    manufacturer VARCHAR DEFAULT NULL,
    model VARCHAR DEFAULT NULL,
    serialnumber VARCHAR DEFAULT NULL,
    inventorynumber VARCHAR DEFAULT NULL,
    cpucores VARCHAR DEFAULT NULL,
    cpumodel VARCHAR DEFAULT NULL,
    cpucoretechnology VARCHAR DEFAULT NULL,
    cpufrequency VARCHAR DEFAULT NULL,
    ram VARCHAR DEFAULT NULL,
    ipaddress VARCHAR DEFAULT NULL,
    vip VARCHAR DEFAULT NULL,
    net VARCHAR DEFAULT NULL,
    os VARCHAR DEFAULT NULL,
    avsoft VARCHAR DEFAULT NULL,
    avversion VARCHAR DEFAULT NULL,
    eos_model VARCHAR DEFAULT NULL,
    eos_software VARCHAR DEFAULT NULL,
    has_ip_array bool default false
) TABLESPACE gsw_tbs_import;
ALTER TABLE IF EXISTS import.workstations OWNER to gsw_datasetter;
COMMENT ON TABLE import.workstations IS 'Workstations';

drop table if exists cmdb.workstations;
 CREATE TABLE IF NOT EXISTS cmdb.workstations (
    id SERIAL NOT NULL primary key,
    searchcode VARCHAR DEFAULT NULL,
    name VARCHAR DEFAULT NULL,
    description VARCHAR DEFAULT NULL,
    status VARCHAR DEFAULT NULL,
    --manufacturer VARCHAR DEFAULT NULL,
    --model VARCHAR DEFAULT NULL,
    manufacturer_info_id integer default null,
    serialnumber VARCHAR DEFAULT NULL,
    inventorynumber VARCHAR DEFAULT NULL,
    --cpucores VARCHAR DEFAULT NULL,
    --cpumodel VARCHAR DEFAULT NULL,
    --cpucoretechnology VARCHAR DEFAULT NULL,
    --cpufrequency VARCHAR DEFAULT NULL,
    --ram VARCHAR DEFAULT NULL,
    hardware_info_id integer default null,
    ipaddress cidr DEFAULT NULL,
    vip cidr[] DEFAULT NULL,
    net VARCHAR DEFAULT NULL,
    os VARCHAR DEFAULT NULL,
    --avsoft VARCHAR DEFAULT NULL,
    --avversion VARCHAR DEFAULT NULL,
    av_info_id integer default null,
    eos_model date DEFAULT NULL,
    eos_software date DEFAULT NULL,
    short_name VARCHAR DEFAULT NULL,
    tags VARCHAR[] DEFAULT NULL
) TABLESPACE gsw_tbs_cmdb;
ALTER TABLE IF EXISTS cmdb.workstations OWNER to gsw_datasetter;
COMMENT ON TABLE cmdb.workstations IS 'Workstations';
