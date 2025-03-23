/*
  Copyright (c) Oleksii Gaienko, 2021
  Contact: galexsoftware@gmail.com

  Module name: PostgreSQL(R) gsw_security_audit DB parse file
  Author(s): Oleksii Gaienko
  Reviewer(s):

  Abstract:
     SQL file with source code for parsing data in DB.
 */
CREATE OR REPLACE PROCEDURE import.parse_vmdr_irc_report()
    language plpgsql
as
$$
declare
    v_ip varchar;
    v_ipaddress cidr;
    v_dns varchar;
    v_netbios varchar;
    v_tracking_method varchar;
    v_os varchar;
    v_ip_status varchar;
    v_ip_status_array varchar[];
    v_qid varchar;
    v_qid1 integer;
    v_title varchar;
    v_vuln_status varchar;
    v_type varchar;
    v_severity varchar;
    v_severity1 integer;
    v_port varchar;
    --v_port1 integer;
    v_protocol varchar;
    v_fqdn varchar;
    v_ssl varchar;
    v_first_detected varchar;
    v_first_detected_ts timestamptz;
    v_last_detected varchar;
    v_last_detected_ts timestamptz;
    v_times_detected varchar;
    v_times_detected1 integer;
    v_date_last_fixed varchar;
    v_date_last_fixed_ts timestamptz;
    v_cve_id varchar;
    v_cve_id_array varchar[];
    v_vendor_reference varchar;
    v_bugtraq_id varchar;
    v_bugtraq_id_array integer[];
    v_cvss varchar;
    v_cvss_base varchar;
    v_cvss_temporal varchar;
    v_cvss_environment varchar;
    --v_cvss_environment_array varchar[];
    v_cvss3 varchar;
    v_cvss3_base varchar;
    v_cvss3_temporal varchar;
    v_threat varchar;
    v_impact varchar;
    v_pci_vuln varchar;
    v_ticket_state varchar;
    v_instance varchar;
    v_category varchar;
    v_associated_tags varchar;
    v_associated_tags_array varchar[];
    v_short_name varchar;

    v_pos integer;
    v_cve_info_id integer;
    v_cvss3_info_id integer;
    v_cvss_info_id integer;

    v_cursor cursor for select rp.ip, rp.dns, rp.netbios, rp.tracking_method, rp.os, rp.ip_status, rp.qid,
                               rp.title, rp.vuln_status, rp.type, rp.severity, rp.port, rp.protocol, rp.fqdn,
                               rp.ssl, rp.first_detected, rp.last_detected, rp.times_detected, rp.date_last_fixed,
                               rp.cve_id, rp.vendor_reference, rp.bugtraq_id, rp.cvss, rp.cvss_base, rp.cvss_temporal,
                               rp.cvss_environment, rp.cvss3, rp.cvss3_base, rp.cvss3_temporal,
                               rp.threat, rp.impact, rp.pci_vuln, rp.ticket_state, rp.instance, rp.category,
                               rp.associated_tags
        from import.vmdr_irc_report rp;

begin
    -- stored procedure body
    open v_cursor;
    loop
        fetch v_cursor into v_ip, v_dns, v_netbios, v_tracking_method, v_os, v_ip_status, v_qid, v_title,
            v_vuln_status, v_type, v_severity, v_port, v_protocol, v_fqdn, v_ssl, v_first_detected, v_last_detected,
            v_times_detected, v_date_last_fixed, v_cve_id, v_vendor_reference, v_bugtraq_id, v_cvss, v_cvss_base,
            v_cvss_temporal, v_cvss_environment, v_cvss3, v_cvss3_base, v_cvss3_temporal, v_threat, v_impact,
            v_pci_vuln, v_ticket_state, v_instance, v_category, v_associated_tags;
        exit when not FOUND;

        if (v_ip IS NOT NULL AND length(trim(v_ip)) != 0) then
            v_ipaddress = v_ip::cidr;
        else
            v_ipaddress = null ;
        end if;
        if (v_ip_status IS NOT NULL AND length(trim(v_ip_status)) != 0) then
            v_ip_status = replace(v_ip_status, ' ', '');
            v_ip_status_array = string_to_array(v_ip_status, ',');
        else
            v_ip_status_array = null ;
        end if;
        if (v_qid IS NOT NULL AND length(trim(v_qid)) != 0) then
            v_qid1 = v_qid::integer;
        else
           v_qid1 = null ;
        end if;
        if (v_severity IS NOT NULL AND length(trim(v_severity)) != 0) then
            v_severity1 = v_severity::integer;
        else
           v_severity1 = null ;
        end if;
        if (v_port IS NOT NULL AND length(trim(v_port)) != 0) then
            v_port = trim(v_port); --::integer;
        else
           v_port = null ;
        end if;
        if (v_first_detected IS NOT NULL AND length(trim(v_first_detected)) != 0) then
            v_first_detected_ts = v_first_detected::timestamptz; -- TO_DATE(v_first_detected, 'DD/MM/YY HH24:MI:SS')
        else
            v_first_detected_ts = null ;
        end if;
        if (v_last_detected IS NOT NULL AND length(trim(v_last_detected)) != 0) then
            v_last_detected_ts = v_last_detected::timestamptz; --TO_DATE(v_last_detected, 'DD/MM/YY HH24:MI:SS')
        else
            v_last_detected_ts = null ;
        end if;
        if (v_times_detected IS NOT NULL AND length(trim(v_times_detected)) != 0) then
            v_times_detected1 = v_times_detected::integer;
        else
           v_times_detected1 = null ;
        end if;
        if (v_date_last_fixed IS NOT NULL AND length(trim(v_date_last_fixed)) != 0) then
            v_date_last_fixed_ts = v_date_last_fixed::timestamptz; --TO_DATE(v_date_last_fixed, 'DD/MM/YY HH24:MI:SS')
        else
            v_date_last_fixed_ts = null ;
        end if;
        if (v_cve_id IS NOT NULL AND length(trim(v_cve_id)) != 0) then
            v_cve_id = replace(v_cve_id, ' ', '');
            v_cve_id_array = string_to_array(v_cve_id, ',');
        else
            v_cve_id_array = null ;
        end if;
        if (v_bugtraq_id IS NOT NULL AND length(trim(v_bugtraq_id)) != 0) then
            v_bugtraq_id = replace(v_bugtraq_id, ' ', '');
            v_bugtraq_id_array = string_to_array(v_bugtraq_id, ',')::integer[];
        else
            v_bugtraq_id_array = null ;
        end if;
        if (v_associated_tags IS NOT NULL AND length(trim(v_associated_tags)) != 0) then
            v_associated_tags = replace(v_associated_tags, ' ', '');
            v_associated_tags_array = string_to_array(v_associated_tags, ',');
        else
            v_associated_tags_array = null ;
        end if;
        if (v_dns IS NOT NULL AND length(trim(v_dns)) != 0) then
            v_pos = position('.' in v_dns);
            if (v_pos != 0) then
                v_short_name = left(v_dns, v_pos - 1);
            else
                v_short_name = v_dns;
            end if;
        else /* v_dns is empty (in workstations and windows servers assets) */
            if (v_netbios is not null and length(trim(v_netbios)) != 0) then
                v_short_name = lower(v_netbios);
                v_dns = v_netbios;
            else
                v_short_name = null ;
            end if;
        end if;
/*
        if (v_cvss_environment is not null and length(trim(v_cvss_environment)) != 0) then
            --v_cvss_environment = replace(v_cvss_environment, ' ', '');
            v_cvss_environment_array = string_to_array(v_cvss_environment, ',');
        else
            v_cvss_environment_array = null ;
        end if;
*/
        v_cve_info_id = qualys.get_cve_info(v_cve_id_array, v_vendor_reference, v_bugtraq_id_array,
                                            v_threat, v_impact);
        v_cvss3_info_id = qualys.get_cvss3_info(v_cvss3, v_cvss3_base, v_cvss3_temporal);
        v_cvss_info_id = qualys.get_cvss_info(v_cvss, v_cvss_base,
                                            v_cvss_temporal, v_cvss_environment);

        insert into qualys.vmdr_irc_base_report(ipaddress, dns, netbios, tracking_method, os, ip_status, qid,
                               title, vuln_status, type, severity, port, protocol, fqdn,
                               ssl, first_detected, last_detected, times_detected, date_last_fixed,
                               /*cve_id, vendor_reference, bugtraq_id*/ cve_info_id,
                               /*cvss, cvss_base, cvss_temporal, cvss_environment*/ cvss_info_id,
                               /*cvss3, cvss3_base, cvss3_temporal*/ cvss3_info_id,
                               /*threat, impact,*/ pci_vuln, ticket_state, instance, category,
                               associated_tags, short_name)
        values (v_ipaddress, v_dns, v_netbios, v_tracking_method, v_os, v_ip_status_array, v_qid1,
                v_title, v_vuln_status, v_type, v_severity1, v_port, v_protocol, v_fqdn,
                v_ssl, v_first_detected_ts, v_last_detected_ts, v_times_detected1, v_date_last_fixed_ts,
                /*v_cve_id_array, v_vendor_reference, v_bugtraq_id_array*/ v_cve_info_id, /*v_cvss, v_cvss_base,
                v_cvss_temporal, v_cvss_environment*/ v_cvss_info_id,
                /*v_cvss3, v_cvss3_base, v_cvss3_temporal*/ v_cvss3_info_id,
                /*v_threat, v_impact,*/ v_pci_vuln, v_ticket_state, v_instance, v_category,
                v_associated_tags_array, v_short_name);
    end loop;
    close v_cursor;
end;
$$;

alter procedure import.parse_vmdr_irc_report() owner to gsw_datasetter;
-- CALL import.parse_vmdr_irc_report();