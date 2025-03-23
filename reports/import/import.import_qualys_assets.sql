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
truncate table import.assets restart identity;
truncate table qualys.assets restart identity;

COPY import.assets(asset_id, name, ipaddress, modules, os, last_logged_in_user, last_inventory, activity,
                   netbios_name, sources, tags)
FROM '/import/datasource.csv'
WITH (format csv, delimiter ',', NULL '', header true, QUOTE '"', encoding 'UTF8');

call import.prepare_to_parse_qualys_assets();
call import.parse_qualys_assets();

