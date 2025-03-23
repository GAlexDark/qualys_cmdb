/*
  Copyright (c) Oleksii Gaienko, 2021
  Contact: galexsoftware@gmail.com

  Module name: PostgreSQL(R) gsw_security_audit DB parse file
  Author(s): Oleksii Gaienko
  Reviewer(s):

  Abstract:
     SQL file with source code for parsing data in DB.
 */
CREATE OR REPLACE PROCEDURE import.parse_qualys_assets()
language PLPGSQL
AS $$
declare
    v_assetid varchar;
    v_asset_id bigint;
    v_name varchar;
    v_short_name varchar;
    v_ipaddress varchar;
    v_ip_address cidr;
    v_modules varchar;
    v_modules_array varchar[];
    v_os varchar;
    v_last_logged_in_user varchar;
    v_last_inventory varchar;
    v_last_inventory_ts timestamptz;
    v_activity varchar;
    v_netbios_name varchar;
    v_sources varchar;
    v_tags varchar;
    v_tags_array varchar[];
    v_has_ip_array bool;
    v_pos integer;

    v_cursor cursor for select qa.asset_id, qa.name, qa.ipaddress, qa.modules, qa.os,
                                qa.last_logged_in_user, qa.last_inventory, qa.activity,
                                qa.netbios_name, qa.sources, qa.tags, qa.has_ip_array
        from import.assets qa;

begin
    -- stored procedure body
    open v_cursor;
    loop
        fetch v_cursor into v_assetid, v_name, v_ipaddress, v_modules, v_os,
            v_last_logged_in_user, v_last_inventory, v_activity, v_netbios_name, v_sources,
            v_tags, v_has_ip_array;
        exit when not FOUND;

        if (v_assetid IS NOT NULL AND length(trim(v_assetid)) != 0) then
            v_asset_id = substring(v_assetid from '[0-9]+$')::integer;
        end if;
        if (v_name IS NOT NULL AND length(trim(v_name)) != 0) then
            v_pos = position('.' in v_name);
            if (v_pos != 0) then
                v_short_name = left(v_name, v_pos - 1);
            else
                v_short_name = v_name;
            end if;
        else
            v_short_name = null ;
        end if;
        if (v_modules IS NOT NULL AND length(trim(v_modules)) != 0) then
            v_modules_array = string_to_array(v_modules, ',');
        else
            v_modules_array = null ;
        end if;
        -- last inventory
        if (v_last_inventory IS NOT NULL AND length(trim(v_last_inventory)) != 0) then
            v_last_inventory_ts = v_last_inventory::timestamptz;
        else
            v_last_inventory_ts = null ;
        end if;

        if (v_tags IS NOT NULL AND length(trim(v_tags)) != 0) then
            v_tags_array = string_to_array(v_tags, ',');
        else
            v_tags_array = null ;
        end if;

        if (v_has_ip_array) then
            insert into qualys.assets(asset_id, name, ipaddress, modules, os,
                                last_logged_in_user, last_inventory, activity,
                                netbios_name, sources, short_name, tags)
            (select v_asset_id, v_name, unnest(string_to_array(v_ipaddress, ';'))::cidr, v_modules_array, v_os,
                    v_last_logged_in_user, v_last_inventory_ts, v_activity, v_netbios_name, v_sources, v_short_name,
                    v_tags_array);
            CONTINUE;
        else
            v_ip_address = v_ipaddress::cidr;
        end if;


        insert into qualys.assets(asset_id, name, ipaddress, modules, os,
                                last_logged_in_user, last_inventory, activity,
                                netbios_name, sources, short_name, tags)
        values (v_asset_id, v_name, v_ip_address, v_modules_array, v_os, v_last_logged_in_user,
            v_last_inventory_ts, v_activity, v_netbios_name, v_sources, v_short_name, v_tags_array);
    end loop;
    close v_cursor;
end;
$$;

alter procedure import.parse_qualys_assets() owner to gsw_datasetter;
-- CALL import.parse_virtual_servers();