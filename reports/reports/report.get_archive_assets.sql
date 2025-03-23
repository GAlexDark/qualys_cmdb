create or replace view report.get_archive_assets(name, ipaddress, os, owner_id, vip, tags, searchcode) as
SELECT qa.name,
       qa.ipaddress,
       vs.os,
       vs.owner_id,
       vs.vip,
       qa.tags,
       vs.searchcode
FROM qualys.assets qa
         JOIN cmdb.virtual_servers vs ON qa.ipaddress::inet = vs.ipaddress::inet
WHERE vs.status::text = 'Archive'::text
UNION
SELECT qa.name,
       qa.ipaddress,
       ps.os,
       ps.owner_id,
       ps.vip,
       qa.tags,
       ps.searchcode
FROM qualys.assets qa
         JOIN cmdb.physical_servers ps ON qa.ipaddress::inet = ps.ipaddress::inet
WHERE ps.status::text = 'Archive'::text;

alter view report.get_archive_assets owner to gsw_datasetter;
grant select on report.get_archive_assets to gsw_reporter;