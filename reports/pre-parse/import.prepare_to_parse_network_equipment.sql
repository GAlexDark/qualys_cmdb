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
CREATE OR REPLACE PROCEDURE import.prepare_to_parse_network_equipment(remove_first_row bool default true)
language PLPGSQL
AS $$
declare
    v_cursor refcursor;
    v_id integer;
    v_vip varchar;

begin
    -- stored procedure body
    if (remove_first_row) then
        delete from import.network_equipment where id=1;
    end if;

    update import.network_equipment
        set searchcode = trim(both '"' from searchcode),
            name = nullif(trim(trim(both '"' from name)),''),
            description = substring(description from '"(.*?[^\\])"$'),
            status = trim(both '"' from status),
            workgroup_templ = trim(both '"' from workgroup_templ),
            owner = trim(both '"' from owner),
            model = nullif(trim(trim(both '"' from model)), ''),
            manufacturer = nullif(trim(trim(both '"' from manufacturer)), ''),
            location = nullif(trim(trim(both '"' from location)), ''),
            house = nullif(trim(trim(both '"' from house)), ''),
            room = nullif(trim(trim(both '"' from room)), ''),
            mac = nullif(trim(both '"' from mac), ''),
            serialnumber = trim(both '"' from serialnumber),
            inventorynumber = trim(both '"' from inventorynumber),
            type_of_equipment = nullif(trim(trim(both '"' from type_of_equipment)), ''),
            ipaddress = regexp_replace(ipaddress, '[^0-9.]', '', 'g'),
            vip = trim(both '"' from vip),
            firmware = trim(both '"' from firmware),
            patchlevel = trim(both '"' from patchlevel),
            eos_model = trim(both '"' from eos_model),
            eos_software = trim(both '"' from eos_software);

    update import.network_equipment
        set description = null
    where
          lower(description) = 'нет';

    open v_cursor for select vs.id, vs.vip
        from import.network_equipment vs where vs.vip is not null;

    loop
        fetch v_cursor into v_id, v_vip;
        exit when not FOUND;

        v_vip = replace(v_vip, ',', ';');
        v_vip = regexp_replace(v_vip, '[^0-9.;]', '', 'g');
        v_vip = replace(v_vip, ';;', ';');
        v_vip = trim(both ';' from v_vip);

        update import.network_equipment
            set vip = v_vip
        where  id = v_id;

    end loop;
    close v_cursor;

--    delete from import.network_equipment
--        where ipaddress is null and vip is null;
end;
$$;

alter procedure import.prepare_to_parse_network_equipment(remove_first_row bool) owner to gsw_datasetter;
--call import.prepare_to_parse_network_equipment( remove_first_row <= value );