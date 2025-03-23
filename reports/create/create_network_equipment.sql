/*
  Copyright (c) Oleksii Gaienko, 2021
  Contact: galexsoftware@gmail.com

  Module name: PostgreSQL(R) gsw_security_audit DB import file
  Author(s): Oleksii Gaienko
  Reviewer(s):

  Abstract:
     SQL file for import data into DB.
 */
drop table if exists import.network_equipment;
CREATE TABLE IF NOT EXISTS import.network_equipment (
    id SERIAL NOT NULL primary key,
	searchcode VARCHAR DEFAULT NULL,
	name VARCHAR DEFAULT NULL,
	description VARCHAR DEFAULT NULL,
	status VARCHAR DEFAULT NULL,
	workgroup_templ VARCHAR DEFAULT NULL,
	owner VARCHAR DEFAULT NULL,
	model VARCHAR DEFAULT NULL,
	manufacturer VARCHAR DEFAULT NULL,
	location VARCHAR DEFAULT NULL,
	house VARCHAR DEFAULT NULL,
	room VARCHAR DEFAULT NULL,
	mac VARCHAR DEFAULT NULL,
	serialnumber VARCHAR DEFAULT NULL,
	inventorynumber VARCHAR DEFAULT NULL,
	type_of_equipment VARCHAR DEFAULT NULL,
	ipaddress VARCHAR DEFAULT NULL,
	vip VARCHAR DEFAULT NULL,
	firmware VARCHAR DEFAULT NULL,
	patchlevel VARCHAR DEFAULT NULL,
	eos_model VARCHAR DEFAULT NULL,
	eos_software VARCHAR DEFAULT NULL
) TABLESPACE gsw_tbs_import;
ALTER TABLE IF EXISTS import.network_equipment OWNER to gsw_datasetter;
COMMENT ON TABLE import.network_equipment IS 'Network Equipment';

drop table if exists cmdb.network_equipment;
CREATE TABLE IF NOT EXISTS cmdb.network_equipment (
    id SERIAL NOT NULL primary key,
	searchcode VARCHAR DEFAULT NULL,
	name VARCHAR DEFAULT NULL,
	description VARCHAR DEFAULT NULL,
	status VARCHAR DEFAULT NULL,
	workgroup_templ VARCHAR DEFAULT NULL,
	owner_id integer DEFAULT NULL,
	--model VARCHAR DEFAULT NULL,
	--manufacturer VARCHAR DEFAULT NULL,
	manufacturer_info_id integer default null,
	--location VARCHAR DEFAULT NULL,
	--house VARCHAR DEFAULT NULL,
	--room VARCHAR DEFAULT NULL,
	location_info_id integer default null,
	mac VARCHAR DEFAULT NULL,
	serialnumber VARCHAR DEFAULT NULL,
	inventorynumber VARCHAR DEFAULT NULL,
	type_of_equipment VARCHAR DEFAULT NULL,
	ipaddress cidr DEFAULT NULL,
	vip cidr[] DEFAULT NULL,
	firmware VARCHAR DEFAULT NULL,
	patchlevel VARCHAR DEFAULT NULL,
	eos_model date DEFAULT NULL,
	eos_software date DEFAULT NULL,
    short_name VARCHAR DEFAULT NULL,
    tags VARCHAR[] DEFAULT NULL
) TABLESPACE gsw_tbs_cmdb;
ALTER TABLE IF EXISTS cmdb.network_equipment OWNER to gsw_datasetter;
COMMENT ON TABLE cmdb.network_equipment IS 'Network Equipment';
