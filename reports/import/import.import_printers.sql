/*
  Copyright (c) Oleksii Gaienko, 2021
  Contact: galexsoftware@gmail.com

  Module name: PostgreSQL(R) gsw_security_audit DB import file
  Author(s): Oleksii Gaienko
  Reviewer(s):

  Abstract:
     SQL file for import data into DB.

 */
SET TIME ZONE 'Europe/Kiev';
truncate table import.printers restart identity;
truncate table cmdb.printers restart identity;

COPY import.printers (searchcode, name, description, status, owner, manufacturer, model, serialnumber,
                      ipaddress, vip, net, inventorynumber, userid)
FROM '/import/datasource.xls'
WITH (format text, delimiter E'\t', NULL '', encoding 'WIN1251');

delete from import.printers where id=1;
call import.prepare_to_parse_printers( false);
call import.parse_printers();
