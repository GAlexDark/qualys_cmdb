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
truncate table import.typelib restart identity;
truncate table cmdb.typelib restart identity;

COPY import.typelib (searchcode, name, description, status, owner, ipaddress, vip, manufacturer, model)
FROM '/import/datasource.xls'
WITH (format text, delimiter E'\t', NULL '', encoding 'WIN1251');

delete from import.typelib where id=1;
call import.prepare_to_parse_typelib( false);
call import.parse_typelib();
