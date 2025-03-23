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
/* temp */
truncate table report.vmdr_irc_aggregated_report restart identity;
/* temp */
truncate table import.vmdr_irc_report restart identity;
truncate table qualys.vmdr_irc_base_report restart identity;
/*
 Import VMDR IRC vulnerability data
 */
COPY import.vmdr_irc_report(ip, dns, netbios, tracking_method, os, ip_status, qid, title, vuln_status, type,
                                 severity, port, protocol, fqdn, ssl, first_detected, last_detected, times_detected,
                                 date_last_fixed, cve_id, vendor_reference, bugtraq_id, cvss, cvss_base, cvss_temporal,
                                 cvss_environment, cvss3, cvss3_base, cvss3_temporal, threat, impact, pci_vuln, ticket_state,
                                 instance, category /*, associated_tags*/, qds, ars, acs)
FROM '/import/datasource.csv'
WITH (format csv, delimiter ',', NULL '', header true, QUOTE '"', encoding 'UTF-8');

call import.parse_vmdr_irc_report();
call qualys.vmdr_irc_report(1, 0, 4, 5, 'GSW_Dashboard_Windows_Servers1_1m');
call qualys.vmdr_irc_report(2, 1, 4, 5, 'GSW_Dashboard_Windows_Servers2_2-1m');
call qualys.vmdr_irc_report(3, 1, 4, 5, 'GSW_Dashboard_Windows_Servers3_3-2m');
call qualys.vmdr_irc_report(4, 1, 4, 5, 'GSW_Dashboard_Windows_Servers4_4-3m');
call qualys.vmdr_irc_report(6, 2, 4, 5, 'GSW_Dashboard_Windows_Servers5_6-4m');
call qualys.vmdr_irc_report(6, -1, 4, 5, 'GSW_Dashboard_Windows_Servers6_-6m');

truncate table import.vmdr_irc_report restart identity;
truncate table qualys.vmdr_irc_base_report restart identity;
/*
 Import VMDR IRC vulnerability data
 */
COPY import.vmdr_irc_report(ip, dns, netbios, tracking_method, os, ip_status, qid, title, vuln_status, type,
                                 severity, port, protocol, fqdn, ssl, first_detected, last_detected, times_detected,
                                 date_last_fixed, cve_id, vendor_reference, bugtraq_id, cvss, cvss_base, cvss_temporal,
                                 cvss_environment, cvss3, cvss3_base, cvss3_temporal, threat, impact, pci_vuln, ticket_state,
                                 instance, category /*, associated_tags*/, qds, ars, acs)
FROM '/import/datasource.csv'
WITH (format csv, delimiter ',', NULL '', header true, QUOTE '"', encoding 'UTF-8');

call import.parse_vmdr_irc_report();
call qualys.vmdr_irc_report(1, 0, 4, 5, 'GSW_Dashboard_Linux_Servers1_1m');
call qualys.vmdr_irc_report(2, 1, 4, 5, 'GSW_Dashboard_Linux_Servers2_2-1m');
call qualys.vmdr_irc_report(3, 1, 4, 5, 'GSW_Dashboard_Linux_Servers3_3-2m');
call qualys.vmdr_irc_report(4, 1, 4, 5, 'GSW_Dashboard_Linux_Servers4_4-3m');
call qualys.vmdr_irc_report(6, 2, 4, 5, 'GSW_Dashboard_Linux_Servers5_6-4m');
call qualys.vmdr_irc_report(6, -1, 4, 5, 'GSW_Dashboard_Linux_Servers6_-6m');

truncate table import.vmdr_irc_report restart identity;
truncate table qualys.vmdr_irc_base_report restart identity;
/*
 Import VMDR IRC vulnerability data
 */
COPY import.vmdr_irc_report(ip, dns, netbios, tracking_method, os, ip_status, qid, title, vuln_status, type,
                                 severity, port, protocol, fqdn, ssl, first_detected, last_detected, times_detected,
                                 date_last_fixed, cve_id, vendor_reference, bugtraq_id, cvss, cvss_base, cvss_temporal,
                                 cvss_environment, cvss3, cvss3_base, cvss3_temporal, threat, impact, pci_vuln, ticket_state,
                                 instance, category, associated_tags, qds, ars, acs)
FROM '/import/datasource.csv'
WITH (format csv, delimiter ',', NULL '', header true, QUOTE '"', encoding 'UTF-8');

call import.parse_vmdr_irc_report();
/*
call qualys.vmdr_irc_report(1, 0, 4, 5, 'GSW_Dashboard_Workstations1_1m');
call qualys.vmdr_irc_report(2, 1, 4, 5, 'GSW_Dashboard_Workstations2_2-1m');
call qualys.vmdr_irc_report(3, 1, 4, 5, 'GSW_Dashboard_Workstations3_3-2m');
call qualys.vmdr_irc_report(4, 1, 4, 5, 'GSW_Dashboard_Workstations4_4-3m');
call qualys.vmdr_irc_report(6, 2, 4, 5, 'GSW_Dashboard_Workstations5_6-4m');
call qualys.vmdr_irc_report(6, -1, 4, 5, 'GSW_Dashboard_Workstations6_-6m');
*/
call qualys.vmdr_irc_report_workstations_only(1, 0, 4, 5, 'GSW_Dashboard_Workstations1_1m');
call qualys.vmdr_irc_report_workstations_only(2, 1, 4, 5, 'GSW_Dashboard_Workstations2_2-1m');
call qualys.vmdr_irc_report_workstations_only(3, 1, 4, 5, 'GSW_Dashboard_Workstations3_3-2m');
call qualys.vmdr_irc_report_workstations_only(4, 1, 4, 5, 'GSW_Dashboard_Workstations4_4-3m');
call qualys.vmdr_irc_report_workstations_only(6, 2, 4, 5, 'GSW_Dashboard_Workstations5_6-4m');
call qualys.vmdr_irc_report_workstations_only(6, -1, 4, 5, 'GSW_Dashboard_Workstations6_-6m');

truncate table import.vmdr_irc_report restart identity;
truncate table qualys.vmdr_irc_base_report restart identity;
/*
 Import VMDR IRC vulnerability data
 */

COPY import.vmdr_irc_report(ip, dns, netbios, tracking_method, os, ip_status, qid, title, vuln_status, type,

                                 severity, port, protocol, fqdn, ssl, first_detected, last_detected, times_detected,
                                 date_last_fixed, cve_id, vendor_reference, bugtraq_id, cvss, cvss_base, cvss_temporal,
                                 cvss_environment, cvss3, cvss3_base, cvss3_temporal, threat, impact, pci_vuln, ticket_state,
                                 instance, category /*, associated_tags*/, qds, ars, acs)
FROM '/import/datasource.csv'
WITH (format csv, delimiter ',', NULL '', header true, QUOTE '"', encoding 'UTF-8');

call import.parse_vmdr_irc_report();
call qualys.vmdr_irc_report(1, 0, 4, 5, 'GSW_Dashboard_Hypervisors1_1m');
call qualys.vmdr_irc_report(2, 1, 4, 5, 'GSW_Dashboard_Hypervisors2_2-1m');
call qualys.vmdr_irc_report(3, 1, 4, 5, 'GSW_Dashboard_Hypervisors3_3-2m');
call qualys.vmdr_irc_report(4, 1, 4, 5, 'GSW_Dashboard_Hypervisors4_4-3m');
call qualys.vmdr_irc_report(6, 2, 4, 5, 'GSW_Dashboard_Hypervisors5_6-4m');
call qualys.vmdr_irc_report(6, -1, 4, 5, 'GSW_Dashboard_Hypervisors6_-6m');

truncate table import.vmdr_irc_report restart identity;
truncate table qualys.vmdr_irc_base_report restart identity;
/*
 Import VMDR IRC vulnerability data
 */

COPY import.vmdr_irc_report(ip, dns, netbios, tracking_method, os, ip_status, qid, title, vuln_status, type,

                                 severity, port, protocol, fqdn, ssl, first_detected, last_detected, times_detected,
                                 date_last_fixed, cve_id, vendor_reference, bugtraq_id, cvss, cvss_base, cvss_temporal,
                                 cvss_environment, cvss3, cvss3_base, cvss3_temporal, threat, impact, pci_vuln, ticket_state,
                                 instance, category /*, associated_tags*/, qds, ars, acs)
FROM '/import/datasource.csv'
WITH (format csv, delimiter ',', NULL '', header true, QUOTE '"', encoding 'UTF-8');

call import.parse_vmdr_irc_report();
call qualys.vmdr_irc_report(1, 0, 4, 5, 'GSW_Dashboard_Middleware1_1m');
call qualys.vmdr_irc_report(2, 1, 4, 5, 'GSW_Dashboard_Middleware2_2-1m');
call qualys.vmdr_irc_report(3, 1, 4, 5, 'GSW_Dashboard_Middleware3_3-2m');
call qualys.vmdr_irc_report(4, 1, 4, 5, 'GSW_Dashboard_Middleware4_4-3m');
call qualys.vmdr_irc_report(6, 2, 4, 5, 'GSW_Dashboard_Middleware5_6-4m');
call qualys.vmdr_irc_report(6, -1, 4, 5, 'GSW_Dashboard_Middleware6_-6m');