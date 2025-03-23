/*
  Copyright (c) Oleksii Gaienko, 2021
  Contact: galexsoftware@gmail.com

  Module name: PostgreSQL(R) gsw_security_audit DB parse file
  Author(s): Oleksii Gaienko
  Reviewer(s):

  Abstract:
     SQL file with source code for parsing data in DB.

  Version 2

 */
CREATE OR REPLACE PROCEDURE import.parse_printers()
language PLPGSQL
AS $$
declare
    v_searchcode varchar;
    v_name varchar;
    v_description varchar;
    v_status varchar;
    v_owner varchar;
    v_owner_id integer;
    v_manufacturer varchar;
    v_model varchar;
    v_serialnumber varchar;
    v_ipaddress varchar;
    v_ip_address cidr;
    v_vip varchar;
    v_vip_array cidr[];
    v_net varchar;
    v_inventorynumber varchar;
    v_userid varchar;
    v_user_id integer;
    v_short_name varchar;
    v_pos integer;
    v_tags varchar[];
    v_dn1 varchar;
    v_dn2 varchar;
    v_manufacturer_info_id integer;

    v_cursor cursor for select vs.searchcode, vs.name, vs.description, vs.status, vs.owner, vs.manufacturer, vs.model,
                               vs.serialnumber, vs.ipaddress, vs.vip, vs.net, vs.inventorynumber, vs.userid
        from import.printers vs;

begin
    -- stored procedure body
    v_dn1 = 'Domain_1';
    v_dn2 = 'Domain_2';
    open v_cursor;
    loop
        fetch v_cursor into v_searchcode, v_name, v_description, v_status, v_owner, v_manufacturer, v_model,
            v_serialnumber, v_ipaddress,  v_vip, v_net, v_inventorynumber, v_userid;
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

        v_ip_address = v_ipaddress::cidr;

        if (v_vip IS NOT NULL AND length(trim(v_vip)) != 0) then
            v_vip_array = string_to_array(v_vip, ';')::cidr[];
        else
            v_vip_array = null ;
        end if;

        if (v_userid IS NOT NULL AND length(trim(v_userid)) != 0) then
            v_user_id = substring(v_owner from '[0-9]+$')::integer;
        else
            v_user_id = null ;
        end if;
        /* test parse */
        v_manufacturer_info_id = cmdb.get_manufacturer_info(v_manufacturer, v_model);

        v_tags = null ;
        if (position('MFU-' in v_searchcode) = 1) then
            v_tags = v_tags || '{MFU}';
        end if;

        insert into cmdb.printers(searchcode, name, description, status, owner_id, /*manufacturer, model*/ manufacturer_info_id,
                                  serialnumber,
                                  ipaddress, vip, net, inventorynumber, user_id, short_name, tags)
        values (v_searchcode, v_name, v_description, v_status, v_owner_id, /*v_manufacturer, v_model*/ v_manufacturer_info_id,
            v_serialnumber, v_ip_address,  v_vip_array, v_net, v_inventorynumber, v_user_id, v_short_name, v_tags);
    end loop;
    close v_cursor;

    update cmdb.printers
        set short_name = null where short_name = 'stock';
end;
$$;

alter procedure import.parse_printers() owner to gsw_datasetter;
-- CALL import.parse_printers();