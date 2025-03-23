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
CREATE OR REPLACE PROCEDURE import.prepare_to_parse_physical_servers(remove_first_row bool default true)
language PLPGSQL
AS $$
declare
    v_cursor refcursor;
    v_id integer;
    v_vip varchar;
    v_pos integer;

begin
    -- stored procedure body
    if (remove_first_row) then
        delete from import.physical_servers where id=1;
    end if;

    update import.physical_servers
        set searchcode = trim(both '"' from searchcode),
            name = trim(both '"' from name),
            description = substring(description from '"(.*?[^\\])"$'),
            status = trim(both '"' from status),
            owner = trim(both '"' from owner),
            manufacturer = substring(manufacturer from '"(.*?[^\\])"$'),
            model = substring(model from '"(.*?[^\\])"$'),
            eos_model = trim(both '"' from eos_model),
            serialnumber = trim(both '"' from serialnumber),
            inventorynumber = trim(both '"' from inventorynumber),
            cpucores = nullif(trim(trim(both '"' from cpucores)),''),
            cpumodel = nullif(trim(trim(both '"' from cpumodel)),''),
            cpucoretechnology = nullif(trim(trim(both '"' from cpucoretechnology)),''),
            cpufrequency = nullif(trim(trim(both '"' from cpufrequency)),''),
            ram = nullif(trim(trim(both '"' from ram)),''),
            location = nullif(trim(trim(both '"' from location)),''),
            house = nullif(trim(trim(both '"' from house)),''),
            --ipaddress = trim(both '"' from ipaddress),
            ipaddress = regexp_replace(ipaddress, '[^0-9.]','','g'),
            vip = trim(both '"' from vip),
            os = trim(both '"' from os),
            eos_software = trim(both '"' from eos_software),
            avsoft = nullif(trim(trim(both '"' from avsoft)),''),
            avversion = nullif(trim(trim(both '"' from avversion)),''),
            datasource = nullif(trim(trim(both '"' from datasource)),'');

    update import.physical_servers
        set ipaddress = null
        where ipaddress = 'N/A';

    update import.physical_servers
        set vip = null
        where vip = 'N/A';

    update import.physical_servers
        set os = replace(os, ' ', ' ');
        update import.physical_servers
        set os = replace(os, '  ', ' ')
        where os like '%  %';

    update import.physical_servers
        set description = replace(description, '""', '"')
        where description like '%""%';
    update import.physical_servers
        set manufacturer = replace(manufacturer, '""', '"')
        where manufacturer like '%""%';
    update  import.physical_servers
        set model = replace(model, '""', '"')
        where model like '%""%';

    open v_cursor for select vs.id, vs.vip
        from import.physical_servers vs where vs.vip is not null;

    loop
        fetch v_cursor into v_id, v_vip;
        exit when not FOUND;

        if (position('VIP IP' in v_vip) > 0) then
            v_vip = lower(v_vip);
            --raise notice 'id: %, VIP: %', v_id, v_vip;

            v_vip = replace(v_vip, 'vip ip:', '');
            v_vip = replace(v_vip, ' ext float/self ip - ', ', ');
            v_pos = position('int float' in v_vip);
            if (v_pos > 1) then
                v_vip = left(v_vip, v_pos - 1);
            end if;
        end if;

        v_vip = replace(v_vip, ',', ';');
        v_vip = regexp_replace(v_vip, '[^0-9.;/]', '','g');
        v_vip = replace(v_vip, ';;', ';');
        v_vip = trim(both ';' from v_vip);

        update import.physical_servers
        set vip = v_vip
        where  id = v_id;

    end loop;
    close v_cursor;

--    delete from import.physical_servers
--        where ipaddress is null and vip is null;


end;
$$;

alter procedure import.prepare_to_parse_physical_servers(remove_first_row bool) owner to gsw_datasetter;
--call import.prepare_to_parse_physical_servers( remove_first_row <= value );