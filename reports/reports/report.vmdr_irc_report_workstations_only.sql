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
CREATE OR REPLACE PROCEDURE qualys.vmdr_irc_report_workstations_only(min_value_month integer, range_interval_month integer default 0,
                            min_severity integer default 0, max_severity integer default 0,
                            report_label varchar default null)
language PLPGSQL
AS $$
declare
    v_min_first_detected timestamptz;
    v_max_first_detected timestamptz;
    v_current_timestamp timestamptz;
    v_date_written date;
begin
    -- stored procedure body
    v_current_timestamp = now();
    --v_current_timestamp = '2022-04-28 19:10:25-07'::timestamptz;
    v_date_written = v_current_timestamp::date;

    --v_min_first_detected = date_trunc('month', now() - concat_ws(' ', min_value_month, 'month')::interval) + interval '15 days';
    v_min_first_detected = date_trunc('month', v_current_timestamp - concat_ws(' ', min_value_month, 'month')::interval) + interval '15 days';

    if (range_interval_month != -1) then
        if (range_interval_month = 0) then
            /*  */
            v_max_first_detected = v_current_timestamp;
        else
            v_max_first_detected = v_min_first_detected + concat_ws (' ', range_interval_month, 'month')::interval;
        end if;
    else
        /* v_min_first_detected - min value for first_detected */
        v_max_first_detected = v_min_first_detected;
        select min(vir.first_detected) into v_min_first_detected from qualys.vmdr_irc_base_report vir;
        v_min_first_detected = date_trunc('month', v_min_first_detected);
    end if;

    raise notice  'v_min_first_detected - %', v_min_first_detected;
    raise notice  'v_max_first_detected - %', v_max_first_detected;

    insert into report.vmdr_irc_aggregated_report (ipaddress, dns, netbios, tracking_method, os, ip_status,
                                                   qid, title, vuln_status, type, severity, ports, protocol, fqdn, ssl,
                                                   first_detected, last_detected, times_detected, date_last_fixed,
                                                   cve_info_id, cvss_info_id, cvss3_info_id, pci_vuln, ticket_state,
                                                   instance, category, label, short_name, date_written, associated_tags)
        select null, --vir.ipaddress, --qualys.ipadress_agg(vir.ipaddress),
               string_agg(distinct vir.dns, ','),
               string_agg(distinct vir.netbios, ','),
               string_agg(distinct vir.tracking_method, ','),
               string_agg(distinct vir.os, ','),
               qualys.array_agg(vir.ip_status),
               vir.qid,
               string_agg(distinct vir.title, ','),
               string_agg(distinct vir.vuln_status, ','),
               string_agg(distinct vir.type, ','),
               qualys.integer_agg(vir.severity),
               string_agg(distinct vir.port, ','),
               string_agg(distinct vir.protocol, ','),
               string_agg(distinct vir.fqdn, ','),
               string_agg(distinct vir.ssl, ','),
               min(vir.first_detected) as first_detected,
               max(vir.last_detected) as last_detected,
               sum(vir.times_detected) as times_detected,
               max(vir.date_last_fixed) as date_last_fixed,
               qualys.integer_agg(vir.cve_info_id) as cve_info_id,
               qualys.integer_agg(vir.cvss_info_id) as cvss_info_id,
               qualys.integer_agg(vir.cvss3_info_id) as cvss3_info_id,
               string_agg(distinct vir.pci_vuln, ','),
               string_agg(distinct vir.ticket_state, ','),
               string_agg(distinct vir.instance, ','),
               string_agg(distinct vir.category, ','),
               report_label,
               vir.short_name, --string_agg(distinct vir.short_name, ','),
               v_date_written,
               qualys.array_agg(vir.associated_tags)
        from qualys.vmdr_irc_base_report vir
        where vir.first_detected >= v_min_first_detected and
                vir.first_detected < v_max_first_detected and
                vir.severity >= min_severity and
                vir.severity <= max_severity
        group by vir.short_name, vir.qid;  --vir.ipaddress, vir.qid;

end;
$$;

alter procedure qualys.vmdr_irc_report_workstations_only(min_value_month integer, range_interval_month integer, min_severity integer, max_severity integer, report_label varchar) owner to gsw_datasetter;
--call qualys.vmdr_irc_report_workstations_only(range varchar, min_severity integer, max_severity integer, label varchar);