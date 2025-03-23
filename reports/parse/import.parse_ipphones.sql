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
CREATE OR REPLACE PROCEDURE import.parse_ipphones()
language PLPGSQL
AS $$
declare
    v_searchcode varchar;
    v_name varchar;
    v_short_name varchar;
    v_description varchar;
    v_status varchar;
    v_owner varchar;
    v_owner_id integer;
    v_serialnumber varchar;
    v_inventorynumber varchar;
    v_manufacturer varchar;
    v_model varchar;
    v_ipaddress varchar;
    v_ip_address cidr;
    v_firmware varchar;
    v_update_ownerid varchar;
    v_update_owner_id integer;
    v_update_managerid varchar;
    v_update_manager_id integer;
    v_datasource varchar;
    v_eos_model varchar;
    v_eos_model_ts date;
    v_eos_software varchar;
    v_eos_software_ts date;
    v_tags varchar[];
    v_manufacturer_info_id integer;
    v_datasource_id integer;

    v_cursor cursor for select vs.searchcode, vs.name, vs.description, vs.status, vs.owner, vs.serialnumber,
                               vs.inventorynumber, vs.manufacturer, vs.model, vs.ipaddress, vs.firmware,
                                vs.update_ownerid, vs.update_managerid, vs.datasource, vs.eos_model, vs.eos_software
        from import.ipphones vs;

begin
    -- stored procedure body
    open v_cursor;
    loop
        fetch v_cursor into v_searchcode, v_name, v_description, v_status, v_owner, v_serialnumber, v_inventorynumber,
            v_manufacturer, v_model, v_ipaddress, v_firmware, v_update_ownerid, v_update_managerid, v_datasource,
            v_eos_model, v_eos_software;
        exit when not FOUND;

        if (v_name is not null and length(trim(v_name)) != 0) then
            v_short_name = lower(v_name);
            v_short_name = regexp_replace(v_short_name, '[^0-9a-z.-]', '', 'g');
        else
            v_short_name = null ;
        end if;
        if (v_owner IS NOT NULL AND length(trim(v_owner)) != 0) then
            v_owner_id = substring(v_owner from '[0-9]+$')::integer;
        else
            v_owner_id = null ;
        end if;
        if (v_ipaddress IS NOT NULL AND length(trim(v_ipaddress)) != 0) then
            v_ip_address = v_ipaddress::cidr;
        else
            v_ip_address = null ;
        end if;
        if (v_update_ownerid is not null and length(trim(v_update_ownerid)) != 0) then
            v_update_owner_id = substring(v_update_ownerid from '[0-9]+$')::integer;
        else
            v_update_owner_id = null ;
        end if;
        if (v_update_managerid is not null and length(trim(v_update_managerid)) != 0) then
            v_update_manager_id = substring(v_update_managerid from '[0-9]+$')::integer;
        else
            v_update_manager_id = null ;
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

        /* test parse */
        v_manufacturer_info_id = cmdb.get_manufacturer_info(v_manufacturer, v_model);
        v_datasource_id = cmdb.get_datasources_info(v_datasource);

        v_tags = null ;
        if (position('IPPHONE-' in v_searchcode) = 1) then
            v_tags = v_tags || '{IPPHONE}';
        end if;
        if (v_eos_software_ts < now()::date) then
            v_tags = v_tags || '{EoS}';
        end if;
        if (v_eos_model_ts < now()::date and (array_position(v_tags, 'EoS') is null)) then
            v_tags = v_tags || '{EoS}';
        end if;

        insert into cmdb.ipphones(searchcode, name, description, status, owner_id, serialnumber,
                               inventorynumber, /*manufacturer, model*/ manufacturer_info_id, ipaddress, firmware,
                                update_owner_id, update_manager_id, datasource_id, eos_model, eos_software, short_name,
                                tags)
        values (v_searchcode, v_name, v_description, v_status, v_owner_id, v_serialnumber, v_inventorynumber,
            /*v_manufacturer, v_model*/ v_manufacturer_info_id, v_ip_address, v_firmware, v_update_owner_id,
                v_update_manager_id, v_datasource_id,
            v_eos_model_ts, v_eos_software_ts, v_short_name, v_tags);
    end loop;
    close v_cursor;
end;
$$;

alter procedure import.parse_ipphones() owner to gsw_datasetter;
-- CALL import.parse_ipphones();