/*
  Copyright (c) Oleksii Gaienko, 2021
  Contact: galexsoftware@gmail.com

  Module name: PostgreSQL(R) gsw_security_audit DB parse file
  Author(s): Oleksii Gaienko
  Reviewer(s):

  Abstract:
     SQL file with source code for parsing data in DB.
 */
CREATE OR REPLACE PROCEDURE import.parse_vmdr_irc_common_stat()
    language plpgsql
as
$$
declare
    v_ipaddress varchar;
    v_ip_address inet;
    v_total_vulnerabilities varchar;
    v_totalvulnerabilities integer;
    v_security_risk varchar;
    v_securityrisk real;
    v_date_written date;

    v_cursor cursor for select qa.ipaddress, qa.total_vulnerabilities, qa.security_risk
        from import.vmdr_irc_common_stat qa;

begin
    -- stored procedure body
    v_date_written = now()::date;
    open v_cursor;
    loop
        fetch v_cursor into v_ipaddress, v_total_vulnerabilities, v_security_risk;
        exit when not FOUND;

        if (v_ipaddress IS NOT NULL AND length(trim(v_ipaddress)) != 0) then
            v_ip_address = v_ipaddress::cidr;
        else
            v_ip_address = null ;
        end if;

        if (v_total_vulnerabilities IS NOT NULL AND length(trim(v_total_vulnerabilities)) != 0) then
            v_totalvulnerabilities = v_total_vulnerabilities::integer;
        else
           v_totalvulnerabilities = 0;
        end if;
        if (v_security_risk IS NOT NULL AND length(trim(v_security_risk)) != 0) then
            v_securityrisk = v_security_risk::real;
        else
           v_securityrisk = 0;
        end if;

        insert into report.vmdr_irc_common_stat(ipaddress, total_vulnerabilities, security_risk, date_written)
        values (v_ip_address, v_totalvulnerabilities, v_securityrisk, v_date_written);
    end loop;
    close v_cursor;
end;
$$;

alter procedure import.parse_vmdr_irc_common_stat() owner to gsw_datasetter;
-- CALL import.parse_vmdr_irc_common_stat();