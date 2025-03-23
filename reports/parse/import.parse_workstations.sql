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
CREATE OR REPLACE PROCEDURE import.parse_workstations()
language PLPGSQL
AS $$
declare
    v_searchcode varchar;
    v_name varchar;
    v_short_name varchar;
    v_description varchar;
    v_status varchar;
    v_manufacturer varchar;
    v_model varchar;
    v_serialnumber varchar;
    v_inventorynumber varchar;
    v_cpucores varchar;
    v_cpumodel varchar;
    v_cpucoretechnology varchar;
    v_cpufrequency varchar;
    v_ram varchar;
    v_ipaddress varchar;
    v_ip_address cidr;
    v_vip varchar;
    v_vip_array cidr[];
    v_net varchar;
    v_os varchar;
    v_avsoft varchar;
    v_avversion varchar;
    v_eos_model varchar;
    v_eos_model_tz date;
    v_eos_software varchar;
    v_eos_software_tz date;

    v_tags varchar[];
    v_has_ip_array bool;
    v_manufacturer_info_id integer;
    v_hardware_info_id integer;
    v_av_info_id integer;
    v_dn1 varchar;
    v_dn2 varchar;
    v_pos integer;

    v_cursor cursor for select vs.searchcode, vs.name, vs.description, vs.status, vs.manufacturer, vs.model,
                               vs.serialnumber, vs.inventorynumber, vs.cpucores, vs.cpumodel, vs.cpucoretechnology,
                               vs.cpufrequency, vs.ram, vs.ipaddress, vs.vip, vs.net, vs.os, vs.avsoft,
                               vs.avversion, vs.eos_model, vs.eos_software, vs.has_ip_array
        from import.workstations vs;

begin
    -- stored procedure body
    v_dn1 = 'Domain_1';
    v_dn2 = 'Domain_2';

    open v_cursor;
    loop
        fetch v_cursor into v_searchcode, v_name, v_description, v_status, v_manufacturer, v_model,
                            v_serialnumber, v_inventorynumber, v_cpucores, v_cpumodel, v_cpucoretechnology,
                            v_cpufrequency, v_ram, v_ipaddress, v_vip, v_net, v_os, v_avsoft,
                            v_avversion, v_eos_model, v_eos_software, v_has_ip_array;
        exit when not FOUND;

        if (v_name is not null and length(trim(v_name)) != 0) then
            v_short_name = lower(v_name);
            v_short_name = nullif(v_short_name, 'archive');
            v_pos = position('.' in v_short_name);
            if (v_pos != 0 and (position(v_dn1 in v_short_name) !=0 or position(v_dn2 in v_short_name) !=0)) then
                v_short_name = left(v_short_name, v_pos - 1);
            end if;
        else
            v_short_name = null;
        end if;
        if (v_vip IS NOT NULL AND length(trim(v_vip)) != 0) then
            v_vip_array = string_to_array(v_vip, ';')::cidr[];
        else
            v_vip_array = null ;
        end if;

        if (v_eos_model IS NOT NULL AND length(trim(v_eos_model)) != 0) then
            v_eos_model_tz = TO_DATE(v_eos_model, 'DD/MM/YY');
        else
            v_eos_model_tz = null ;
        end if;
        if (v_eos_software IS NOT NULL AND length(trim(v_eos_software)) != 0) then
            v_eos_software_tz = TO_DATE(v_eos_software, 'DD/MM/YY');
        else
            v_eos_software_tz = null ;
        end if;
        v_manufacturer_info_id = cmdb.get_manufacturer_info(v_manufacturer, v_model);
        v_hardware_info_id = cmdb.get_hardware_info(v_cpucores, v_cpumodel, v_cpucoretechnology, v_cpufrequency, v_ram);
        v_av_info_id = cmdb.get_av_info(v_avsoft, v_avversion);

        v_tags = null ;
        if (v_manufacturer = '<Removed>') then
            v_tags = v_tags || '{TC}';
        end if;
        if ((array_position(v_tags, 'TC') is null) and
            (position('l-' in v_short_name) = 1 or substring(v_short_name, 4, 1) = 'l')) then
            v_tags = v_tags || '{LAPTOP}';
        end if;
        if ((array_position(v_tags, 'TC') is null) and
            (position('a-' in v_short_name) = 1 or substring(v_short_name, 4, 1) = 'a')) then
            v_tags = v_tags || '{ARM}';
        end if;
        if (position('WS-' in v_searchcode) = 1 and
            array_position(v_tags, 'LAPTOP') is null and
            array_position(v_tags, 'ARM') is null and
            array_position(v_tags, 'TC') is null) then
            v_tags = v_tags || '{WS}';
        end if;
        if (v_eos_software_tz < now()::date) then
            v_tags = v_tags || '{EoS}';
        end if;
        if (v_eos_model_tz < now()::date and (array_position(v_tags, 'EoS') is null)) then
            v_tags = v_tags || '{EoS}';
        end if;

        if (v_has_ip_array) then
            --raise notice  'v_ipaddress %', v_ipaddress;
            insert into cmdb.workstations(searchcode, name, description, status, /*manufacturer, model*/ manufacturer_info_id,
                                        serialnumber, inventorynumber, /*cpucores, cpumodel, cpucoretechnology,
                                        cpufrequency, ram*/ hardware_info_id, ipaddress, vip, net, os, /*avsoft,
                                        avversion*/ av_info_id, eos_model, eos_software, short_name, tags)
            (select v_searchcode, v_name, v_description, v_status, /*v_manufacturer, v_model*/ v_manufacturer_info_id,
                    v_serialnumber, v_inventorynumber, /*v_cpucores, v_cpumodel, v_cpucoretechnology,
                    v_cpufrequency, v_ram*/ v_manufacturer_info_id, unnest(string_to_array(v_ipaddress, ';'))::cidr,
                    v_vip_array, v_net, v_os, /*v_avsoft, v_avversion*/ v_av_info_id, v_eos_model_tz, v_eos_software_tz,
                    v_short_name, v_tags);
            CONTINUE;
        else
            v_ip_address = v_ipaddress::cidr;
        end if;

        insert into cmdb.workstations(searchcode, name, description, status, /*manufacturer, model*/ manufacturer_info_id,
                                        serialnumber, inventorynumber, /*cpucores, cpumodel, cpucoretechnology,
                                        cpufrequency, ram*/ hardware_info_id, ipaddress, vip, net, os, /*avsoft,
                                        avversion*/ av_info_id, eos_model, eos_software, short_name, tags)
        values (v_searchcode, v_name, v_description, v_status, /*v_manufacturer, v_model*/ v_manufacturer_info_id,
                v_serialnumber, v_inventorynumber, /*v_cpucores, v_cpumodel, v_cpucoretechnology,
                v_cpufrequency, v_ram*/ v_manufacturer_info_id, v_ip_address, v_vip_array, v_net, v_os, /*v_avsoft,
                v_avversion*/ v_av_info_id, v_eos_model_tz, v_eos_software_tz, v_short_name, v_tags);
    end loop;
    close v_cursor;
end;
$$;

alter procedure import.parse_workstations() owner to gsw_datasetter;
-- CALL import.parse_workstations();