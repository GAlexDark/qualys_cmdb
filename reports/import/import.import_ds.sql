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
truncate table import.ds restart identity;
truncate table cmdb.ds restart identity;

COPY import.ds (searchcode, name, description, status, owner, manufacturer, model, technomapid_model, eos_model,
                 serialnumber, ipaddress, vip, firmware, eos_software)
FROM '/import/datasource.xls'
WITH (format text, delimiter E'\t', NULL '', encoding 'WIN1251');

delete from import.ds where id=1;
call import.prepare_to_parse_ds( false);
call import.parse_ds();
