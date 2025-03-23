/*
  Copyright (c) Oleksii Gaienko, 2021
  Contact: galexsoftware@gmail.com

  Module name: PostgreSQL(R) gsw_security_audit DB parse file
  Author(s): Oleksii Gaienko
  Reviewer(s):

  Abstract:
     SQL file with source code for parsing data in DB.
 */
CREATE OR REPLACE PROCEDURE import.prepare_to_parse_qualys_assets()
language PLPGSQL
AS $$
declare
    v_id integer;
    v_ipaddress varchar;
    v_has_ip_array bool;

    v_cursor refcursor;
begin
    -- stored procedure body
    delete from import.assets where ipaddress like '%N/A%';

    update import.assets
        set ipaddress = null
    where length(ipaddress) <= 1;

    update import.assets
        set name = nullif(name, ipaddress), --null where name = ipaddress;
            modules = nullif(modules, ''),
            os = nullif(os, 'OS Not Identified'), --null where os = 'OS Not Identified';
            last_logged_in_user = nullif(last_logged_in_user, '''-'), --where length(last_logged_in_user) <= 2;
            last_inventory = nullif(last_inventory, '''-'), --length(last_inventory) <= 2;
            activity = nullif(activity, ''),
            netbios_name = nullif(netbios_name, ''),
            sources = nullif(sources, ''),
            tags = nullif(tags, '');

    update import.assets
        set last_inventory = format('%s:%s', left(last_inventory, position('GMT+' in last_inventory) + 5),
                            right(last_inventory, -1 * (position('GMT+' in last_inventory) + 5)))
        where last_inventory is not null ;

    open v_cursor for select vs.id, vs.ipaddress
        from import.assets vs where vs.ipaddress is not null;

    loop
        fetch v_cursor into v_id, v_ipaddress;
        exit when not FOUND;

        v_has_ip_array = false;
        v_ipaddress = replace(v_ipaddress, ',', ';');
        v_ipaddress = regexp_replace(v_ipaddress, '[^0-9.;:a-fA-F]','','g');
        v_ipaddress = replace(v_ipaddress, ';;', ';');
        v_ipaddress = trim(both ';' from v_ipaddress);
        if (position(';' in v_ipaddress) > 0) then
            v_has_ip_array = true;
        end if;

        update import.assets
            set ipaddress = v_ipaddress,
                has_ip_array = v_has_ip_array
        where  id = v_id;

    end loop;
    close v_cursor;
end;
$$;

alter procedure import.prepare_to_parse_qualys_assets() owner to gsw_datasetter;
--call import.prepare_to_parse_physical_servers();