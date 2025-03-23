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
CREATE OR REPLACE PROCEDURE import.prepare_to_parse_workstations(remove_first_row bool default true)
language PLPGSQL
AS $$
declare
    v_id integer;
    v_net varchar;
    v_ipaddress varchar;
    v_ipadresses varchar[];
    v_regex varchar;
    v_has_ip_array bool;

    v_cursor refcursor;

begin
    -- stored procedure body
    if (remove_first_row) then
        delete from import.workstations where id=1;
    end if;

    update import.workstations
        set searchcode = trim(both '"' from searchcode),
            name = nullif(trim(trim(both '"' from name)),''),
            description = trim(substring(description from '"(.*?[^\\])"$')),
            status = trim(both '"' from status),
            manufacturer = nullif(trim(trim(both '"' from manufacturer)),''),
            model = nullif(trim(trim(both '"' from model)),''),
            serialnumber = trim(both '"' from serialnumber),
            inventorynumber = trim(both '"' from inventorynumber),
            cpucores = nullif(trim(trim(both '"' from cpucores)),''),
            cpumodel = nullif(trim(trim(both '"' from cpumodel)),''),
            cpucoretechnology = nullif(trim(trim(both '"' from cpucoretechnology)),''),
            cpufrequency = nullif(trim(trim(both '"' from cpufrequency)),''),
            ram = nullif(trim(trim(both '"' from ram)),''),
            vip = trim(both '"' from vip),
            net = nullif(trim(trim(both '"' from net)),''),
            os = trim(both '"' from os),
            avsoft = nullif(trim(trim(both '"' from avsoft)),''),
            avversion = nullif(trim(trim(both '"' from avversion)),''),
            eos_model = trim(both '"' from eos_model),
            eos_software = trim(both '"' from eos_software);

    update import.workstations
        set description = replace(description, '""', '"')
    where description like '%""%';

    delete from import.workstations
        where net is null;

    v_regex = '(?:(?:2[0-4]\d|25[0-5]|1\d{2}|[1-9]?\d)\.){3}(?:2[0-4]\d|25[0-5]|1\d{2}|[1-9]?\d)(?:\:(?:\d|[1-9]\d{1,3}|[1-5]\d{4}|6[0-4]\d{3}|65[0-4]\d{2}|655[0-2]\d|6553[0-5]))?';
    open v_cursor for select vs.id, vs.net
        from import.workstations vs;

    loop
        fetch v_cursor into v_id, v_net;
        exit when not FOUND;

        v_net = replace(v_net, ',', ';');
        v_net = replace(v_net, ';;', ';');
        v_net = trim(both ';' from v_net);
        v_has_ip_array = false;
        if (position(';' in v_net) > 0) then
            v_ipadresses = string_to_array(v_net, ';');
            v_ipadresses = ARRAY(select substring(unnest(v_ipadresses) from v_regex));
            v_ipaddress = array_to_string(v_ipadresses, ';', null);
        else
            v_ipaddress = substring(v_net from v_regex);
        end if;
        v_ipaddress = nullif(v_ipaddress, '');
        if (position(';' in v_ipaddress) > 0) then
            v_has_ip_array = true;
        end if;

        update import.workstations
            set ipaddress = v_ipaddress,
                has_ip_array = v_has_ip_array
        where  id = v_id;

    end loop;
    close v_cursor;

    delete from import.workstations
        where ipaddress is null;
end;
$$;

alter procedure import.prepare_to_parse_workstations(remove_first_row bool) owner to gsw_datasetter;
--call import.prepare_to_parse_workstations( remove_first_row <= value );