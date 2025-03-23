/*
  Copyright (c) Oleksii Gaienko, 2021
  Contact: galexsoftware@gmail.com

  Module name: PostgreSQL(R) gsw_security_audit DB parse file
  Author(s): Oleksii Gaienko
  Reviewer(s):

  Abstract:
     SQL file with source code for parsing data in DB.

  Version: 2

 */

create or replace view report.view_vmdr_irc_aggregeted_report
            (ipaddress, dns, netbios, tracking_method, os, ip_status, qid, title, vuln_status, type,
                                 severity, ports, protocol, fqdn, ssl, first_detected, last_detected, times_detected,
                                 date_last_fixed, cve_id, vendor_reference, bugtraq_id, cvss, cvss_base, cvss_temporal,
                                 cvss_environment, cvss3, cvss3_base, cvss3_temporal, threat, impact, pci_vuln, ticket_state,
                                 instance, category, label, short_name, date_written, associated_tags) as
SELECT
       ar.ipaddress as ipaddress,
       ar.dns as dns,
       ar.netbios as netbios,
       ar.tracking_method as tracking_method,
       ar.os as os,
       ar.ip_status as ip_status,
       ar.qid as qid,
       ar.title as title,
       ar.vuln_status as vuln_status,
       ar.type as type,
       ar.severity as severity,
       ar.ports as ports,
       ar.protocol as protocol,
       ar.fqdn as fqdn,
       ar.ssl as ssl,
       ar.first_detected as first_detected,
       ar.last_detected as last_detected,
       ar.times_detected as times_detected,
       ar.date_last_fixed as date_last_fixed,
       cvei.cve_id as cve_id,
       cvei.vendor_reference as vendor_reference,
       cvei.bugtraq_id as bugtraq_id,

       cvsi.cvss as cvss,
       cvsi.cvss_base as cvss_base,
       cvsi.cvss_temporal as cvss_temporal,
       cvsi.cvss_environment as cvss_environment,
       cv3i.cvss3 as cvss3,
       cv3i.cvss3_base as cvss3_base,
       cv3i.cvss3_temporal as cvss3_temporal,

       cvei.threat as threat,
       cvei.impact as impact,

       ar.pci_vuln as pci_vuln,
       ar.ticket_state as ticket_state,
       ar.instance as instance,
       ar.category as category,
       ar.label as label,
       ar.short_name,
       ar.date_written as date_written,
       ar.associated_tags as associated_tags
from report.vmdr_irc_aggregated_report ar,
     qualys.cve_info cvei,
     qualys.cvss_info cvsi,
     qualys.cvss3_info cv3i
where ar.cve_info_id = cvei.id and
      ar.cvss_info_id = cvsi.id and
      ar.cvss3_info_id = cv3i.id
order by ar.first_detected asc ;


alter view report.view_vmdr_irc_aggregeted_report owner to gsw_datasetter;
grant select on report.view_vmdr_irc_aggregeted_report to gsw_reporter;

