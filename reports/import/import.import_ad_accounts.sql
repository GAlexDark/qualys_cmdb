/*
  Copyright (c) Oleksii Gaienko, 2021
  Contact: galexsoftware@gmail.com

  Module name: PostgreSQL(R) gsw_security_audit DB import file
  Author(s): Oleksii Gaienko
  Reviewer(s):

  Abstract:
     SQL file for import data into DB.
     Scenario import data to DB.
 */
SET TIME ZONE 'Europe/Kiev';
truncate table import.accounts restart identity;
truncate table ad.accounts restart identity;

/*
 Import user accounts info from AD
 */
COPY import.accounts (name, mail, title, department, /*employeeid,*/ samaccountname, enabled, user_account_control,
                      password_last_set)
FROM '/import/datasource.csv'
WITH (format text, delimiter E'\t', NULL '', encoding 'UTF8');

delete from import.accounts where id=1;
call import.prepare_to_parse_accounts( false);
call import.parse_accounts();
