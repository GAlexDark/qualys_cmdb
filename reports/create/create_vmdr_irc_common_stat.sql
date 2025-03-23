/*
  Copyright (c) Oleksii Gaienko, 2021
  Contact: galexsoftware@gmail.com

  Module name: PostgreSQL(R) gsw_security_audit DB import file
  Author(s): Oleksii Gaienko
  Reviewer(s):

  Abstract:
     SQL file for import data into DB.
 */
drop table if exists import.vmdr_irc_common_stat;
CREATE TABLE IF NOT EXISTS import.vmdr_irc_common_stat (
    id SERIAL NOT NULL primary key,
    ipaddress VARCHAR DEFAULT NULL,
    total_vulnerabilities VARCHAR DEFAULT NULL,
    security_risk VARCHAR DEFAULT NULL
) TABLESPACE gsw_tbs_import;
ALTER TABLE IF EXISTS import.vmdr_irc_common_stat OWNER to gsw_datasetter;
COMMENT ON TABLE import.vmdr_irc_common_stat IS 'VMDR IRC common statictics';

drop table if exists report.vmdr_irc_common_stat;
CREATE TABLE IF NOT EXISTS report.vmdr_irc_common_stat (
    id SERIAL NOT NULL primary key,
    ipaddress cidr,
    total_vulnerabilities integer,
    security_risk REAL,
    date_written date
) TABLESPACE gsw_tbs_report;
ALTER TABLE IF EXISTS report.vmdr_irc_common_stat OWNER to gsw_datasetter;
COMMENT ON TABLE report.vmdr_irc_common_stat IS 'VMDR IRC common statictics';
