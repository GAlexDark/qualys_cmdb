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
truncate table import.vmdr_irc_common_stat restart identity;
truncate table report.vmdr_irc_common_stat restart identity;
/*
 Import VMDR IRC common statistical data
 */
COPY import.vmdr_irc_common_stat(ipaddress, total_vulnerabilities, security_risk)
FROM '/import/datasource.csv'
WITH (format csv, delimiter ',', NULL '', header true, QUOTE '"', encoding 'UTF-8');

call import.parse_vmdr_irc_common_stat();

truncate table import.vmdr_irc_report restart identity;
truncate table qualys.vmdr_irc_base_report restart identity;
/*
 Import VMDR IRC vulnerability data
 */
COPY import.vmdr_irc_report(ip, dns, netbios, tracking_method, os, ip_status, qid, title, vuln_status, type,
                                 severity, port, protocol, fqdn, ssl, first_detected, last_detected, times_detected,
                                 date_last_fixed, cve_id, vendor_reference, bugtraq_id, cvss, cvss_base, cvss_temporal,
                                 cvss_environment, cvss3, cvss3_base, cvss3_temporal, threat, impact, pci_vuln, ticket_state,
                                 instance, category /*, associated_tags*/)
FROM '/import/datasource.csv'
WITH (format csv, delimiter ',', NULL '', header true, QUOTE '"', encoding 'UTF-8');

call import.parse_vmdr_irc_report();
call qualys.vmdr_irc_report(1, 0, 4, 5, '1_GSW_Dashboard_1m_Linux');
call qualys.vmdr_irc_report(2, 1, 4, 5, '2_GSW_Dashboard_2-1m_Linux');
call qualys.vmdr_irc_report(3, 1, 4, 5, '3_GSW_Dashboard_3-2m_Linux');
call qualys.vmdr_irc_report(4, 1, 4, 5, '4_GSW_Dashboard_4-3m_Linux');
call qualys.vmdr_irc_report(6, 2, 4, 5, '5_GSW_Dashboard_6-4m_Linux');
call qualys.vmdr_irc_report(6, -1, 4, 5, '6_GSW_Dashboard_-6m_Linux');
