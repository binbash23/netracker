/*

20230305 jens heine <binbash@gmx.net>, andreas stoecker <a.stoecker@gmx.net>

Basic database structure creation script.

*/


CREATE TABLE IF NOT EXISTS "sys_config" (
        "CREATE_DATE" datetime not null default (datetime(CURRENT_TIMESTAMP, 'localtime')),
        "PROPERTY"    TEXT,
        "VALUE"       TEXT,
        PRIMARY KEY("PROPERTY")
);
CREATE TABLE IF NOT EXISTS "tracker_config" (
    "CREATE_DATE" datetime not null default (datetime(CURRENT_TIMESTAMP, 'localtime')),
    "NAME"        TEXT,
    "ENABLED"     int,
    "INTERVAL_SEC"     INT,
    "LAST_EXECUTION"     datetime,
    "IS_RUNNING"     int default 0,
    "NEXT_SCHEDULED_EXECUTION" datetime GENERATED ALWAYS AS (datetime(LAST_EXECUTION, ('+' || INTERVAL_SEC || ' seconds'))) ,
    PRIMARY KEY("NAME")
);
CREATE VIEW if not exists v_tracker_config_calc as
SELECT
*,
case when NEXT_SCHEDULED_EXECUTION < datetime(CURRENT_TIMESTAMP, 'localtime') or LAST_EXECUTION is NULL then 1 else 0 end as SHOULD_RUN,
strftime('%s', NEXT_SCHEDULED_EXECUTION) - strftime('%s', datetime(CURRENT_TIMESTAMP, 'localtime')) as NEXT_RUN_SECONDS_DELTA
FROM
tracker_config;
/*
CREATE TABLE IF NOT EXISTS "Tracker_Group" (
        "UUID"      TEXT,
        "CREATE_DATE" datetime not null default (datetime(CURRENT_TIMESTAMP, 'localtime')),
        "NAME"       TEXT,
        "PARENT"     TEXT,
        "ENABLED"    TEXT,
        "SCHEDULE"   DATE,  
        PRIMARY KEY("TG_ID")
);*/

CREATE TABLE IF NOT EXISTS "log" (
        "ID"          INTEGER PRIMARY KEY AUTOINCREMENT,
        "CREATE_DATE" datetime not null default (datetime(CURRENT_TIMESTAMP, 'localtime')),
        "LOG_LEVEL"   TEXT,
        "MESSAGE"     TEXT not null,
        "SOURCE"      TEXT,
        "COLLECTION_UUID" TEXT
);

