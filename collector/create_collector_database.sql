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
    "IS_RUNNING"     int,
    "NEXT_SCHEDULED_EXECUTION" datetime GENERATED ALWAYS AS (datetime(LAST_EXECUTION, ('+' || INTERVAL_SEC || ' seconds'))) ,
    PRIMARY KEY("NAME")
);
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

