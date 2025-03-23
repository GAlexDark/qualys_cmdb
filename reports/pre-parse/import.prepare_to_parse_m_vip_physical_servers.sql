/*
  Copyright (c) Oleksii Gaienko, 2021
  Contact: galexsoftware@gmail.com

  Module name: PostgreSQL(R) gsw_security_audit DB parse file
  Author(s): Oleksii Gaienko
  Reviewer(s):

  Abstract:
     SQL file with source code for parsing data in DB.

  Version: deprecated
 */
create or replace function import.prepare_to_parse_m_vip_physical_servers( vip varchar) returns varchar
language PLPGSQL
AS $$
declare
    v_vip varchar;
    v_pos integer;
begin
    if (vip is null or length(vip) = 0) then
        return null;
    end if;

    v_vip = lower(vip);
    if (position('vip ip:' in v_vip) = 1) then
        v_vip = replace(v_vip, 'vip ip:', '');
        v_vip = replace(v_vip, ' ext float/self ip - ', ', ');
        v_pos = position('int float' in v_vip);
        if (v_pos > 1) then
            v_vip = left(v_vip, v_pos - 1);
            v_vip = trim(both ' ' from v_vip);
            return v_vip;
        end if;
    end if;
    return vip;
end;
$$;

alter function import.prepare_to_parse_m_vip_physical_servers( vip varchar) owner to gsw_datasetter;
--call import.prepare_to_parse_m_vip_physical_servers( vip <== value>);