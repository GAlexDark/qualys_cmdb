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
CREATE OR REPLACE PROCEDURE import.prepare_to_parse_virtual_servers(remove_first_row bool default true)
language PLPGSQL
AS $$
declare
    v_cursor refcursor;
    v_id integer;
    v_vip varchar;

begin
    -- stored procedure body
    if (remove_first_row) then
        delete from import.virtual_servers where id=1;
    end if;

    update import.virtual_servers
        set searchcode = trim(both '"' from searchcode),
            name = trim(both '"' from name),
            description = substring(description from '"(.*?[^\\])"$'),
            status = trim(both '"' from status),
            owner = trim(both '"' from owner),
            cpucores = nullif(trim(trim(both '"' from cpucores)),''),
            ram = nullif(trim(trim(both '"' from ram)),''),
            ipaddress = regexp_replace(ipaddress, '[^0-9./]','','g'),
            vip = trim(both '"' from vip),
            os = trim(both '"' from os),
            patchlevel = trim(both '"' from patchlevel),
            avsoft = nullif(trim(trim(both '"' from avsoft)),''),
            avversion = nullif(trim(trim(both '"' from avversion)),''),
            datasource = nullif(trim(trim(both '"' from datasource)),''),
            eos_software = trim(both '"' from eos_software);

    update import.virtual_servers
        set description = replace(description, '""', '"')
    where description like '%""%';

    update import.virtual_servers
        set os = replace(os, '  ', ' ')
    where os like '%  %';

    update import.virtual_servers
        set description = null
    where
          lower(description) = 'нет';
    open v_cursor for select vs.id, vs.vip
        from import.virtual_servers vs where vs.vip is not null;

    loop
        fetch v_cursor into v_id, v_vip;
        exit when not FOUND;

        v_vip = replace(v_vip, ',', ';');
        v_vip = regexp_replace(v_vip, '[^0-9.;]', '', 'g');
        v_vip = replace(v_vip, ';;', ';');
        v_vip = trim(both ';' from v_vip);

        update import.virtual_servers
            set vip = v_vip
        where  id = v_id;

    end loop;
    close v_cursor;

--    delete from import.virtual_servers
--        where ipaddress is null and vip is null;
end;
$$;

alter procedure import.prepare_to_parse_virtual_servers(remove_first_row bool) owner to gsw_datasetter;
--call import.prepare_to_parse_virtual_servers( remove_first_row <= value );