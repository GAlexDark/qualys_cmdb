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
CREATE OR REPLACE PROCEDURE import.parse_network_equipment()
language PLPGSQL
AS $$
declare
    v_searchcode varchar;
    v_name varchar;
    v_short_name varchar;
    v_description varchar;
    v_status varchar;
    v_workgroup_templ varchar;
    v_owner varchar;
    v_owner_id integer;
    v_manufacturer varchar;
    v_location varchar;
    v_house varchar;
    v_room varchar;
    v_mac varchar;
    v_model varchar;
    v_eos_model varchar;
    v_eos_model_ts date;
    v_serialnumber varchar;
    v_inventorynumber varchar;
    v_type_of_equipment varchar;
    v_type_of_equipment1 varchar;
    v_ipaddress varchar;
    v_ip_address cidr;
    v_vip varchar;
    v_vip_array cidr[];
    v_firmware varchar;
    v_patchlevel varchar;
    v_eos_software varchar;
    v_eos_software_ts date;
    v_tags varchar[];

    v_manufacturer_info_id integer;
    v_location_info_id integer;

    v_cursor cursor for select vs.searchcode, vs.name, vs.description, vs.status, vs.workgroup_templ, vs.owner,
                               vs.model, vs.manufacturer, vs.location, vs.house, vs.room, vs.mac, vs.serialnumber,
                               vs.inventorynumber, vs.type_of_equipment, vs.ipaddress, vs.vip, vs.firmware,
                               vs.patchlevel, vs.eos_model, vs.eos_software
        from import.network_equipment vs;

begin
    -- stored procedure body
    open v_cursor;
    loop
        fetch v_cursor into v_searchcode, v_name, v_description, v_status, v_workgroup_templ, v_owner, v_model,
            v_manufacturer, v_location, v_house, v_room, v_mac, v_serialnumber, v_inventorynumber, v_type_of_equipment,
            v_ipaddress, v_vip, v_firmware, v_patchlevel, v_eos_model, v_eos_software;
        exit when not FOUND;

        if (v_name is not null and length(trim(v_name)) != 0) then
            v_short_name = lower(v_name);
            v_short_name = nullif(v_short_name, 'нет');
        else
            v_short_name = null;
        end if;
        --raise notice  'v_owner %', v_owner;
        if (v_owner IS NOT NULL AND length(trim(v_owner)) != 0) then
            v_owner_id = substring(v_owner from '[0-9]+$')::integer;
        else
            v_owner_id = null ;
        end if;
        --raise notice  'v_ipaddress %', v_ipaddress;
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

        if (v_eos_model IS NOT NULL AND length(trim(v_eos_model)) != 0) then
            v_eos_model_ts = TO_DATE(v_eos_model, 'DD/MM/YY');
        else
            v_eos_model_ts = null ;
        end if;
        if (v_eos_software IS NOT NULL AND length(trim(v_eos_software)) != 0) then
            v_eos_software_ts = TO_DATE(v_eos_software, 'DD/MM/YY');
        else
            v_eos_software_ts = null ;
        end if;

        v_tags = null ;
        if (position('<Removed>' in v_searchcode) = 1) then
            v_tags = v_tags || '{<>}';
        end if;
        v_type_of_equipment1 = lower(trim(v_type_of_equipment));
        if (v_type_of_equipment1 = 'switch') then
            v_tags = v_tags || '{SW}';
        end if;
        if (v_type_of_equipment1 = 'router') then
            v_tags = v_tags || '{RT}';
        end if;
        if (v_type_of_equipment1 = 'wireless controller') then
            v_tags = v_tags || '{WC}';
        end if;
        if (position('(fw)' in v_type_of_equipment1) > 0) then
            v_tags = v_tags || '{FW}';
        end if;
        if (position('(gw)' in v_type_of_equipment1) > 0) then
            v_tags = v_tags || '{GW}';
        end if;
        if (position('(lb)' in v_type_of_equipment1) > 0) then
            v_tags = v_tags || '{LB}';
        end if;
        if (position('(cons)' in v_type_of_equipment1) > 0) then
            v_tags = v_tags || '{CONSRV}';
        end if;
        if (v_type_of_equipment1 = 'wireless access point') then
            v_tags = v_tags || '{WFAP}';
        end if;
        if (position('(sec)' in v_type_of_equipment1) > 0) then
            v_tags = v_tags || '{SEC}';
        end if;
        if (v_eos_software_ts < now()::date) then
            v_tags = v_tags || '{EoS}';
        end if;
        if (v_eos_model_ts < now()::date and (array_position(v_tags, 'EoS') is null)) then
            v_tags = v_tags || '{EoS}';
        end if;
        /* test parse */
        v_manufacturer_info_id = cmdb.get_manufacturer_info(v_manufacturer, v_model);
        v_location_info_id = cmdb.get_location_info(v_location, v_house, v_room);


        insert into cmdb.network_equipment(searchcode, name, description, status, workgroup_templ, owner_id, /*model,
                            manufacturer*/ manufacturer_info_id, /*location, house, room*/ location_info_id, mac,
                            serialnumber, inventorynumber, type_of_equipment,
                            ipaddress, vip, firmware, patchlevel, eos_model, eos_software, short_name, tags)
        values (v_searchcode, v_name, v_description, v_status, v_workgroup_templ, v_owner_id, /*v_model, v_manufacturer*/
                v_manufacturer_info_id,
                /*v_location, v_house, v_room*/ v_location_info_id, v_mac, v_serialnumber, v_inventorynumber, v_type_of_equipment,
                v_ip_address, v_vip_array, v_firmware, v_patchlevel, v_eos_model_ts, v_eos_software_ts, v_short_name, v_tags);
    end loop;
    close v_cursor;

    --delete from cmdb.network_equipment
    --    where ipaddress is null and vip is null;
end;
$$;

alter procedure import.parse_network_equipment() owner to gsw_datasetter;
-- CALL import.parse_network_equipment();