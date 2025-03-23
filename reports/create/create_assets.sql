/*
  Copyright (c) Oleksii Gaienko, 2021
  Contact: galexsoftware@gmail.com

  Module name: PostgreSQL(R) gsw_security_audit DB import file
  Author(s): Oleksii Gaienko
  Reviewer(s):

  Abstract:
     SQL file for import data into DB.
 */

drop table if exists import.assets;
CREATE TABLE IF NOT EXISTS import.assets (
    id SERIAL NOT NULL primary key,
    asset_id VARCHAR DEFAULT NULL,
    name VARCHAR DEFAULT NULL,
    ipaddress VARCHAR DEFAULT NULL,
    modules VARCHAR DEFAULT NULL,
    os VARCHAR DEFAULT NULL,
    last_logged_in_user VARCHAR DEFAULT NULL,
    last_inventory VARCHAR DEFAULT NULL,
    activity VARCHAR DEFAULT NULL,
    netbios_name VARCHAR DEFAULT NULL,
    sources VARCHAR DEFAULT NULL,
    tags varchar DEFAULT NULL,
    has_ip_array bool default false
) TABLESPACE gsw_tbs_import;
ALTER TABLE IF EXISTS import.assets OWNER to gsw_datasetter;
COMMENT ON TABLE import.assets IS 'Assets from Qualys report';

drop table if exists qualys.assets;
CREATE TABLE IF NOT EXISTS qualys.assets (
    id SERIAL NOT NULL primary key,
    asset_id bigint not null,
    name VARCHAR,
    ipaddress cidr,
    modules VARCHAR[],
    os VARCHAR,
    last_logged_in_user VARCHAR,
    last_inventory timestamptz,
    activity VARCHAR,
    netbios_name VARCHAR,
    sources VARCHAR,
    short_name VARCHAR,
    tags varchar[]
) TABLESPACE gsw_tbs_qualys;
ALTER TABLE IF EXISTS qualys.assets OWNER to gsw_datasetter;
COMMENT ON TABLE qualys.assets IS 'Assets from Qualys report';
COMMENT ON COLUMN qualys.assets.last_logged_in_user IS '(?) Field for QID 90925 or Qualys Cloud agent gathering info';
COMMENT ON COLUMN qualys.assets.short_name IS 'asset name without domain name';
