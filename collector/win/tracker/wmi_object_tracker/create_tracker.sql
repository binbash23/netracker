CREATE TABLE IF NOT EXISTS "track_wmiObject" (
  "UUID"  TEXT,
  "COLLECTION_UUID"  TEXT,
  "CREATE_DATE" datetime not null default (datetime(CURRENT_TIMESTAMP, 'localtime')),
  "CLASS"  TEXT,
  "ENABLED"     TEXT,
  PRIMARY KEY("UUID")
);

