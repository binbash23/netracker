CREATE TABLE IF NOT EXISTS "netevent" (
  "UUID"  TEXT,
  "COLLECTION_UUID"  TEXT,
  "CREATE_DATE" datetime not null default (datetime(CURRENT_TIMESTAMP, 'localtime')),
  "INTERFACE"  TEXT,
  "STATUS" TEXT,
  "IPV4" TEXT,
  "IPV6" TEXT,
  PRIMARY KEY("UUID")
);

