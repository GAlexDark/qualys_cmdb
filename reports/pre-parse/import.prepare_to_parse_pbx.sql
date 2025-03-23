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
CREATE OR REPLACE PROCEDURE import.prepare_to_parse_pbx(remove_first_row bool default true)
language PLPGSQL
AS $$
declare
    v_id integer;
    v_ipaddress varchar;
    v_has_ip_array bool;

    v_cursor refcursor;
begin
    -- stored procedure body
    if (remove_first_row) then
        delete from import.pbx where id=1;
    end if;

    update import.pbx
        set searchcode = trim(both '"' from searchcode),
            name = trim(both '"' from name),
            description = substring(description from '"(.*?[^\\])"$'),
            status = trim(both '"' from status),
            owner = trim(both '"' from owner),
            manufacturer = nullif(trim(trim(both '"' from manufacturer)),''),
            model = nullif(trim(trim(both '"' from model)),''),
            serialnumber = trim(both '"' from serialnumber),
            inventorynumber = trim(both '"' from inventorynumber),
            datasource = nullif(trim(trim(both '"' from datasource)),''),
            pbx_config = trim(both '"' from pbx_config),
            ipaddress = nullif(trim(trim(both '"' from ipaddress)), ''),
            reliability_cat = trim(both '"' from reliability_cat),
            vip = nullif(trim(trim(both '"' from vip)),''),
            division_owner = trim(both '"' from division_owner),
            division_owner_parent = trim(both '"' from division_owner_parent),
            division_owner_www = trim(both '"' from division_owner_www),
            division_owner_mail = trim(both '"' from division_owner_mail),
            eos_model = trim(both '"' from eos_model),
            eos_software = trim(both '"' from eos_software);

    update import.pbx
        set description = null
    where
          lower(description) = 'нет';
--    delete from import.pbx
--        where ipaddress is null and vip is null;

    open v_cursor for select vs.id, vs.ipaddress
        from import.pbx vs where vs.ipaddress is not null;

    loop
        fetch v_cursor into v_id, v_ipaddress;
        exit when not FOUND;

        v_has_ip_array = false;
        v_ipaddress = replace(v_ipaddress, ',', ';');
        v_ipaddress = regexp_replace(v_ipaddress, '[^0-9.;]','','g');
        v_ipaddress = replace(v_ipaddress, ';;', ';');
        v_ipaddress = trim(both ';' from v_ipaddress);
        if (position(';' in v_ipaddress) > 0) then
            v_has_ip_array = true;
        end if;

        update import.pbx
            set ipaddress = v_ipaddress,
                has_ip_array = v_has_ip_array
        where  id = v_id;

    end loop;
    close v_cursor;

end;
$$;

alter procedure import.prepare_to_parse_pbx(remove_first_row bool) owner to gsw_datasetter;
--call import.prepare_to_parse_pbx( remove_first_row <= value );