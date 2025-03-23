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
CREATE OR REPLACE PROCEDURE import.parse_physical_servers()
language PLPGSQL
AS $$
declare
    v_searchcode varchar;
    v_name varchar;
    v_short_name varchar;
    v_description varchar;
    v_descr varchar;
    v_status varchar;
    v_owner varchar;
    v_owner_id integer;
    v_manufacturer varchar;
    v_model varchar;
    v_eos_model varchar;
    v_eos_model_ts date;
    v_serialnumber varchar;
    v_inventorynumber varchar;
    v_cpucores varchar;
    v_cpumodel varchar;
    v_cpucoretechnology varchar;
    v_cpufrequency varchar;
    v_ram varchar;
    v_location varchar;
    v_house varchar;
    v_ipaddress varchar;
    v_ip_address cidr;
    v_vip varchar;
    v_vip_array cidr[];
    v_os varchar;
    v_os1 varchar;
    v_eos_software varchar;
    v_eos_software_ts date;
    v_avsoft varchar;
    v_avversion varchar;
    v_datasource varchar;
    v_tags varchar[];
    v_pos integer;
    v_dn1 varchar;
    v_dn2 varchar;
    v_manufacturer_info_id integer;
    v_hardware_info_id integer;
    v_location_info_id integer;
    v_av_info_id integer;
    v_datasource_id integer;

    v_cursor cursor for select ps.searchcode, ps.name, ps.description, ps.status, ps.owner,
            ps.manufacturer, ps.model, ps.eos_model, ps.serialnumber, ps.inventorynumber,
            ps.cpucores, ps.cpumodel, ps.cpucoretechnology, ps.cpufrequency, ps.ram, ps.location,
            ps.house, ps.ipaddress, ps.vip, ps.os, ps.eos_software, ps.avsoft, ps.avversion, ps.datasource
        from import.physical_servers ps;

begin
    -- stored procedure body
    v_dn1 = 'Domain_1';
    v_dn2 = 'Domain_2';
    open v_cursor;
    loop
        fetch v_cursor into v_searchcode, v_name, v_description, v_status, v_owner, v_manufacturer, v_model,
            v_eos_model, v_serialnumber, v_inventorynumber, v_cpucores, v_cpumodel, v_cpucoretechnology,
            v_cpufrequency, v_ram, v_location, v_house, v_ipaddress, v_vip, v_os, v_eos_software, v_avsoft,
            v_avversion, v_datasource;
        exit when not FOUND;

        if (v_name is not null and length(trim(v_name)) != 0) then
            v_short_name = lower(v_name);
            v_pos = position('.' in v_short_name);
            if (v_pos != 0 and (position(v_dn1 in v_short_name) !=0 or position(v_dn2 in v_short_name) !=0)) then
	            v_short_name = left(v_short_name, v_pos - 1);
            end if;
        else
            v_short_name = null ;
        end if;
        if (v_owner IS NOT NULL AND length(trim(v_owner)) != 0) then
            v_owner_id = substring(v_owner from '[0-9]+$')::integer;
        else
            v_owner_id = null ;
        end if;
        if (v_eos_model IS NOT NULL AND length(trim(v_eos_model)) != 0) then
            v_eos_model_ts = TO_DATE(v_eos_model, 'DD/MM/YY');
        else
            v_eos_model_ts = null ;
        end if;
        if (v_ipaddress IS NOT NULL AND length(trim(v_ipaddress)) != 0) then
            v_ip_address = v_ipaddress::cidr;
        else
            v_ip_address = null ;
        end if;
        if (v_vip IS NOT NULL AND length(trim(v_vip)) != 0) then
            v_vip_array = string_to_array(v_vip, ';')::cidr[];
        else
            v_vip_array = null ;
        end if;
        if (v_eos_software IS NOT NULL AND length(trim(v_eos_software)) != 0) then
            v_eos_software_ts = TO_DATE(v_eos_model, 'DD/MM/YY');
        else
            v_eos_software_ts = null ;
        end if;

        /* test parse */
        v_manufacturer_info_id = cmdb.get_manufacturer_info(v_manufacturer, v_model);
        v_hardware_info_id = cmdb.get_hardware_info(v_cpucores, v_cpumodel, v_cpucoretechnology, v_cpufrequency, v_ram);
        v_location_info_id = cmdb.get_location_info(v_location, v_house);
        v_av_info_id = cmdb.get_av_info(v_avsoft, v_avversion);
        v_datasource_id = cmdb.get_datasources_info(v_datasource);

        v_tags = null;
        if (position('SRV-' in v_searchcode) = 1) then
            v_tags = v_tags || '{SRV}';
        end if;
        if (position('APLN-' in v_searchcode) = 1) then
            v_tags = v_tags || '{APLN}';
        end if;
        if (position('PC-' in v_searchcode) = 1) then
            v_tags = v_tags || '{PC_WS}';
        end if;
        if (v_eos_software_ts < now()::date) then
            v_tags = v_tags || '{EoS}';
        end if;

        v_descr = lower(v_description);
        if (position('<Removed>' in v_descr) > 0 and (array_position(v_tags, 'NET_EQUIP') is null)) then
            v_tags = v_tags || '{NET_EQUIP}';
        end if;
        if ((position('terminal' in v_descr) > 0 and position('server' in v_descr) > 0) or
            position('терминальный' in v_descr) > 0) then
            v_tags = v_tags || '{TERM}';
        end if;

        v_os1 = lower(v_os);
        if ((position('checkpoint' in v_os1) > 0 or position('check point' in v_os1) > 0) and (array_position(v_tags, 'NET_EQUIP') is null)) then
            v_tags = v_tags || '{NET_EQUIP}';
        end if;
        if (position('microsoft' in v_os1) > 0 and position('windows' in v_os1) > 0 and (array_position(v_tags, 'WIN') is null)) then
            v_tags = v_tags || '{WIN}';
        end if;
        if ((position('red hat' in v_os1) > 0 or position('rhel' in v_os1) > 0) and (array_position(v_tags, 'LINUX') is null)) then
            v_tags = v_tags || '{LINUX}';
        end if;
        if (position('centos' in v_os1) > 0 and (array_position(v_tags, 'LINUX') is null)) then
            v_tags = v_tags || '{LINUX}';
        end if;
        if (position('freebsd' in v_os1) > 0 and (array_position(v_tags, 'LINUX') is null)) then
            v_tags = v_tags || '{LINUX}';
        end if;
        if (position('gentoo' in v_os1) > 0 and (array_position(v_tags, 'LINUX') is null)) then
            v_tags = v_tags || '{LINUX}';
        end if;
        if (position('kali' in v_os1) > 0 and (array_position(v_tags, 'LINUX') is null)) then
            v_tags = v_tags || '{LINUX}';
        end if;
        if (position('slackware' in v_os1) > 0 and (array_position(v_tags, 'LINUX') is null)) then
            v_tags = v_tags || '{LINUX}';
        end if;
        if (position('sun' in v_os1) > 0 and (array_position(v_tags, 'LINUX') is null)) then
            v_tags = v_tags || '{LINUX}';
        end if;
        if (position('suse' in v_os1) > 0 and (array_position(v_tags, 'LINUX') is null)) then
            v_tags = v_tags || '{LINUX}';
        end if;
        if (position('ubuntu' in v_os1) > 0 and (array_position(v_tags, 'LINUX') is null)) then
            v_tags = v_tags || '{LINUX}';
        end if;
        if ((position('ibm-aix' in v_os1) > 0 or position('ibm aix' in v_os1) > 0 or position('aix' in v_os1) > 0)
                and (array_position(v_tags, 'LINUX') is null)) then
            v_tags = v_tags || '{LINUX}';
        end if;

        insert into cmdb.physical_servers(searchcode, name, description, status, owner_id,  /*manufacturer, model*/
                                        manufacturer_info_id,
                                        EoS_Model, serialnumber, inventorynumber, /*CPUcores, CPUModel,
                                        CPUCoretechnology, CPUfrequency, RAM*/ hardware_info_id, /*Location, House*/ location_info_id,
                                          ipaddress, vip,
                                        os, EoS_Software, /*AVSoft, AVversion*/ av_info_id, datasource_id, short_name, tags)
        values (v_searchcode, v_name, v_description, v_status, v_owner_id, /*v_manufacturer, v_model*/ v_manufacturer_info_id,
            v_eos_model_ts, v_serialnumber, v_inventorynumber, /*v_cpucores, v_cpumodel, v_cpucoretechnology,
            v_cpufrequency, v_ram*/ v_hardware_info_id, /*v_location, v_house*/ v_location_info_id, v_ip_address, v_vip_array, v_os, v_eos_software_ts,
                /*v_avsoft, v_avversion*/ v_av_info_id, v_datasource_id, v_short_name, v_tags);
    end loop;
    close v_cursor;
end;
$$;

alter procedure import.parse_physical_servers() owner to gsw_datasetter;
-- CALL import.parse_physical_servers();