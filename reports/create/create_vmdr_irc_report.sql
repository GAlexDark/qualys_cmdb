/*
  Copyright (c) Oleksii Gaienko, 2021
  Contact: galexsoftware@gmail.com

  Module name: PostgreSQL(R) gsw_security_audit DB import file
  Author(s): Oleksii Gaienko
  Reviewer(s):

  Abstract:
     SQL file for import data into DB.
 */
drop table if exists import.vmdr_irc_report;
CREATE TABLE IF NOT EXISTS import.vmdr_irc_report (
    id SERIAL NOT NULL primary key,
    ip VARCHAR DEFAULT NULL,
    dns VARCHAR DEFAULT NULL,
    netbios VARCHAR DEFAULT NULL,
    tracking_method VARCHAR DEFAULT NULL,
    os VARCHAR DEFAULT NULL,
    ip_status VARCHAR DEFAULT NULL,
    qid VARCHAR DEFAULT NULL,
    title VARCHAR DEFAULT NULL,
    vuln_status VARCHAR DEFAULT NULL,
    type VARCHAR DEFAULT NULL,
    severity VARCHAR DEFAULT NULL,
    port VARCHAR DEFAULT NULL,
    protocol VARCHAR DEFAULT NULL,
    fqdn VARCHAR DEFAULT NULL,
    ssl VARCHAR DEFAULT NULL,
    first_detected VARCHAR DEFAULT NULL,
    last_detected VARCHAR DEFAULT NULL,
    times_detected VARCHAR DEFAULT NULL,
    date_last_fixed VARCHAR DEFAULT NULL,
    cve_id VARCHAR DEFAULT NULL,
    vendor_reference VARCHAR DEFAULT NULL,
    bugtraq_id VARCHAR DEFAULT NULL,
    cvss VARCHAR DEFAULT NULL,
    cvss_base VARCHAR DEFAULT NULL,
    cvss_temporal VARCHAR DEFAULT NULL,
    cvss_environment VARCHAR DEFAULT NULL,
    cvss3 VARCHAR DEFAULT NULL,
    cvss3_base VARCHAR DEFAULT NULL,
    cvss3_temporal VARCHAR DEFAULT NULL,
    threat VARCHAR DEFAULT NULL,
    impact VARCHAR DEFAULT NULL,
    pci_vuln VARCHAR DEFAULT NULL,
    ticket_state VARCHAR DEFAULT NULL,
    instance VARCHAR DEFAULT NULL,
    category VARCHAR DEFAULT NULL,
    associated_tags VARCHAR DEFAULT NULL,
    QDS varchar default null,
    ARS varchar default null,
    ACS varchar default null
) TABLESPACE gsw_tbs_import;
ALTER TABLE IF EXISTS import.vmdr_irc_report OWNER to gsw_datasetter;
COMMENT ON TABLE import.vmdr_irc_report IS 'VMDR IRC report';

drop table if exists qualys.vmdr_irc_base_report;
CREATE TABLE IF NOT EXISTS qualys.vmdr_irc_base_report (
    id SERIAL NOT NULL primary key,
    ipaddress cidr DEFAULT NULL,
    dns VARCHAR DEFAULT NULL,
    short_name VARCHAR DEFAULT NULL,
    netbios VARCHAR DEFAULT NULL,
    tracking_method VARCHAR DEFAULT NULL,
    os VARCHAR DEFAULT NULL,
    ip_status VARCHAR[] DEFAULT NULL,
    qid INTEGER DEFAULT NULL,
    title VARCHAR DEFAULT NULL,
    vuln_status VARCHAR DEFAULT NULL,
    type VARCHAR DEFAULT NULL,
    severity INTEGER DEFAULT NULL,
    port varchar DEFAULT NULL,
    protocol VARCHAR DEFAULT NULL,
    fqdn VARCHAR DEFAULT NULL,
    ssl VARCHAR DEFAULT NULL,
    first_detected timestamptz DEFAULT NULL, --MM/DD/YYYY HH:MM:SS
    last_detected timestamptz DEFAULT NULL, --MM/DD/YYYY HH:MM:SS
    times_detected INTEGER DEFAULT NULL,
    date_last_fixed timestamptz DEFAULT NULL, --MM/DD/YYYY HH:MM:SS
    --cve_id VARCHAR[] DEFAULT NULL,
    --vendor_reference VARCHAR DEFAULT NULL,
    --bugtraq_id INTEGER[] DEFAULT NULL,
    cve_info_id integer default null,
    --cvss VARCHAR DEFAULT NULL,
    --cvss_base VARCHAR DEFAULT NULL,
    --cvss_temporal VARCHAR DEFAULT NULL,
    --cvss_environment VARCHAR DEFAULT NULL,
    cvss_info_id integer default null,
    --cvss3 VARCHAR DEFAULT NULL,
    --cvss3_base VARCHAR DEFAULT NULL,
    --cvss3_temporal VARCHAR DEFAULT NULL,
    cvss3_info_id integer default null,
    --threat VARCHAR DEFAULT NULL, --cve_info_id
    --impact VARCHAR DEFAULT NULL, --cve_info_id
    pci_vuln VARCHAR DEFAULT NULL,
    ticket_state VARCHAR DEFAULT NULL,
    instance VARCHAR DEFAULT NULL,
    category VARCHAR DEFAULT NULL,
    to_aggregate boolean default false,
    associated_tags VARCHAR[] DEFAULT NULL
) TABLESPACE gsw_tbs_qualys;
ALTER TABLE IF EXISTS qualys.vmdr_irc_base_report OWNER to gsw_datasetter;
COMMENT ON TABLE qualys.vmdr_irc_base_report IS 'VMDR IRC base report';

drop table if exists report.vmdr_irc_aggregated_report;
CREATE TABLE IF NOT EXISTS report.vmdr_irc_aggregated_report (
    id SERIAL NOT NULL primary key,
    ipaddress cidr DEFAULT NULL,
    dns VARCHAR DEFAULT NULL,
    netbios VARCHAR DEFAULT NULL,
    tracking_method VARCHAR DEFAULT NULL,
    os VARCHAR DEFAULT NULL,
    ip_status VARCHAR[] DEFAULT NULL,
    qid INTEGER DEFAULT NULL,
    title VARCHAR DEFAULT NULL,
    vuln_status VARCHAR DEFAULT NULL,
    type VARCHAR DEFAULT NULL,
    severity INTEGER DEFAULT NULL,
    --port INTEGER DEFAULT NULL,
    ports varchar default null,
    protocol VARCHAR DEFAULT NULL,
    fqdn VARCHAR DEFAULT NULL,
    ssl VARCHAR DEFAULT NULL,
    first_detected timestamptz DEFAULT NULL, --MM/DD/YYYY HH:MM:SS
    last_detected timestamptz DEFAULT NULL, --MM/DD/YYYY HH:MM:SS
    times_detected INTEGER DEFAULT NULL,
    date_last_fixed timestamptz DEFAULT NULL, --MM/DD/YYYY HH:MM:SS
    cve_info_id integer default null,
    cvss_info_id integer default null,
    cvss3_info_id integer default null,
    pci_vuln VARCHAR DEFAULT NULL,
    ticket_state VARCHAR DEFAULT NULL,
    instance VARCHAR DEFAULT NULL,
    category VARCHAR DEFAULT NULL,
    label varchar default null,
    short_name VARCHAR DEFAULT NULL,
    date_written date default null,
    associated_tags VARCHAR[] DEFAULT NULL
) TABLESPACE gsw_tbs_qualys;
ALTER TABLE IF EXISTS report.vmdr_irc_aggregated_report OWNER to gsw_datasetter;
COMMENT ON TABLE report.vmdr_irc_aggregated_report IS 'VMDR IRC aggregeted report';