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
CREATE OR REPLACE PROCEDURE import.prepare_to_parse_accounts(remove_first_row bool default true)
language PLPGSQL
AS $$
declare
    v_cursor refcursor;
    v_id integer;
    v_vip varchar;

begin
    -- stored procedure body
    if (remove_first_row) then
        delete from import.accounts where id=1;
    end if;

    update import.accounts
        set name = trim(both '"' from name),
            mail = trim(both '"' from mail),
            title = trim(substring(title from '"(.*?[^\\])"$')),
            department = trim(substring(department from '"(.*?[^\\])"$')),
            employeeid = trim(both '"' from employeeid),
            samaccountname = trim(both '"' from samaccountname),
            enabled = trim(both '"' from enabled),
            user_account_control = trim(both '"' from user_account_control),
            password_last_set = trim(both '"' from password_last_set);

    update import.accounts
        set department = replace(department, '""', '"')
        where department like '%""%';

    update import.accounts
        set title = replace(title, '""', '"')
        where title like '%""%';


--    delete from import.accounts
--        where employeeid is null;
end;
$$;

alter procedure import.prepare_to_parse_accounts(remove_first_row bool) owner to gsw_datasetter;
--call import.prepare_to_parse_accounts( remove_first_row <= value );