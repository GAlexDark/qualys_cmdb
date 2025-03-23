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
truncate table import.workstations restart identity;
truncate table cmdb.workstations restart identity;

COPY import.workstations (searchcode, name, description, status, manufacturer, model, serialnumber, inventorynumber,
                          cpucores, cpumodel, cpucoretechnology, cpufrequency, ram, ipaddress, vip, net, os, avsoft,
                          avversion, eos_model, eos_software)
FROM '/import/datasource.xls'
WITH (format text, delimiter E'\t', NULL '', encoding 'WIN1251');

delete from import.workstations where id=1;
call import.prepare_to_parse_workstations( false);
call import.parse_workstations();
