/*
  Copyright (c) Oleksii Gaienko, 2021
  Contact: galexsoftware@gmail.com

  Module name: PostgreSQL(R) gsw_security_audit DB import file
  Author(s): Oleksii Gaienko
  Reviewer(s):

  Abstract:
     SQL file for import data into DB.
 */
drop table if exists import.physical_servers;
CREATE TABLE import.physical_servers (
    id SERIAL NOT NULL primary key,
    searchcode VARCHAR DEFAULT NULL,
    name VARCHAR DEFAULT NULL,
    description VARCHAR DEFAULT NULL,
    status VARCHAR DEFAULT NULL,
    owner VARCHAR DEFAULT NULL,
    manufacturer VARCHAR DEFAULT NULL,
    model VARCHAR DEFAULT NULL,
    eos_model VARCHAR DEFAULT NULL,
    serialnumber VARCHAR DEFAULT NULL,
    inventorynumber VARCHAR DEFAULT NULL,
    cpucores VARCHAR DEFAULT NULL,
    cpumodel VARCHAR DEFAULT NULL,
    cpucoretechnology VARCHAR DEFAULT NULL,
    cpufrequency VARCHAR DEFAULT NULL,
    ram VARCHAR DEFAULT NULL,
    location VARCHAR DEFAULT NULL,
    house VARCHAR DEFAULT NULL,
    ipaddress VARCHAR DEFAULT NULL,
    vip VARCHAR DEFAULT NULL,
    os VARCHAR DEFAULT NULL,
    eos_software VARCHAR DEFAULT NULL,
    avsoft VARCHAR DEFAULT NULL,
    avversion VARCHAR DEFAULT NULL,
    datasource VARCHAR DEFAULT NULL
) TABLESPACE gsw_tbs_import;
ALTER TABLE IF EXISTS import.physical_servers OWNER to gsw_datasetter;
COMMENT ON TABLE import.physical_servers IS 'Physical servers';
COMMENT ON COLUMN import.physical_servers.owner IS 'employeeid from ad.accounts';
COMMENT ON COLUMN import.physical_servers.status IS 'ToDo: change VARCHAR to INTEGER';

drop table if exists cmdb.physical_servers;
CREATE TABLE cmdb.physical_servers (
    id SERIAL NOT NULL primary key,
    searchcode VARCHAR DEFAULT NULL,
    name VARCHAR DEFAULT NULL,
    description VARCHAR DEFAULT NULL,
    status VARCHAR DEFAULT NULL,
    owner_id INTEGER DEFAULT NULL,
    --manufacturer VARCHAR DEFAULT NULL,
    --model VARCHAR DEFAULT NULL,
    manufacturer_info_id integer default null,
    eos_model DATE DEFAULT NULL,
    serialnumber VARCHAR DEFAULT NULL,
    inventorynumber VARCHAR DEFAULT NULL,
    --cpucores VARCHAR DEFAULT NULL,
    --cpumodel VARCHAR DEFAULT NULL,
    --cpucoretechnology VARCHAR DEFAULT NULL,
    --cpufrequency VARCHAR DEFAULT NULL,
    --ram VARCHAR DEFAULT NULL,
    hardware_info_id integer default null,
    --location VARCHAR DEFAULT NULL,
    --house VARCHAR DEFAULT NULL,
    location_info_id integer default null,
    ipaddress cidr DEFAULT NULL,
    vip cidr[] DEFAULT NULL,
    os VARCHAR DEFAULT NULL,
    eos_software DATE DEFAULT NULL,
    --avsoft VARCHAR DEFAULT NULL,
    --avversion VARCHAR DEFAULT NULL,
    av_info_id integer default null,
    --datasource VARCHAR DEFAULT NULL,
    datasource_id integer default null,
    short_name VARCHAR DEFAULT NULL,
    tags VARCHAR[] DEFAULT NULL
) TABLESPACE gsw_tbs_cmdb;
ALTER TABLE IF EXISTS cmdb.physical_servers OWNER to gsw_datasetter;
COMMENT ON TABLE cmdb.physical_servers IS 'Physical servers';
COMMENT ON COLUMN cmdb.physical_servers.owner_id IS 'employeeid from ad.accounts';
COMMENT ON COLUMN cmdb.physical_servers.status IS 'ToDo: change VARCHAR to INTEGER';