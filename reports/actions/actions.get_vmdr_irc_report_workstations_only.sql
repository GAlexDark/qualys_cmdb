/*
  Copyright (c) Oleksii Gaienko, 2021
  Contact: galexsoftware@gmail.com

  Module name: PostgreSQL(R) gsw_security_audit DB import file
  Author(s): Oleksii Gaienko
  Reviewer(s):

  Abstract:
     Get report

 */
SET TIME ZONE 'Europe/Kiev';
truncate table import.vmdr_irc_report restart identity;
truncate table qualys.vmdr_irc_base_report restart identity;
/*
 Import VMDR IRC vulnerability data
 */
COPY import.vmdr_irc_report(ip, dns, netbios, tracking_method, os, ip_status, qid, title, vuln_status, type,
                                 severity, port, protocol, fqdn, ssl, first_detected, last_detected, times_detected,
                                 date_last_fixed, cve_id, vendor_reference, bugtraq_id, cvss, cvss_base, cvss_temporal,
                                 cvss_environment, cvss3, cvss3_base, cvss3_temporal, threat, impact, pci_vuln, ticket_state,
                                 instance, category, associated_tags)
FROM '/import/datasource.csv'
WITH (format csv, delimiter ',', NULL '', header true, QUOTE '"', encoding 'UTF-8');

call import.parse_vmdr_irc_report();
call qualys.vmdr_irc_report_workstations_only(1, 0, 4, 5, 'GSW_Dashboard_Workstations1_1m');
call qualys.vmdr_irc_report_workstations_only(2, 1, 4, 5, 'GSW_Dashboard_Workstations2_2-1m');
call qualys.vmdr_irc_report_workstations_only(3, 1, 4, 5, 'GSW_Dashboard_Workstations3_3-2m');
call qualys.vmdr_irc_report_workstations_only(4, 1, 4, 5, 'GSW_Dashboard_Workstations4_4-3m');
call qualys.vmdr_irc_report_workstations_only(6, 2, 4, 5, 'GSW_Dashboard_Workstations5_6-4m');
call qualys.vmdr_irc_report_workstations_only(6, -1, 4, 5, 'GSW_Dashboard_Workstations6_-6m');
