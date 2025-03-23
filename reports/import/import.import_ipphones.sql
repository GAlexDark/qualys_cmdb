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
truncate table import.ipphones restart identity;
truncate table cmdb.ipphones restart identity;

/*
 Import non-Archive IP-Phones
 */
COPY import.ipphones (searchcode, name, description, status, owner, serialnumber, inventorynumber, manufacturer,
                      model, ipaddress, firmware, update_ownerid, update_managerid, datasource, eos_model, eos_software)
FROM '/import/datasource.xls'
WITH (format text, delimiter E'\t', NULL '', encoding 'WIN1251');

delete from import.ipphones where id=1;
call import.prepare_to_parse_ipphones( false);
call import.parse_ipphones();
