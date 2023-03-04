CREATE TABLE IF NOT EXISTS "hostevent" (
  "UUID"  TEXT,
  "COLLECTION_UUID"  TEXT,
  "CREATE_DATE" datetime not null default (datetime(CURRENT_TIMESTAMP, 'localtime')),
  "IP"  TEXT,
  "DNS_NAME" TEXT,
  "STATUS" TEXT,
  PRIMARY KEY("UUID")
);

