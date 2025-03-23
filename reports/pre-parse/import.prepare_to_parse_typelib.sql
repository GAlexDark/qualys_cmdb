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
CREATE OR REPLACE PROCEDURE import.prepare_to_parse_typelib(remove_first_row bool default true)
language PLPGSQL
AS $$
/*
declare
    v_cursor refcursor;
    v_id integer;
    v_vip varchar;
*/
begin
    -- stored procedure body
    if (remove_first_row) then
        delete from import.typelib where id=1;
    end if;

    update import.typelib
        set searchcode = trim(both '"' from searchcode),
            name = trim(both '"' from name),
            description = substring(description from '"(.*?[^\\])"$'),
            status = trim(both '"' from status),
            owner = trim(both '"' from owner),
            ipaddress = regexp_replace(ipaddress, '[^0-9.]', '', 'g'),
            vip = trim(both '"' from vip),
            manufacturer = nullif(trim(trim(both '"' from manufacturer)),''),
            model = nullif(trim(trim(both '"' from model)),'');

    update import.typelib
        set description = null
    where
          lower(description) = 'нет';
/*
    -- -= To future =-
    open v_cursor for select vs.id, vs.vip
        from import.typelib vs where vs.vip is not null;

    loop
        fetch v_cursor into v_id, v_vip;
        exit when not FOUND;

        v_vip = replace(v_vip, ',', ';');
        v_vip = regexp_replace(v_vip, '[^0-9.;]', '', 'g');
        v_vip = replace(v_vip, ';;', ';');
        v_vip = trim(both ';' from v_vip);

        update import.ds
            set vip = v_vip
        where  id = v_id;

    end loop;
    close v_cursor;
*/
--    delete from import.typelib
--        where ipaddress is null and vip is null;
end;
$$;

alter procedure import.prepare_to_parse_typelib(remove_first_row bool) owner to gsw_datasetter;
--call import.prepare_to_parse_typelib( remove_first_row <= value );