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
truncate table import.physical_servers restart identity;
truncate table cmdb.physical_servers restart identity;

COPY import.physical_servers (searchcode, name, description, status, owner,
                              manufacturer, model, eos_model, serialnumber, inventorynumber,
                              cpucores, cpumodel, cpucoretechnology, cpufrequency, ram, location,
                              house, ipaddress, vip, os, eos_software, avsoft, avversion, datasource)
FROM '/import/datasource.xls'
WITH (format text, delimiter E'\t', NULL '', encoding 'WIN1251');

delete from import.physical_servers where id=1;
call import.prepare_to_parse_physical_servers(false);
call import.parse_physical_servers();



