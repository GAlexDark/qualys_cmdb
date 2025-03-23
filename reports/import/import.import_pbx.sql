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
truncate table import.pbx restart identity;
truncate table cmdb.pbx restart identity;

COPY import.pbx (searchcode, name, description, status, owner, manufacturer, model, serialnumber, inventorynumber,
                 datasource, pbx_config, ipaddress, reliability_cat, vip, division_owner, division_owner_parent,
                 division_owner_www, division_owner_mail, eos_model, eos_software)
FROM '/import/datasource.xls'
WITH (format text, delimiter E'\t', NULL '', encoding 'WIN1251');

delete from import.pbx where id=1;
call import.prepare_to_parse_pbx( false);
call import.parse_pbx();
