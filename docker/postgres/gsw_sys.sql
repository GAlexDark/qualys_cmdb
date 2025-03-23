CREATE ROLE metabase WITH LOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOINHERIT NOREPLICATION encrypted PASSWORD 'P@s$w0rd2';
CREATE TABLESPACE metabase owner metabase location '/var/lib/postgresql/tbspaces/metabase';
CREATE DATABASE metabase WITH OWNER metabase tablespace = metabase;

CREATE ROLE gsw_datasetter CREATEDB SUPERUSER LOGIN  encrypted password 'P@s$w0rd2';
CREATE ROLE gsw_reporter LOGIN  encrypted password 'P@s$w0rd2';

CREATE TABLESPACE gsw_tbs_ad owner gsw_datasetter location '/var/lib/postgresql/tbspaces/gsw_security_audit/gsw_tbs_ad';
CREATE TABLESPACE gsw_tbs_ams owner gsw_datasetter location '/var/lib/postgresql/tbspaces/gsw_security_audit/gsw_tbs_ams';
CREATE TABLESPACE gsw_tbs_cmdb owner gsw_datasetter location '/var/lib/postgresql/tbspaces/gsw_security_audit/gsw_tbs_cmdb';
CREATE TABLESPACE gsw_tbs_import owner gsw_datasetter location '/var/lib/postgresql/tbspaces/gsw_security_audit/gsw_tbs_import';
CREATE TABLESPACE gsw_tbs_network owner gsw_datasetter location '/var/lib/postgresql/tbspaces/gsw_security_audit/gsw_tbs_network';
CREATE TABLESPACE gsw_tbs_qualys owner gsw_datasetter location '/var/lib/postgresql/tbspaces/gsw_security_audit/gsw_tbs_qualys';
CREATE TABLESPACE gsw_tbs_report owner gsw_datasetter location '/var/lib/postgresql/tbspaces/gsw_security_audit/gsw_tbs_report';
CREATE TABLESPACE idx_gsw owner gsw_datasetter location '/var/lib/postgresql/tbspaces/gsw_security_audit/idx_gsw';
CREATE TABLESPACE gsw_data owner gsw_datasetter location '/var/lib/postgresql/tbspaces/gsw_security_audit/gsw_data';

CREATE DATABASE gsw_security_audit with
    owner gsw_datasetter
    template = template0
    tablespace = gsw_data
    ENCODING = 'UTF8'
    LC_COLLATE = 'uk_UA.UTF-8'
    LC_CTYPE = 'uk_UA.UTF-8';
ALTER DATABASE gsw_security_audit SET TIMEZONE = 'Europe/Kiev';

\c metabase
CREATE EXTENSION IF NOT EXISTS citext;

\c gsw_security_audit
CREATE SCHEMA ad authorization gsw_datasetter;
CREATE SCHEMA ams authorization gsw_datasetter;
CREATE SCHEMA cmdb authorization gsw_datasetter;
CREATE SCHEMA import authorization gsw_datasetter;
CREATE SCHEMA network authorization gsw_datasetter;
CREATE SCHEMA qualys authorization gsw_datasetter;
CREATE SCHEMA report authorization gsw_datasetter;
GRANT USAGE ON SCHEMA report TO gsw_reporter;
GRANT USAGE ON SCHEMA qualys TO gsw_reporter;
--GRANT USAGE ON SCHEMA import TO gsw_reporter;
--GRANT CREATE ON SCHEMA report TO gsw_reporter;

-- =======================================================================================
CREATE TABLE IF NOT EXISTS import.assets (  
    id SERIAL NOT NULL primary key,
    asset_id VARCHAR DEFAULT NULL,
    name VARCHAR DEFAULT NULL,
    ipaddress VARCHAR DEFAULT NULL,
    modules VARCHAR DEFAULT NULL,
    os VARCHAR DEFAULT NULL,
    last_logged_in_user VARCHAR DEFAULT NULL,
    last_inventory VARCHAR DEFAULT NULL,
    activity VARCHAR DEFAULT NULL,
    netbios_name VARCHAR DEFAULT NULL,
    sources VARCHAR DEFAULT NULL,
    tags varchar DEFAULT NULL,
    has_ip_array bool default false
) TABLESPACE gsw_tbs_import;
ALTER TABLE IF EXISTS import.assets OWNER to gsw_datasetter;
COMMENT ON TABLE import.assets IS 'Assets from Qualys report';

CREATE TABLE IF NOT EXISTS qualys.assets (
    id SERIAL NOT NULL primary key,
    asset_id bigint not null,
    name VARCHAR,
    short_name VARCHAR,
    ipaddress cidr,
    modules VARCHAR[],
    os VARCHAR,
    last_logged_in_user VARCHAR,
    last_inventory timestamptz,
    activity VARCHAR,
    netbios_name VARCHAR,
    sources VARCHAR,
    tags varchar[]
) TABLESPACE gsw_tbs_qualys;
ALTER TABLE IF EXISTS qualys.assets OWNER to gsw_datasetter;
COMMENT ON TABLE qualys.assets IS 'Assets from Qualys report';
COMMENT ON COLUMN qualys.assets.last_logged_in_user IS '(?) Field for QID 90925 or Qualys Cloud agent gathering info';
COMMENT ON COLUMN qualys.assets.short_name IS 'asset name without domain name';
-- =======================================================================================
CREATE TABLE IF NOT EXISTS import.auth_status (
    id SERIAL NOT NULL primary key,
    host VARCHAR DEFAULT NULL,
    hostname VARCHAR DEFAULT NULL,
    instance VARCHAR DEFAULT NULL,
    status VARCHAR DEFAULT NULL,
    updated_on VARCHAR DEFAULT NULL,
    cause VARCHAR DEFAULT NULL
) TABLESPACE gsw_tbs_import;
ALTER TABLE IF EXISTS import.auth_status OWNER to gsw_datasetter;
COMMENT ON TABLE import.auth_status IS 'Assets from Qualys auth report';

CREATE TABLE IF NOT EXISTS qualys.auth_status (
    id SERIAL NOT NULL primary key,
    host VARCHAR,
    hostname VARCHAR,
    instance VARCHAR,
    status VARCHAR,
    updated_on timestamp,
    cause VARCHAR
) TABLESPACE gsw_tbs_qualys;
ALTER TABLE IF EXISTS qualys.auth_status OWNER to gsw_datasetter;
COMMENT ON TABLE qualys.auth_status IS 'Assets from Qualys auth report';
-- =======================================================================================
CREATE TABLE IF NOT EXISTS import.accounts (
    id SERIAL NOT NULL primary key,
    name VARCHAR DEFAULT NULL,
    title VARCHAR DEFAULT NULL,
    department VARCHAR DEFAULT NULL,
    employeeid VARCHAR DEFAULT NULL,
    samaccountname VARCHAR DEFAULT NULL,
    enabled VARCHAR DEFAULT NULL,
    user_account_control VARCHAR DEFAULT NULL,
    password_last_set VARCHAR DEFAULT NULL
) TABLESPACE gsw_tbs_import;
ALTER TABLE IF EXISTS import.accounts OWNER to gsw_datasetter;
COMMENT ON TABLE import.accounts IS 'Acounts imported from AD';

CREATE TABLE IF NOT EXISTS ad.accounts (
    id SERIAL NOT NULL primary key,
    name VARCHAR DEFAULT NULL,
    mail VARCHAR DEFAULT NULL,
    title VARCHAR DEFAULT NULL,
    department VARCHAR DEFAULT NULL,
    employeeid integer DEFAULT NULL,
    samaccountname VARCHAR DEFAULT NULL,
    enabled boolean DEFAULT NULL,
    user_account_control integer DEFAULT NULL,
    password_last_set timestamptz DEFAULT NULL,
    accountDisabled BOOLEAN DEFAULT NULL,
    is_locked BOOLEAN DEFAULT NULL,
    dontExpirePassword BOOLEAN DEFAULT NULL,
    passwordExpired BOOLEAN DEFAULT NULL,
    account_type VARCHAR[] DEFAULT NULL
) TABLESPACE gsw_tbs_ad;
ALTER TABLE IF EXISTS ad.accounts OWNER to gsw_datasetter;
COMMENT ON TABLE ad.accounts IS 'Acounts imported from AD';
COMMENT ON COLUMN ad.accounts.account_type IS 'Some types: wifi, adm, svc, user';
-- =======================================================================================
CREATE TABLE IF NOT EXISTS network.nac (
    date_written timestamptz,
    MACAddress  VARCHAR,
    ipaddress cidr[],
    FQDN  VARCHAR,
    host_name  VARCHAR,
    IdentityGroup  VARCHAR,
    MatchedPolicy  VARCHAR,
    OUI VARCHAR,
    dhcp_user_class_identifier VARCHAR,
    dhcp_class_identifier VARCHAR,
    dhcp_user_class_id VARCHAR,
    dhcp_parameter_request_list VARCHAR,
    User_Agent VARCHAR,
    User_Name VARCHAR,
    Description VARCHAR,
    description1 VARCHAR,
    ElapsedDays INTEGER,
    InactiveDays INTEGER,
    Called_Station_ID VARCHAR,
    NAS_Port_Type VARCHAR,
    NADAddress cidr[],
    AAA_Server VARCHAR,
    BYODRegistration VARCHAR,
    Calling_Station_ID VARCHAR,
    User_Fetch_User_Name VARCHAR,
    CertificateExpirationDate timestamptz,
    CertificateIssueDate timestamptz,
    CertificateIssuerName VARCHAR,
    CertificateSerialNumber VARCHAR,
    DestinationIPAddress cidr[],
    DeviceIdentifier VARCHAR,
    DeviceName VARCHAR,
    DeviceRegistrationStatus VARCHAR,
    EndPointPolicy VARCHAR,
    EndPointPolicyID VARCHAR,
    EndPointProfilerServer VARCHAR,
    EndPointSource VARCHAR,
    FirstCollection timestamptz,
    FirstCollectionLong timestamptz,
    Framed_ipaddress cidr[],
    IdentityGroupID VARCHAR,
    IdentityStoreGUID VARCHAR,
    IdentityStoreName VARCHAR,
    L4_DST_PORT VARCHAR,
    LastNmapScanTime timestamptz,
    MDMCompliant VARCHAR,
    MDMCompliantFailureReason VARCHAR,
    MDMDiskEncrypted VARCHAR,
    MDMEnrolled VARCHAR,
    MDMImei VARCHAR,
    MDMJailBroken VARCHAR,
    MDMManufacturer VARCHAR,
    MDMModel VARCHAR,
    MDMOSVersion VARCHAR,
    MDMPhoneNumber VARCHAR,
    MDMPinLockSet VARCHAR,
    MDMProvider VARCHAR,
    MDMSerialNumber VARCHAR,
    MDMUptimestamptz VARCHAR,
    MDMServerReachable VARCHAR,
    MDMServerID VARCHAR,
    PhoneID VARCHAR,
    PhoneIDType VARCHAR,
    PreviousDeviceRegistrationStatus VARCHAR,
    MatchedPolicyID VARCHAR,
    NAS_IP_Address cidr[],
    NAS_Port_Id VARCHAR,
    NmapScanCount VARCHAR,
    NmapSubnetScanID VARCHAR,
    OSVersion VARCHAR,
    PolicyVersion VARCHAR,
    PortalUser VARCHAR,
    PostureApplicable VARCHAR,
    PostureOS VARCHAR,
    PostureFailureReason VARCHAR,
    Product VARCHAR,
    RegistrationTimeStamp timestamptz,
    SSID VARCHAR,
    StaticAssignment VARCHAR,
    StaticGroupAssignment VARCHAR,
    TimeToProfile INTEGER,
    TotalCertaintyFactor VARCHAR,
    cdpCacheAddress cidr[],
    cdpCacheCapabilities VARCHAR,
    cdpCacheDeviceId VARCHAR,
    cdpCachePlatform VARCHAR,
    cdpCacheVersion VARCHAR,
    ciaddr VARCHAR,
    dhcp_requested_address VARCHAR,
    hrDeviceDescr VARCHAR,
    ifIndex VARCHAR,
    iotAssetRetrievedFrom VARCHAR,
    iotAssetDeviceType VARCHAR,
    iotAssetProductName VARCHAR,
    iotAssetVendorID VARCHAR,
    iotAssetProductCode VARCHAR,
    iotAssetSerialNumber VARCHAR,
    iotAssetTrustLevel VARCHAR,
    lldpCacheCapabilities VARCHAR,
    lldpCapabilitiesMapSupported VARCHAR,
    lldpSystemDescription VARCHAR,
    operating_system VARCHAR,
    sysDescr VARCHAR,
    snmp_161_udp VARCHAR,
    AUPAccepted VARCHAR,
    LastAUPAccepted timestamptz,
    Uptimestamptz timestamptz,
    UptimestamptzLong timestamptz,
    CreateTime VARCHAR,
    CacheUptimestamptz VARCHAR,
    AC_User_Agent VARCHAR,
    UniqueSubjectID VARCHAR,
    AD_Operating_System VARCHAR,
    AD_OS_Version VARCHAR,
    AD_Service_Pack VARCHAR,
    AD_Host_Exists VARCHAR,
    AD_Join_Point VARCHAR,
    AD_Last_Fetch_Time timestamptz,
    AD_Fetch_Host_Name VARCHAR,
    operating_system_result VARCHAR,
    IsRegistered VARCHAR,
    User_Fetch_First_Name VARCHAR,
    User_Fetch_Email VARCHAR,
    User_Fetch_Last_Name VARCHAR,
    User_Fetch_Department VARCHAR,
    User_Fetch_Telephone VARCHAR,
    User_Fetch_Job_Title VARCHAR,
    User_Fetch_Organizational_Unit VARCHAR,
    User_Fetch_CountryName VARCHAR,
    User_Fetch_LocalityName VARCHAR,
    User_Fetch_StateOrProvinceName VARCHAR,
    User_Fetch_StreetAddress VARCHAR,
    User_Fetch_PassiveID_Username VARCHAR,
    LastActivity timestamptz,
    LastActivityLong timestamptz,
    User_Name1 VARCHAR,
    prn_515_tcp VARCHAR,
    prn_9100_tcp VARCHAR,
    ADDomain VARCHAR,
    Airespace_Wlan_Id VARCHAR,
    AllowedProtocolMatchedRule VARCHAR,
    AuthState VARCHAR,
    AuthenticationIdentityStore VARCHAR,
    AuthenticationMethod VARCHAR,
    AuthorizationPolicyMatchedRule VARCHAR,
    DestinationPort VARCHAR,
    DetailedInfo VARCHAR,
    DeviceIPAddress cidr[],
    DevicePort VARCHAR,
    DeviceType VARCHAR,
    DeviceCompliance VARCHAR,
    EapAuthentication VARCHAR,
    EapChainingResult VARCHAR,
    EapTunnel VARCHAR,
    EndPointMACAddress VARCHAR,
    FailureReason VARCHAR,
    IdentityPolicyMatchedRule VARCHAR,
    IssuedPacInfo VARCHAR,
    L4_SRC_PORT VARCHAR,
    LastAUPAcceptanceHours VARCHAR,
    Location VARCHAR,
    LogicalProfile VARCHAR,
    MACAddress1 VARCHAR,
    MDMMeid VARCHAR,
    MDMServerName VARCHAR,
    MDMUdid VARCHAR,
    MessageCode VARCHAR,
    NAS_Identifier VARCHAR,
    NAS_Port VARCHAR,
    NetworkDeviceGroups VARCHAR,
    NetworkDeviceName VARCHAR,
    OperatingSystem VARCHAR,
    PROTOCOL VARCHAR,
    PortalUser_CreationType VARCHAR,
    PostureAssessmentStatus VARCHAR,
    PostureStatus VARCHAR,
    RadiusPacketType VARCHAR,
    SelectedAccessService VARCHAR,
    SelectedAuthenticationIdentityStores VARCHAR,
    SelectedAuthorizationProfiles VARCHAR,
    Service_Type VARCHAR,
    UserType VARCHAR,
    Vlan VARCHAR,
    VlanName VARCHAR,
    active VARCHAR,
    authStatus VARCHAR,
    byodRegistration1 VARCHAR,
    chaddr VARCHAR,
    client_fqdn VARCHAR,
    customAttrCount VARCHAR,
    device_platform VARCHAR,
    device_platform_version VARCHAR,
    device_type VARCHAR,
    deviceRegistrationStatus1 VARCHAR,
    dhcp_client_identifier VARCHAR,
    dhcp_message_type VARCHAR,
    dhcpv6_vendor_class VARCHAR,
    enabledMDM VARCHAR,
    endpointProfilerServer1 VARCHAR,
    errorMessage VARCHAR,
    fileImportErrorMessage VARCHAR,
    fileImportStatus VARCHAR,
    flags VARCHAR,
    giaddr VARCHAR,
    h323DeviceName VARCHAR,
    h323DeviceVendor VARCHAR,
    h323DeviceVersion VARCHAR,
    hlen VARCHAR,
    hostName VARCHAR,
    htype VARCHAR,
    identityGroup1 VARCHAR,
    ipAddr cidr[],
    ipv6 VARCHAR,
    isMDMEnrolled VARCHAR,
    lldpChassisId VARCHAR,
    lldpSystemName VARCHAR,
    macAddress2 VARCHAR,
    mdmServerName1 VARCHAR,
    mdns_VSM_class_identifier VARCHAR,
    mdns_VSM_srv_identifier VARCHAR,
    mdns_VSM_txt_identifier VARCHAR,
    name VARCHAR,
    nasIPAddress cidr[],
    nasPort VARCHAR,
    nativeDeviceIdentifier VARCHAR,
    nativeMDM VARCHAR,
    op VARCHAR,
    oui1 VARCHAR,
    policyName VARCHAR,
    portalUser1 VARCHAR,
    sipDeviceName VARCHAR,
    sipDeviceVendor VARCHAR,
    sipDeviceVersion VARCHAR,
    staticEndpoint VARCHAR,
    staticGroupEndpoint VARCHAR,
    sysContact VARCHAR,
    sysLocation VARCHAR,
    sysName VARCHAR,
    yiaddr VARCHAR
) TABLESPACE gsw_tbs_network;
ALTER TABLE IF EXISTS network.nac OWNER to gsw_datasetter;

CREATE TABLE IF NOT EXISTS network.network_object_directory (
    id SERIAL NOT NULL primary key,
    type VARCHAR,
    name VARCHAR,
    value VARCHAR,
    prefix VARCHAR,
    ip cidr[]
) TABLESPACE gsw_tbs_network;
ALTER TABLE IF EXISTS network.network_object_directory OWNER to gsw_datasetter;

CREATE TABLE IF NOT EXISTS network.firewall_rules_destinations (
    id SERIAL NOT NULL primary key,
    rule_id INTEGER,
    destination VARCHAR,
    ip cidr[]
) TABLESPACE gsw_tbs_network;
ALTER TABLE IF EXISTS network.firewall_rules_destinations OWNER to gsw_datasetter;

CREATE TABLE IF NOT EXISTS network.firewall_rules_sources (
    id SERIAL NOT NULL primary key,
    rule_id INTEGER,
    source VARCHAR,
    ip cidr[]
) TABLESPACE gsw_tbs_network;
ALTER TABLE IF EXISTS network.firewall_rules_sources OWNER to gsw_datasetter;

CREATE TABLE IF NOT EXISTS network.firewall_rules (
    id SERIAL NOT NULL primary key,
    ruleNo INTEGER,
    status VARCHAR,
    name VARCHAR,
    vpn VARCHAR,
    services_applications VARCHAR,
    content VARCHAR,
    action VARCHAR,
    time VARCHAR,
    track VARCHAR,
    installOn VARCHAR,
    comments VARCHAR
) TABLESPACE gsw_tbs_network;
ALTER TABLE IF EXISTS network.firewall_rules OWNER to gsw_datasetter;
-- =======================================================================================
CREATE TABLE import.virtual_servers(
    id SERIAL NOT NULL primary key,
    searchcode VARCHAR DEFAULT NULL,
    name VARCHAR DEFAULT NULL,
    description VARCHAR DEFAULT NULL,
    status VARCHAR DEFAULT NULL,
    owner VARCHAR DEFAULT NULL,
    cpucores VARCHAR DEFAULT NULL,
    ram VARCHAR DEFAULT NULL,
    ipaddress VARCHAR DEFAULT NULL,
    vip VARCHAR DEFAULT NULL,
    os VARCHAR DEFAULT NULL,
    patchlevel VARCHAR DEFAULT NULL,
    avsoft VARCHAR DEFAULT NULL,
    avversion VARCHAR DEFAULT NULL,
    datasource VARCHAR DEFAULT NULL,
    eos_software VARCHAR DEFAULT NULL
) TABLESPACE gsw_tbs_import;
ALTER TABLE IF EXISTS import.virtual_servers OWNER to gsw_datasetter;
COMMENT ON TABLE import.virtual_servers IS 'Virtual servers';
COMMENT ON COLUMN import.virtual_servers.owner IS 'employeeid from ad.accounts';
COMMENT ON COLUMN import.virtual_servers.status IS 'ToDo: change VARCHAR to INTEGER';

CREATE TABLE cmdb.virtual_servers(
    id SERIAL NOT NULL primary key,
    searchcode VARCHAR default null,
    name VARCHAR default null,
    description VARCHAR default null,
    status VARCHAR default null,
    owner_id INTEGER default null,
    cpucores VARCHAR default null,
    ram VARCHAR default null,
    ipaddress cidr default null,
    vip cidr[] default null,
    os VARCHAR default null,
    patchlevel VARCHAR default null,
    avsoft VARCHAR default null,
    avversion VARCHAR default null,
    datasource VARCHAR default null,
    eos_software DATE default null,
    short_name varchar default null,
    tags VARCHAR[] default null
) TABLESPACE gsw_tbs_cmdb;
ALTER TABLE IF EXISTS cmdb.virtual_servers OWNER to gsw_datasetter;
COMMENT ON TABLE cmdb.virtual_servers IS 'Virtual servers';
COMMENT ON COLUMN cmdb.virtual_servers.owner_id IS 'employeeid from ad.accounts';
COMMENT ON COLUMN cmdb.virtual_servers.status IS 'ToDo: change VARCHAR to INTEGER';
-- =======================================================================================
CREATE TABLE import.physical_servers (
    id SERIAL NOT NULL primary key,
    searchcode VARCHAR DEFAULT NULL,
    name VARCHAR DEFAULT NULL,
    description VARCHAR DEFAULT NULL,
    status VARCHAR DEFAULT NULL,
    owner VARCHAR DEFAULT NULL,
    --manufacturer VARCHAR DEFAULT NULL,
    --model VARCHAR DEFAULT NULL,
    manufacturer_info_id integer default null,
    eos_model VARCHAR DEFAULT NULL,
    serialnumber VARCHAR DEFAULT NULL,
    inventorynumber VARCHAR DEFAULT NULL,
    cpucores VARCHAR DEFAULT NULL,
    cpumodel VARCHAR DEFAULT NULL,
    cpucoretechnology VARCHAR DEFAULT NULL,
    cpufrequency VARCHAR DEFAULT NULL,
    ram VARCHAR DEFAULT NULL,
    location VARCHAR DEFAULT NULL,
    house VARCHAR DEFAULT NULL,
    ipaddress VARCHAR DEFAULT NULL,
    vip VARCHAR DEFAULT NULL,
    os VARCHAR DEFAULT NULL,
    eos_software VARCHAR DEFAULT NULL,    
    avSoft VARCHAR DEFAULT NULL,
    avversion VARCHAR DEFAULT NULL,
    datasource VARCHAR DEFAULT NULL
) TABLESPACE gsw_tbs_import;
ALTER TABLE IF EXISTS import.physical_servers OWNER to gsw_datasetter;
COMMENT ON TABLE import.physical_servers IS 'Physical servers';
COMMENT ON COLUMN import.physical_servers.owner IS 'employeeid from ad.accounts';
COMMENT ON COLUMN import.physical_servers.status IS 'ToDo: change VARCHAR to INTEGER';

CREATE TABLE cmdb.physical_servers (
    id SERIAL NOT NULL primary key,
    searchcode VARCHAR DEFAULT NULL,
    name VARCHAR DEFAULT NULL,
    description VARCHAR DEFAULT NULL,
    status VARCHAR DEFAULT NULL,
    owner_id INTEGER DEFAULT NULL,
    manufacturer VARCHAR DEFAULT NULL,
    model VARCHAR DEFAULT NULL,
    eos_Model DATE DEFAULT NULL,
    serialnumber VARCHAR DEFAULT NULL,
    inventorynumber VARCHAR DEFAULT NULL,
    cpucores VARCHAR DEFAULT NULL,
    cpumodel VARCHAR DEFAULT NULL,
    cpucoretechnology VARCHAR DEFAULT NULL,
    cpufrequency VARCHAR DEFAULT NULL,
    ram VARCHAR DEFAULT NULL,
    location VARCHAR DEFAULT NULL,
    house VARCHAR DEFAULT NULL,
    ipaddress cidr DEFAULT NULL,
    vip cidr[] DEFAULT NULL,
    os VARCHAR DEFAULT NULL,
    eos_Software DATE DEFAULT NULL,
    avsoft VARCHAR DEFAULT NULL,
    avversion VARCHAR DEFAULT NULL,
    datasource VARCHAR DEFAULT NULL,
    short_name VARCHAR DEFAULT NULL,
    tags VARCHAR[] DEFAULT NULL
) TABLESPACE gsw_tbs_cmdb;
ALTER TABLE IF EXISTS cmdb.physical_servers OWNER to gsw_datasetter;
COMMENT ON TABLE cmdb.physical_servers IS 'Physical servers';
COMMENT ON COLUMN cmdb.physical_servers.owner_id IS 'employeeid from ad.accounts';
COMMENT ON COLUMN cmdb.physical_servers.status IS 'ToDo: change VARCHAR to INTEGER';
-- =======================================================================================
CREATE TABLE IF NOT EXISTS import.vmdr_irc_common_stat (
    id SERIAL NOT NULL primary key,
    ipaddress VARCHAR DEFAULT NULL,
    total_vulnerabilities VARCHAR DEFAULT NULL,
    security_risk VARCHAR DEFAULT NULL
) TABLESPACE gsw_tbs_import;
ALTER TABLE IF EXISTS import.vmdr_irc_common_stat OWNER to gsw_datasetter;
COMMENT ON TABLE import.vmdr_irc_common_stat IS 'VMDR IRC common statictics';

CREATE TABLE IF NOT EXISTS report.vmdr_irc_common_stat (
    id SERIAL NOT NULL primary key,
    ipaddress cidr,
    total_vulnerabilities integer,
    security_risk REAL,
    date_written date
) TABLESPACE gsw_tbs_report;
ALTER TABLE IF EXISTS report.vmdr_irc_common_stat OWNER to gsw_datasetter;
COMMENT ON TABLE report.vmdr_irc_common_stat IS 'VMDR IRC common statictics';
-- =======================================================================================
CREATE TABLE IF NOT EXISTS import.ds (
    id SERIAL NOT NULL primary key,
    searchcode VARCHAR DEFAULT NULL,
    name VARCHAR DEFAULT NULL,
    description VARCHAR DEFAULT NULL,
    status VARCHAR DEFAULT NULL,
    owner VARCHAR DEFAULT NULL, --integer
    manufacturer VARCHAR DEFAULT NULL,
    model VARCHAR DEFAULT NULL,
    technomapid_model varchar DEFAULT NULL,
    eos_model VARCHAR DEFAULT NULL,
    serialnumber VARCHAR DEFAULT NULL,
    ipaddress VARCHAR DEFAULT NULL,
    vip VARCHAR DEFAULT NULL,
    firmware VARCHAR DEFAULT NULL,
    eos_software VARCHAR DEFAULT NULL
) TABLESPACE gsw_tbs_import;
ALTER TABLE IF EXISTS import.ds OWNER to gsw_datasetter;
COMMENT ON TABLE import.ds IS 'Disks Storages';
COMMENT ON COLUMN import.ds.owner IS 'employeeid from ad.accounts';

CREATE TABLE IF NOT EXISTS cmdb.ds (
    id SERIAL NOT NULL primary key,
    searchcode VARCHAR DEFAULT NULL,
    name VARCHAR DEFAULT NULL,
    description VARCHAR DEFAULT NULL,
    status VARCHAR DEFAULT NULL,
    owner_id integer default null,
    manufacturer VARCHAR DEFAULT NULL,
    model VARCHAR DEFAULT NULL,
    technomapid_model varchar DEFAULT NULL,
    eos_model DATE DEFAULT NULL,
    serialnumber VARCHAR DEFAULT NULL,
    ipaddress cidr DEFAULT NULL,
    vip cidr[] DEFAULT NULL,
    firmware VARCHAR DEFAULT NULL,
    eos_software DATE DEFAULT NULL,
    tags varchar[] default null
) TABLESPACE gsw_tbs_cmdb;
ALTER TABLE IF EXISTS cmdb.ds OWNER to gsw_datasetter;
COMMENT ON TABLE cmdb.ds IS 'Disks Storages';
COMMENT ON COLUMN cmdb.ds.owner_id IS 'employeeid from ad.accounts';
-- =======================================================================================
CREATE TABLE IF NOT EXISTS import.vmdr_irc_report (
    id SERIAL NOT NULL primary key,
    ip VARCHAR DEFAULT NULL,
    dns VARCHAR DEFAULT NULL,
    netbios VARCHAR DEFAULT NULL,
    tracking_method VARCHAR DEFAULT NULL,
    os VARCHAR DEFAULT NULL,
    ip_status VARCHAR DEFAULT NULL,
    qid VARCHAR DEFAULT NULL,
    title VARCHAR DEFAULT NULL,
    vuln_status VARCHAR DEFAULT NULL,
    type VARCHAR DEFAULT NULL,
    severity VARCHAR DEFAULT NULL,
    port VARCHAR DEFAULT NULL,
    protocol VARCHAR DEFAULT NULL,
    fqdn VARCHAR DEFAULT NULL,
    ssl VARCHAR DEFAULT NULL,
    first_detected VARCHAR DEFAULT NULL,
    last_detected VARCHAR DEFAULT NULL,
    times_detected VARCHAR DEFAULT NULL,
    date_last_fixed VARCHAR DEFAULT NULL,
    cve_id VARCHAR DEFAULT NULL,
    vendor_reference VARCHAR DEFAULT NULL,
    bugtraq_id VARCHAR DEFAULT NULL,
    cvss VARCHAR DEFAULT NULL,
    cvss_base VARCHAR DEFAULT NULL,
    cvss_temporal VARCHAR DEFAULT NULL,
    cvss_environment VARCHAR DEFAULT NULL,
    cvss3 VARCHAR DEFAULT NULL,
    cvss3_base VARCHAR DEFAULT NULL,
    cvss3_temporal VARCHAR DEFAULT NULL,
    threat VARCHAR DEFAULT NULL,
    impact VARCHAR DEFAULT NULL,
    pci_vuln VARCHAR DEFAULT NULL,
    ticket_state VARCHAR DEFAULT NULL,
    instance VARCHAR DEFAULT NULL,
    category VARCHAR DEFAULT NULL,
    associated_tags VARCHAR DEFAULT NULL
) TABLESPACE gsw_tbs_import;
ALTER TABLE IF EXISTS import.vmdr_irc_report OWNER to gsw_datasetter;
COMMENT ON TABLE import.vmdr_irc_report IS 'VMDR IRC report';

CREATE TABLE IF NOT EXISTS qualys.vmdr_irc_report (
    id SERIAL NOT NULL primary key,
    ipaddress cidr,
    dns VARCHAR,
    short_name VARCHAR,
    netbios VARCHAR,
    tracking_method VARCHAR,
    os VARCHAR,
    ip_status VARCHAR[],
    qid INTEGER,
    title VARCHAR,
    vuln_status VARCHAR,
    type VARCHAR,
    severity INTEGER,
    port INTEGER,
    protocol VARCHAR,
    fqdn VARCHAR,
    ssl VARCHAR,
    first_detected timestamptz, --MM/DD/YYYY HH:MM:SS
    last_detected timestamptz, --MM/DD/YYYY HH:MM:SS
    times_detected INTEGER,
    date_last_fixed timestamptz, --MM/DD/YYYY HH:MM:SS
    cve_id VARCHAR[],
    vendor_reference VARCHAR,
    bugtraq_id INTEGER[],
    cvss VARCHAR,
    cvss_base VARCHAR,
    cvss_temporal VARCHAR,
    cvss_environment VARCHAR,
    cvss3 VARCHAR,
    cvss3_base VARCHAR,
    cvss3_temporal VARCHAR,
    threat VARCHAR,
    impact VARCHAR,
    pci_vuln VARCHAR,
    ticket_state VARCHAR,
    instance VARCHAR,
    category VARCHAR,
    associated_tags VARCHAR[]
) TABLESPACE gsw_tbs_qualys;
ALTER TABLE IF EXISTS qualys.vmdr_irc_report OWNER to gsw_datasetter;
COMMENT ON TABLE qualys.vmdr_irc_report IS 'VMDR IRC report';
-- =======================================================================================
