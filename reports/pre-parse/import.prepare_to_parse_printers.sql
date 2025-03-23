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
CREATE OR REPLACE PROCEDURE import.prepare_to_parse_printers(remove_first_row bool default true)
language PLPGSQL
AS $$
declare
    v_regexp varchar;
begin
    -- stored procedure body
    if (remove_first_row) then
        delete from import.printers where id=1;
    end if;

    v_regexp = '(?:(?:2[0-4]\d|25[0-5]|1\d{2}|[1-9]?\d)\.){3}(?:2[0-4]\d|25[0-5]|1\d{2}|[1-9]?\d)(?:\:(?:\d|[1-9]\d{1,3}|[1-5]\d{4}|6[0-4]\d{3}|65[0-4]\d{2}|655[0-2]\d|6553[0-5]))?';

    update import.printers
        set searchcode = trim(both '"' from searchcode),
            name = trim(both '"' from name),
            description = substring(description from '"(.*?[^\\])"$'),
            status = trim(both '"' from status),
            owner = trim(both '"' from owner),
            manufacturer = nullif(trim(trim(both '"' from manufacturer)),''),
            model = nullif(trim(trim(both '"' from model)),''),
            serialnumber = trim(both '"' from serialnumber),
            ipaddress = substring(net from v_regexp),
            vip = trim(both '"' from vip),
            net = nullif(trim(both '"' from net), '-'),
            inventorynumber = trim(both '"' from inventorynumber),
            userid = trim(both '"' from userid);
/*
    -= To future =-
    v_vip = replace(v_vip, ',', ';');
    v_vip = regexp_replace(v_vip, '[^0-9.]','','g'),
    v_vip = replace(v_vip, ';;', ';');
*/

--    delete from import.printers
--        where ipaddress is null;
end;
$$;

alter procedure import.prepare_to_parse_printers(remove_first_row bool) owner to gsw_datasetter;
--call import.prepare_to_parse_printers( remove_first_row <= value );