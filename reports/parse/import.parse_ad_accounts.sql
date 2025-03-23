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
CREATE OR REPLACE PROCEDURE import.parse_accounts()
language PLPGSQL
AS $$
declare
    v_name varchar;
    v_mail varchar;
    v_title varchar;
    v_department varchar;
    v_employeeid varchar;
    v_employee_id integer;
    v_samaccountname varchar;
    v_samaccountname1 varchar;
    v_enabled varchar;
    v_is_enabled bool;
    v_user_account_control varchar;
    v_user_account_control1 integer;
    v_password_last_set varchar;
    v_password_last_set_ts timestamptz;
    v_is_account_disabled bool;
    v_is_locked bool;
    v_is_dont_expire_password bool;
    v_is_password_expired bool;
    v_account_type varchar[];

    v_cursor cursor for select vs.name, vs.mail, vs.title, vs.department, vs.employeeid, vs.samaccountname,
                               vs.enabled, vs.user_account_control, vs.password_last_set
        from import.accounts vs;

begin
    -- stored procedure body
    open v_cursor;
    loop
        fetch v_cursor into v_name, v_mail, v_title, v_department, v_employeeid,
                v_samaccountname, v_enabled, v_user_account_control, v_password_last_set;
        exit when not FOUND;

        if (v_employeeid is not null and length(trim(v_employeeid)) != 0) then
            v_employee_id = substring(v_employee_id from '[0-9]+$')::integer;
        else
            v_employee_id = null ;
        end if;

        if (v_enabled IS NOT NULL AND length(trim(v_enabled)) != 0) then
            v_is_enabled = v_enabled::bool;
        else
            v_is_enabled = null ;
        end if;
        if (v_user_account_control IS NOT NULL AND length(trim(v_user_account_control)) != 0) then
            v_user_account_control1 = substring(v_user_account_control from '[0-9]+$')::integer;
        else
            v_user_account_control1 = null ;
        end if;
        if (v_password_last_set IS NOT NULL AND length(trim(v_password_last_set)) != 0) then
            v_password_last_set_ts = to_timestamp(v_password_last_set, 'DD.MM.YYYY HH24:MI:SS');
        else
            v_password_last_set_ts = null ;
        end if;

        v_account_type = null ;
        v_samaccountname1 = lower(v_samaccountname);

        if (position('wifi-' in v_samaccountname1) > 0) then
            v_account_type = v_account_type || '{WIFI}';
        end if;
        if (position('adm-' in v_samaccountname1) > 0) then
            v_account_type = v_account_type || '{ADM}';
        end if;
        if (position('svc' in v_samaccountname1) > 0) then
            v_account_type = v_account_type || '{SVC}';
        end if;

        insert into ad.accounts (name, mail, title, department, employee_id, samaccountname,
                               is_enabled, user_account_control, password_last_set, account_type)
        values (v_name, v_mail, v_title, v_department, v_employee_id, v_samaccountname,
                v_is_enabled, v_user_account_control1, v_password_last_set_ts, v_account_type);
    end loop;
    close v_cursor;
end;
$$;

alter procedure import.parse_accounts() owner to gsw_datasetter;
-- CALL import.parse_accounts();