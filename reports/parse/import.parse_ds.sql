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
CREATE OR REPLACE PROCEDURE import.parse_ds()
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
    v_manufacturer varchar;
    v_model varchar;
    v_technomapid_model varchar;
    v_eos_model varchar;
    v_eos_model_ts date;
    v_serialnumber varchar;
    v_ipaddress varchar;
    v_ip_address cidr;
    v_vip varchar;
    v_vip_array cidr[];
    v_firmware varchar;
    v_eos_software varchar;
    v_eos_software_ts date;
    v_tags varchar[];

    v_manufacturer_info_id integer;

    v_cursor cursor for select vs.searchcode, vs.name, vs.description, vs.status, vs.owner, vs.manufacturer,
                               vs.model, vs.technomapid_model, vs.eos_model, vs.serialnumber, vs.ipaddress,
                               vs.vip, vs.firmware, vs.eos_software
        from import.ds vs;

begin
    -- stored procedure body
    open v_cursor;
    loop
        fetch v_cursor into v_searchcode, v_name, v_description, v_status, v_owner, v_manufacturer,
                v_model, v_technomapid_model, v_eos_model, v_serialnumber, v_ipaddress,
                               v_vip, v_firmware, v_eos_software;
        exit when not FOUND;

        if (v_name is not null and length(trim(v_name)) != 0) then
            v_short_name = lower(v_name);
            v_short_name = nullif(v_short_name, 'нет');
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
            v_eos_software_ts = TO_DATE(v_eos_software, 'DD/MM/YY');
        else
            v_eos_software_ts = null ;
        end if;

        v_tags = null ;
        if (position('DS-' in v_searchcode) = 1) then
            v_tags = v_tags || '{DS}';
        end if;
        if (position('LPAR-' in v_searchcode) = 1) then
            v_tags = v_tags || '{LPAR}';
        end if;
        if (position('VAPLN-' in v_searchcode) = 1) then
            v_tags = v_tags || '{VAPLN}';
        end if;
        if (v_eos_software_ts < now()::date) then
            v_tags = v_tags || '{EoS}';
        end if;
        if (v_eos_model_ts < now()::date and (array_position(v_tags, 'EoS') is null)) then
            v_tags = v_tags || '{EoS}';
        end if;
        /* test parse */
        v_manufacturer_info_id = cmdb.get_manufacturer_info(v_manufacturer, v_model);


        insert into cmdb.ds(searchcode, name, description, status, owner_id, --manufacturer, model,
                            manufacturer_info_id,
                             technomapid_model, eos_model, serialnumber, ipaddress,
                             vip, firmware, eoS_software, short_name, tags)
        values (v_searchcode, v_name, v_description, v_status, v_owner_id, --v_manufacturer, v_model,
                v_manufacturer_info_id,
                v_technomapid_model, v_eos_model_ts, v_serialnumber, v_ip_address,
                               v_vip_array, v_firmware, v_eos_software_ts, v_short_name, v_tags);
    end loop;
    close v_cursor;
end;
$$;

alter procedure import.parse_ds() owner to gsw_datasetter;
-- CALL import.parse_ds();