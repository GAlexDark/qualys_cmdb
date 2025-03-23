/*
  Copyright (c) Oleksii Gaienko, 2021
  Contact: galexsoftware@gmail.com

  Module name: PostgreSQL(R) gsw_security_audit DB parse file
  Author(s): Oleksii Gaienko
  Reviewer(s):

  Abstract:
     SQL file with source code for parsing data in DB.

  Version: 2

 */

create or replace view cmdb.get_all_nonarchive_assets
            (searchcode, name, description, status, owner, ipaddress, vip, os,  short_name, tags) as
SELECT
       d.searchcode AS searchcode,
       d.name       AS name,
       d.description as description,
       d.status     AS status,
       d.owner_id   as owner,
       d.ipaddress  AS ipaddress,
       d.vip        AS vip,
       concat_ws(' ', mi.manufacturer, mi.model) as os,
       d.short_name as short_name,
       d.tags       AS tags
FROM cmdb.ds d,
     cmdb.manufacturer_info mi
where
      (d.ipaddress is not null or d.vip is not null) and
      d.manufacturer_info_id = mi.id and
      d.status::text <> 'Archive'::text
UNION
SELECT
       ipp.searchcode AS searchcode,
       ipp.name       AS name,
       ipp.description AS description,
       ipp.status     AS status,
       ipp.owner_id as owner,
       ipp.ipaddress  AS ipaddress,
       null         as vip,
       concat_ws(' ', mi.manufacturer, mi.model) as os,
       ipp.short_name as short_name,
       ipp.tags       AS tags
FROM cmdb.ipphones ipp,
     cmdb.manufacturer_info mi
where
      ipp.ipaddress is not null and
      ipp.manufacturer_info_id = mi.id and
      ipp.status::text <> 'Archive'::text
UNION
SELECT
       ne.searchcode AS searchcode,
       ne.name       AS name,
       ne.description as description,
       ne.status     AS status,
       ne.owner_id   as owner,
       ne.ipaddress  AS ipaddress,
       ne.vip        AS vip,
       concat_ws(' ', mi.manufacturer, mi.model) as os,
       ne.short_name as short_name,
       ne.tags       AS tags
FROM cmdb.network_equipment ne,
     cmdb.manufacturer_info mi
where
      ne.ipaddress is not null and
      ne.manufacturer_info_id = mi.id and
      ne.status::text <> 'Archive'::text
UNION
SELECT
       ne.searchcode AS searchcode,
       ne.name       AS name,
       ne.description as description,
       ne.status     AS status,
       ne.owner_id   as owner,
       ne.ipaddress  AS ipaddress,
       ne.vip        AS vip,
       concat_ws(' ', mi.manufacturer, mi.model) as os,
       ne.short_name as short_name,
       ne.tags       AS tags
FROM cmdb.pbx ne,
     cmdb.manufacturer_info mi
where
      ne.ipaddress is not null and
      ne.manufacturer_info_id = mi.id and
      ne.status::text <> 'Archive'::text
union
SELECT
       ne.searchcode AS searchcode,
       ne.name       AS name,
       ne.description as description,
       ne.status     AS status,
       ne.owner_id   as owner,
       ne.ipaddress  AS ipaddress,
       ne.vip        AS vip,
       ne.os         AS os,
       ne.short_name as short_name,
       ne.tags       AS tags
FROM cmdb.physical_servers ne
where
      (ne.ipaddress is not null or ne.vip is not null) and
      ne.status::text <> 'Archive'::text
union
SELECT
       ne.searchcode AS searchcode,
       ne.name       AS name,
       ne.description as description,
       ne.status     AS status,
       ne.owner_id   as owner,
       ne.ipaddress  AS ipaddress,
       ne.vip        AS vip,
       concat_ws(' ', mi.manufacturer, mi.model) as os,
       ne.short_name as short_name,
       ne.tags       AS tags
FROM cmdb.printers ne,
     cmdb.manufacturer_info mi
where
      ne.ipaddress is not null and
      ne.manufacturer_info_id = mi.id and
      ne.status::text <> 'Archive'::text
union
SELECT
       ne.searchcode AS searchcode,
       ne.name       AS name,
       ne.description as description,
       ne.status     AS status,
       ne.owner_id   as owner,
       ne.ipaddress  AS ipaddress,
       ne.vip        AS vip,
       concat_ws(' ', mi.manufacturer, mi.model) as os,
       ne.short_name as short_name,
       ne.tags       AS tags
FROM cmdb.typelib ne,
     cmdb.manufacturer_info mi
where
      ne.ipaddress is not null and
      ne.manufacturer_info_id = mi.id and
      ne.status::text <> 'Archive'::text
union
SELECT
       ne.searchcode AS searchcode,
       ne.name       AS name,
       ne.description as description,
       ne.status     AS status,
       ne.owner_id   as owner,
       ne.ipaddress  AS ipaddress,
       ne.vip        AS vip,
       ne.os         AS os,
       ne.short_name as short_name,
       ne.tags       AS tags
FROM cmdb.virtual_servers ne
where
      (ne.ipaddress is not null or ne.vip is not null) and
      ne.status::text <> 'Archive'::text
union
SELECT
       ne.searchcode AS searchcode,
       ne.name       AS name,
       ne.description as description,
       ne.status     AS status,
       null          as owner,
       ne.ipaddress  AS ipaddress,
       ne.vip        AS vip,
       ne.os         AS os,
       ne.short_name as short_name,
       ne.tags       AS tags
FROM cmdb.workstations ne
where
      ne.ipaddress is not null and
      ne.status::text <> 'Archive'::text;

alter view cmdb.get_all_nonarchive_assets owner to gsw_datasetter;
grant select on cmdb.get_all_nonarchive_assets to gsw_reporter;

