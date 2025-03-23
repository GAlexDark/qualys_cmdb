/*
  Copyright (c) Oleksii Gaienko, 2021
  Contact: galexsoftware@gmail.com

  Module name: PostgreSQL(R) gsw_security_audit DB import file
  Author(s): Oleksii Gaienko
  Reviewer(s):

  Abstract:
     SQL file for import data into DB.
 */
drop table if exists cmdb.manufacturer_info;
create table if not exists cmdb.manufacturer_info(
    id SERIAL NOT NULL primary key,
    manufacturer varchar default null,
    model varchar default null
) TABLESPACE gsw_tbs_cmdb;
ALTER TABLE IF EXISTS cmdb.manufacturer_info OWNER to gsw_datasetter;
COMMENT ON TABLE cmdb.manufacturer_info IS 'Assets manufacturer info';

drop table if exists cmdb.hardware_info;
create table if not exists cmdb.hardware_info(
    id                SERIAL NOT NULL primary key,
    cpucores          varchar default null,
    cpumodel          varchar default null,
    cpucoretechnology varchar default null,
    cpufrequency      varchar default null,
    ram               varchar default null
) TABLESPACE gsw_tbs_cmdb;
ALTER TABLE IF EXISTS cmdb.hardware_info OWNER to gsw_datasetter;
COMMENT ON TABLE cmdb.hardware_info IS 'Assets hardware info';

drop table if exists cmdb.location_info;
create table if not exists cmdb.location_info(
    id SERIAL NOT NULL primary key,
    location varchar default null,
    house varchar default null,
    room varchar default null
) TABLESPACE gsw_tbs_cmdb;
ALTER TABLE IF EXISTS cmdb.location_info OWNER to gsw_datasetter;
COMMENT ON TABLE cmdb.location_info IS 'Assets location info';

drop table if exists cmdb.av_info;
create table if not exists cmdb.av_info(
    id SERIAL NOT NULL primary key,
    avsoft varchar default null,
    avversion varchar default null
) TABLESPACE gsw_tbs_cmdb;
ALTER TABLE IF EXISTS cmdb.av_info OWNER to gsw_datasetter;
COMMENT ON TABLE cmdb.av_info IS 'Assets antivirus info';

drop table if exists cmdb.datasource_info;
create table if not exists cmdb.datasource_info(
    id SERIAL NOT NULL primary key,
    datasource varchar default null
) TABLESPACE gsw_tbs_cmdb;
ALTER TABLE IF EXISTS cmdb.datasource_info OWNER to gsw_datasetter;
COMMENT ON TABLE cmdb.datasource_info IS 'Datasource info';

drop table if exists qualys.cve_info;
create table if not exists qualys.cve_info(
    id SERIAL NOT NULL primary key,
    cve_id VARCHAR[] DEFAULT NULL,
    vendor_reference VARCHAR DEFAULT NULL,
    bugtraq_id INTEGER[] DEFAULT NULL,
    threat VARCHAR DEFAULT NULL,
    impact VARCHAR DEFAULT NULL
) TABLESPACE gsw_tbs_qualys;
ALTER TABLE IF EXISTS qualys.cve_info OWNER to gsw_datasetter;
COMMENT ON TABLE qualys.cve_info IS 'CVE info';

drop table if exists qualys.cvss_info;
create table if not exists qualys.cvss_info(
    id SERIAL NOT NULL primary key,
    cvss VARCHAR DEFAULT NULL,
    cvss_base VARCHAR DEFAULT NULL,
    cvss_temporal VARCHAR DEFAULT NULL,
    cvss_environment VARCHAR DEFAULT NULL
    --cvss_environment VARCHAR[] DEFAULT NULL
) TABLESPACE gsw_tbs_qualys;
ALTER TABLE IF EXISTS qualys.cvss_info OWNER to gsw_datasetter;
COMMENT ON TABLE qualys.cvss_info IS 'CVSS info';

drop table if exists qualys.cvss3_info;
create table if not exists qualys.cvss3_info(
    id SERIAL NOT NULL primary key,
    cvss3 VARCHAR DEFAULT NULL,
    cvss3_base VARCHAR DEFAULT NULL,
    cvss3_temporal VARCHAR DEFAULT NULL
) TABLESPACE gsw_tbs_qualys;
ALTER TABLE IF EXISTS qualys.cvss3_info OWNER to gsw_datasetter;
COMMENT ON TABLE qualys.cvss3_info IS 'CVSS3 info';

-- ================================================================================

create or replace function cmdb.get_manufacturer_info(manufacturer varchar, model varchar)
returns integer
language plpgsql
as
$$
declare
    v_manufacturer_info_id integer;
    v_manufacturer varchar;
    v_model varchar;
begin
    v_manufacturer = nullif(trim(manufacturer), '');
    v_model = nullif(trim(model), '');

    if ((v_manufacturer is null or length(v_manufacturer) = 0) and
        (v_model is null or length(v_model) = 0)) then
        return null;
    end if;

    select mi.id into v_manufacturer_info_id
    from cmdb.manufacturer_info mi
    -- ref: https://postgrespro.ru/docs/postgresql/9.5/functions-comparison
    --where mi.manufacturer = v_manufacturer and mi.model = v_model limit 1;
    where (mi.manufacturer IS NOT DISTINCT FROM v_manufacturer) and
          (mi.model IS NOT DISTINCT FROM v_model)
    limit 1;

    if (v_manufacturer_info_id is null) then
        insert into cmdb.manufacturer_info(manufacturer, model)
        values (v_manufacturer, v_model)
        returning id into v_manufacturer_info_id;
    end if;

   return v_manufacturer_info_id;
end;
$$;

create or replace function cmdb.get_hardware_info(cpucores varchar, cpumodel varchar,
                                    cpucoretechnology varchar, cpufrequency varchar, ram varchar)
returns integer
language plpgsql
as
$$
declare
    v_hardware_info_id integer;
    v_cpucores varchar;
    v_cpumodel varchar;
    v_cpucoretechnology varchar;
    v_cpufrequency varchar;
    v_ram varchar;
begin
    v_cpucores = nullif(trim(cpucores), '');
    v_cpumodel = nullif(trim(cpumodel), '');
    v_cpucoretechnology = nullif(trim(cpucoretechnology), '');
    v_cpufrequency = nullif(trim(cpufrequency), '');
    v_ram = nullif(trim(ram), '');

    if ((v_cpucores is null or length(v_cpucores) = 0) and
        (v_cpumodel is null or length(v_cpumodel) = 0) and
        (v_cpucoretechnology is null or length(v_cpucoretechnology) = 0) and
        (v_cpufrequency is null or length(v_cpufrequency) = 0) and
        (v_ram is null or length(v_ram) = 0)) then
        return null;
    end if;

    select hi.id into v_hardware_info_id
    from cmdb.hardware_info hi
/*
    where hi.cpucores = v_cpucores and
          hi.cpumodel = v_cpumodel and
          hi.cpucoretechnology = v_cpucoretechnology and
          hi.cpufrequency = v_cpufrequency and
          hi.ram = v_ram limit 1;
*/
    where (hi.cpucores IS NOT DISTINCT FROM v_cpucores) and
          (hi.cpumodel IS NOT DISTINCT FROM v_cpumodel) and
          (hi.cpucoretechnology IS NOT DISTINCT FROM v_cpucoretechnology) and
          (hi.cpufrequency IS NOT DISTINCT FROM v_cpufrequency) and
          (hi.ram IS NOT DISTINCT FROM v_ram)
    limit 1;

    if (v_hardware_info_id is null) then
        insert into cmdb.hardware_info(cpucores, cpumodel, cpucoretechnology, cpufrequency, ram)
        values (v_cpucores, v_cpumodel, v_cpucoretechnology, v_cpufrequency, v_ram)
        returning id into v_hardware_info_id;
    end if;

   return v_hardware_info_id;
end;
$$;

create or replace function cmdb.get_location_info(location varchar, house varchar, room varchar default null)
returns integer
language plpgsql
as
$$
declare
    v_location_info_id integer;
    v_location varchar;
    v_house varchar;
    v_room varchar;
begin
    v_location = nullif(trim(location), '');
    v_house = nullif(trim(house), '');
    v_room = nullif(trim(room), '');

    if ((v_location is null or length(v_location) = 0) and
        (v_house is null or length(v_house) = 0) and
        (v_room is null or length(v_room) = 0)) then
        return null;
    end if;

    select li.id into v_location_info_id
    from cmdb.location_info li
    where (li.location IS NOT DISTINCT FROM v_location) and
          (li.house IS NOT DISTINCT FROM v_house) and
          (li.room IS NOT DISTINCT FROM v_room)
    limit 1;

    if (v_location_info_id is null) then
        insert into cmdb.location_info (location, house, room)
        values (v_location, v_house, v_room)
        returning id into v_location_info_id;
    end if;

   return v_location_info_id;
end;
$$;

create or replace function cmdb.get_av_info(avsoft varchar, avversion varchar)
returns integer
language plpgsql
as
$$
declare
    v_av_info_id integer;
    v_avsoft varchar;
    v_avversion varchar;
begin
    v_avsoft = nullif(trim(avsoft), '');
    v_avversion = nullif(trim(avversion), '');

    if ((v_avsoft is null or length(v_avsoft) = 0) and
        (v_avversion is null or length(v_avversion) = 0)) then
        return null;
    end if;

    select ai.id into v_av_info_id
    from cmdb.av_info ai
    where (ai.avsoft IS NOT DISTINCT FROM v_avsoft) and
          (ai.avversion IS NOT DISTINCT FROM v_avversion)
    limit 1;

    if (v_av_info_id is null) then
        insert into cmdb.av_info (avsoft, avversion)
        values (v_avsoft, v_avversion)
        returning id into v_av_info_id;
    end if;

   return v_av_info_id;
end;
$$;

create or replace function cmdb.get_datasources_info(datasource varchar)
returns integer
language plpgsql
as
$$
declare
    v_datasource_id integer;
    v_datasource varchar;
begin
    v_datasource = nullif(trim(datasource), '');

    if ((v_datasource is null or length(v_datasource) = 0)) then
        return null;
    end if;

    select ai.id into v_datasource_id
    from cmdb.datasource_info ai
    where (ai.datasource IS NOT DISTINCT FROM v_datasource)
    limit 1;

    if (v_datasource_id is null) then
        insert into cmdb.datasource_info (datasource)
        values (v_datasource)
        returning id into v_datasource_id;
    end if;

   return v_datasource_id;
end;
$$;

create or replace function qualys.get_cve_info(cve_id VARCHAR[], vendor_reference VARCHAR,
                                            bugtraq_id INTEGER[], threat VARCHAR, impact VARCHAR)
returns integer
language plpgsql
as
$$
declare
    v_cve_info_id integer;
    v_cve_id varchar[];
    v_vendor_reference VARCHAR;
    v_bugtraq_id INTEGER[];
    v_threat VARCHAR;
    v_impact VARCHAR;

begin
    v_cve_id = cve_id;
    v_vendor_reference = nullif(trim(vendor_reference),'');
    v_bugtraq_id = bugtraq_id;
    v_threat = nullif(trim(threat),'');
    v_impact = nullif(trim(impact),'');

    if (v_cve_id is null and
        v_vendor_reference is null and
        v_bugtraq_id is null and
        v_threat is null and
        v_impact is null) then
        return null;
    end if;

    select ci.id into v_cve_info_id
    from qualys.cve_info ci
    where (ci.cve_id IS NOT DISTINCT FROM v_cve_id and
           ci.vendor_reference IS NOT DISTINCT FROM v_vendor_reference and
           ci.bugtraq_id IS NOT DISTINCT FROM v_bugtraq_id and
           ci.threat IS NOT DISTINCT FROM v_threat and
           ci.impact IS NOT DISTINCT FROM v_impact)
    limit 1;

    if (v_cve_info_id is null) then
        insert into qualys.cve_info (cve_id, vendor_reference, bugtraq_id, threat, impact)
        values (v_cve_id, v_vendor_reference, v_bugtraq_id, v_threat, v_impact)
        returning id into v_cve_info_id;
    end if;

   return v_cve_info_id;
end;
$$;

create or replace function qualys.get_cvss3_info(cvss3 VARCHAR, cvss3_base VARCHAR,
                                            cvss3_temporal VARCHAR)
returns integer
language plpgsql
as
$$
declare
    v_cvss3_info_id integer;
    v_cvss3 varchar;
    v_cvss3_base varchar;
    v_cvss3_temporal varchar;

begin
    v_cvss3 = nullif(trim(cvss3), '');
    v_cvss3_base = nullif(trim(cvss3_base),'');
    v_cvss3_temporal = nullif(trim(cvss3_temporal),'');

    if (v_cvss3 is null and
        v_cvss3_base is null and
        v_cvss3_temporal is null) then
        return null;
    end if;

    select ci3.id into v_cvss3_info_id
    from qualys.cvss3_info ci3
    where (ci3.cvss3 IS NOT DISTINCT FROM v_cvss3 and
           ci3.cvss3_base IS NOT DISTINCT FROM v_cvss3_base and
           ci3.cvss3_temporal IS NOT DISTINCT FROM v_cvss3_temporal)
    limit 1;

    if (v_cvss3_info_id is null) then
        insert into qualys.cvss3_info (cvss3, cvss3_base, cvss3_temporal)
        values (v_cvss3, v_cvss3_base, v_cvss3_temporal)
        returning id into v_cvss3_info_id;
    end if;

   return v_cvss3_info_id;
end;
$$;

create or replace function qualys.get_cvss_info(cvss VARCHAR, cvss_base VARCHAR,
                                            cvss_temporal VARCHAR, cvss_environment VARCHAR)
returns integer
language plpgsql
as
$$
declare
    v_cvss_info_id integer;
    v_cvss varchar;
    v_cvss_base varchar;
    v_cvss_temporal varchar;
    v_cvss_environment VARCHAR;

begin
    v_cvss = nullif(trim(cvss), '');
    v_cvss_base = nullif(trim(cvss_base),'');
    v_cvss_temporal = nullif(trim(cvss_temporal),'');
    v_cvss_environment = nullif(trim(cvss_environment),'');
    --v_cvss_environment = cvss_environment;

    if (v_cvss is null and
        v_cvss_base is null and
        v_cvss_temporal is null and
        v_cvss_environment is null) then
        return null;
    end if;

    select ci.id into v_cvss_info_id
    from qualys.cvss_info ci
    where (ci.cvss IS NOT DISTINCT FROM v_cvss and
           ci.cvss_base IS NOT DISTINCT FROM v_cvss_base and
           ci.cvss_temporal IS NOT DISTINCT FROM v_cvss_temporal and
           ci.cvss_environment IS NOT DISTINCT FROM v_cvss_environment)
    limit 1;

    if (v_cvss_info_id is null) then
        insert into qualys.cvss_info (cvss, cvss_base, cvss_temporal, cvss_environment)
        values (v_cvss, v_cvss_base, v_cvss_temporal, v_cvss_environment)
        returning id into v_cvss_info_id;
    end if;

   return v_cvss_info_id;
end;
$$;

/*
PostgreSQL, в отличие от MySQL, не показывает случайные данные для столбцов, которые не агрегируются в агрегированном запросе.

Решение содержится в сообщении об ошибке

ERROR:  column "COLUMN" must appear in the GROUP BY clause or be used in an aggregate function
Это означает, что вы должны GROUP BY столбец "messages.date" или использовать агрегатную функцию, такую как MIN() или MAX(), при выборе этого столбца
 */

create or replace function qualys.group_cidr (ip1 cidr, ip2 cidr)
returns cidr
language plpgsql
as
$$
begin
    if (ip1 is null and ip2 is null) then
        return null;
    end if;
    if (ip1 is null) then
        return ip2;
    end if;
    if (ip2 is null) then
        return ip1;
    end if;
    if (ip1 = ip2) then
        return ip1;
    end if;
    return null;
end;
$$;

create aggregate qualys.ipadress_agg (cidr) (
    sfunc = qualys.group_cidr,
    stype = cidr
);

create or replace function qualys.group_int (val1 integer, val2 integer)
returns integer
language plpgsql
as
$$
begin
    if (val1 is null and val2 is null) then
        return null;
    end if;
    if (val1 is null) then
        return val2;
    end if;
    if (val2 is null) then
        return val1;
    end if;
    if (val1 = val2) then
        return val1;
    end if;
    return null;
end;
$$;

create aggregate qualys.integer_agg (integer) (
    sfunc = qualys.group_int,
    stype = integer
);

create or replace function qualys.merge_array (val1 varchar[], val2 varchar[])
returns varchar[]
language plpgsql
as
$$
declare
    retVal varchar[];
begin
    retVal = array_cat(val1, val2);
    retVal = array(select distinct unnest (retVal) as item order by item asc);
    return retVal;
end;
$$;

create aggregate qualys.array_agg (varchar[]) (
    sfunc = qualys.merge_array,
    stype = varchar[]
);