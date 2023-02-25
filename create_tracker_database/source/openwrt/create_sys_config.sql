CREATE TABLE IF NOT EXISTS "sys_config" (
        "PROPERTY"      TEXT,
        "VALUE" TEXT,
        PRIMARY KEY("PROPERTY")
);
insert or replace into sys_config (property, value) values ('OS', 'linux');

