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
truncate table import.virtual_servers restart identity;
truncate table cmdb.virtual_servers restart identity;

COPY import.virtual_servers (searchcode, name, description, status, owner,
                              cpucores, ram, ipaddress, vip, os, patchlevel, avsoft,
                             avversion, datasource, eos_software)
FROM '/import/datasource.xls'
WITH (format text, delimiter E'\t', NULL '', encoding 'WIN1251');

delete from import.virtual_servers where id=1;
call import.prepare_to_parse_virtual_servers( false);
call import.parse_virtual_servers();





