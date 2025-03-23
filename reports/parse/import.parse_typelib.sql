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
CREATE OR REPLACE PROCEDURE import.parse_typelib()
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
    v_ipaddress varchar;
    v_ip_address cidr;
    v_vip varchar;
    v_vip_array cidr[];
    v_manufacturer varchar;
    v_model varchar;
    v_tags varchar[];
    v_manufacturer_info_id integer;

    v_cursor cursor for select vs.searchcode, vs.name, vs.description, vs.status, vs.owner, vs.ipaddress, vs.vip,
                               vs.manufacturer, vs.model
        from import.typelib vs;

begin
    -- stored procedure body
    open v_cursor;
    loop
        fetch v_cursor into v_searchcode, v_name, v_description, v_status, v_owner, v_ipaddress, v_vip,
            v_manufacturer, v_model;
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
        if (v_vip IS NOT NULL AND length(trim(v_vip)) != 0) then
            v_vip_array = string_to_array(v_vip, ';')::cidr[];
        else
            v_vip_array = null ;
        end if;
        /* test parse */
        v_manufacturer_info_id = cmdb.get_manufacturer_info(v_manufacturer, v_model);

        v_tags = null ;
        if (position('TL-' in v_searchcode) = 1) then
            v_tags = v_tags || '{TL}';
        end if;

        insert into cmdb.typelib(searchcode, name, description, status, owner_id, ipaddress, vip, /*manufacturer,
                             model*/ manufacturer_info_id, short_name, tags)
        values (v_searchcode, v_name, v_description, v_status, v_owner_id, v_ip_address, v_vip_array,
                /*v_manufacturer, v_model*/ v_manufacturer_info_id, v_short_name, v_tags);
    end loop;
    close v_cursor;
end;
$$;

alter procedure import.parse_typelib() owner to gsw_datasetter;
-- CALL import.parse_typelib();