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
CREATE OR REPLACE PROCEDURE import.parse_pbx()
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
    v_serialnumber varchar;
    v_inventorynumber varchar;
    v_datasource varchar;
    v_pbx_config varchar;
    v_ipaddress varchar;
    v_ip_address cidr;
    v_reliability_cat varchar;
    v_vip varchar;
    v_vip_array cidr[];
    v_division_owner varchar;
    v_division_owner_parent varchar;
    v_division_owner_www varchar;
    v_division_owner_mail varchar;
    v_eos_model varchar;
    v_eos_model_tz date;
    v_eos_software varchar;
    v_eos_software_tz date;
    v_tags varchar[];
    v_has_ip_array bool;
    v_manufacturer_info_id integer;
    v_datasource_id integer;

    v_cursor cursor for select vs.searchcode, vs.name, vs.description, vs.status, vs.owner, vs.manufacturer, vs.model,
                               vs.serialnumber, vs.inventorynumber, vs.datasource, vs.pbx_config, vs.ipaddress,
                               vs.reliability_cat, vs.vip, vs.division_owner, vs.division_owner_parent,
                                vs.division_owner_www, vs.division_owner_mail, vs.eos_model, vs.eos_software,
                               vs.has_ip_array
        from import.pbx vs;

begin
    -- stored procedure body
    open v_cursor;
    loop
        fetch v_cursor into v_searchcode, v_name, v_description, v_status, v_owner, v_manufacturer, v_model,
            v_serialnumber, v_inventorynumber, v_datasource, v_pbx_config, v_ipaddress, v_reliability_cat,
            v_vip_array, v_division_owner, v_division_owner_parent, v_division_owner_www, v_division_owner_mail,
            v_eos_model, v_eos_software, v_has_ip_array;
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
        /* test parse */
        v_manufacturer_info_id = cmdb.get_manufacturer_info(v_manufacturer, v_model);
        v_datasource_id = cmdb.get_datasources_info(v_manufacturer);

        v_tags = null ;
        if (position('PBX-' in v_searchcode) = 1) then
            v_tags = v_tags || '{PBX}';
        end if;
        if (v_eos_software_tz < now()::date) then
            v_tags = v_tags || '{EoS}';
        end if;
        if (v_eos_model_tz < now()::date and (array_position(v_tags, 'EoS') is null)) then
            v_tags = v_tags || '{EoS}';
        end if;

        if (v_has_ip_array) then
            raise notice  'v_ipaddress %', v_ipaddress;
            insert into cmdb.pbx(searchcode, name, description, status, owner_id, /*manufacturer, model*/ manufacturer_info_id,
                                 serialnumber,
                             inventorynumber, datasource_id, pbx_config, ipaddress, reliability_cat, vip, division_owner,
                             division_owner_parent, division_owner_www, division_owner_mail, eos_model, eos_software,
                             short_name, tags)
            (select v_searchcode, v_name, v_description, v_status, v_owner_id, /*v_manufacturer, v_model*/ v_manufacturer_info_id,
                    v_serialnumber,
                v_inventorynumber, v_datasource_id, v_pbx_config, unnest(string_to_array(v_ipaddress, ';'))::cidr,
                v_reliability_cat, v_vip_array, v_division_owner, v_division_owner_parent, v_division_owner_www,
                v_division_owner_mail, v_eos_model_tz, v_eos_software_tz, v_short_name, v_tags);
            CONTINUE;
        else
            v_ip_address = v_ipaddress::cidr;
        end if;

        insert into cmdb.pbx(searchcode, name, description, status, owner_id, /*manufacturer, model*/ manufacturer_info_id,
                             serialnumber,
                             inventorynumber, datasource_id, pbx_config, ipaddress, reliability_cat, vip, division_owner,
                             division_owner_parent, division_owner_www, division_owner_mail, eos_model, eos_software,
                             short_name, tags)
        values (v_searchcode, v_name, v_description, v_status, v_owner_id, /*v_manufacturer, v_model*/ v_manufacturer_info_id,
                v_serialnumber,
                v_inventorynumber, v_datasource_id, v_pbx_config, v_ip_address, v_reliability_cat, v_vip_array,
                v_division_owner, v_division_owner_parent, v_division_owner_www, v_division_owner_mail,
                v_eos_model_tz, v_eos_software_tz, v_short_name, v_tags);
    end loop;
    close v_cursor;
end;
$$;

alter procedure import.parse_pbx() owner to gsw_datasetter;
-- CALL import.parse_pbx();