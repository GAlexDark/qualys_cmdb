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
truncate table import.network_equipment restart identity;
truncate table cmdb.network_equipment restart identity;

COPY import.network_equipment (searchcode, name, description, status, workgroup_templ, owner, model, manufacturer,
                               location, house, room, mac, serialnumber, inventorynumber, type_of_equipment,
                               ipaddress, vip, firmware, patchlevel, eos_model, eos_software)
FROM '/import/datasource.xls'
WITH (format text, delimiter E'\t', NULL '', encoding 'WIN1251');

delete from import.network_equipment where id=1;
call import.prepare_to_parse_network_equipment( false);
call import.parse_network_equipment();
