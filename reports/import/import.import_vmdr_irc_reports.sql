/*
  Copyright (c) Oleksii Gaienko, 2021
  Contact: galexsoftware@gmail.com

  Module name: PostgreSQL(R) gsw_security_audit DB import file
  Author(s): Oleksii Gaienko
  Reviewer(s):

  Abstract:
     SQL file for import data into DB.

 */
SET TIME ZONE 'Europe/Kiev';
truncate table import.vmdr_irc_common_stat restart identity;
truncate table report.vmdr_irc_common_stat restart identity;

COPY import.vmdr_irc_common_stat(ipaddress, total_vulnerabilities, security_risk)
FROM '/import/datasource.csv'
WITH (format csv, delimiter ',', NULL '', header true, QUOTE '"', encoding 'UTF-8');

call import.parse_vmdr_irc_common_stat();

truncate table import.vmdr_irc_report restart identity;
truncate table qualys.vmdr_irc_base_report restart identity;

