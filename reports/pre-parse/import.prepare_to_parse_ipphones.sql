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
CREATE OR REPLACE PROCEDURE import.prepare_to_parse_ipphones(remove_first_row bool default true)
language PLPGSQL
AS $$
--declare
begin
    -- stored procedure body
    if (remove_first_row) then
        delete from import.ipphones where id=1;
    end if;

    update import.ipphones
        set searchcode = trim(both '"' from searchcode),
            name = nullif(trim(trim(both '"' from name)), ''),
            description = substring(description from '"(.*?[^\\])"$'),
            status = trim(both '"' from status),
            owner = trim(both '"' from owner),
            serialnumber = trim(both '"' from serialnumber),
            inventorynumber = trim(both '"' from inventorynumber),
            manufacturer = nullif(trim(trim(both '"' from manufacturer)),''),
            model = nullif(trim(trim(both '"' from model)),''),
            ipaddress = regexp_replace(ipaddress, '[^0-9.]','','g'),
            firmware = trim(both '"' from firmware),
            update_ownerid = trim(both '"' from update_ownerid),
            update_managerid = trim(both '"' from update_managerid),
            datasource = nullif(trim(trim(both '"' from datasource)),''),
            eos_model = trim(both '"' from eos_model),
            eos_software = trim(both '"' from eos_software);

--    delete from import.ipphones
--        where ipaddress is null;
end;
$$;

alter procedure import.prepare_to_parse_ipphones(remove_first_row bool) owner to gsw_datasetter;
--call import.prepare_to_parse_ipphones( remove_first_row <= value );