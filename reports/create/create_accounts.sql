/*
  Copyright (c) Oleksii Gaienko, 2021
  Contact: galexsoftware@gmail.com

  Module name: PostgreSQL(R) gsw_security_audit DB import file
  Author(s): Oleksii Gaienko
  Reviewer(s):

  Abstract:
     SQL file for import data into DB.
 */
drop table if exists import.accounts;
CREATE TABLE IF NOT EXISTS import.accounts (
    id SERIAL NOT NULL primary key,
    name VARCHAR DEFAULT NULL,
    mail VARCHAR DEFAULT NULL,
    title VARCHAR DEFAULT NULL,
    department VARCHAR DEFAULT NULL,
    employeeid VARCHAR DEFAULT NULL,
    samaccountname VARCHAR DEFAULT NULL,
    enabled VARCHAR DEFAULT NULL,
    user_account_control VARCHAR DEFAULT NULL,
    password_last_set VARCHAR DEFAULT NULL
) TABLESPACE gsw_tbs_import;
ALTER TABLE IF EXISTS import.accounts OWNER to gsw_datasetter;
COMMENT ON TABLE import.accounts IS 'Acounts imported from AD';

drop table if exists ad.accounts;
CREATE TABLE IF NOT EXISTS ad.accounts (
    id SERIAL NOT NULL primary key,
    name VARCHAR DEFAULT NULL,
    mail VARCHAR DEFAULT NULL,
    title VARCHAR DEFAULT NULL,
    department VARCHAR DEFAULT NULL,
    employee_id integer DEFAULT NULL,
    samaccountname VARCHAR DEFAULT NULL,
    is_enabled boolean DEFAULT NULL,
    user_account_control integer DEFAULT NULL,
    password_last_set timestamptz DEFAULT NULL,
    is_account_disabled BOOLEAN DEFAULT NULL,
    is_locked BOOLEAN DEFAULT NULL,
    is_dont_expire_password BOOLEAN DEFAULT NULL,
    is_password_expired BOOLEAN DEFAULT NULL,
    account_type VARCHAR[] DEFAULT NULL
) TABLESPACE gsw_tbs_ad;
ALTER TABLE IF EXISTS ad.accounts OWNER to gsw_datasetter;
COMMENT ON TABLE ad.accounts IS 'Acounts imported from AD';
COMMENT ON COLUMN ad.accounts.account_type IS 'Some types: wifi, adm, svc, user';