CREATE TABLE IF NOT EXISTS "t_arpevent" (
  "UUID"  TEXT,
  "COLLECTION_UUID"  TEXT,
  "CREATE_DATE" datetime not null default (datetime(CURRENT_TIMESTAMP, 'localtime')),
  "IP"  TEXT,
  "HW_TYPE" TEXT,
  "FLAGS" TEXT,
  "HW_ADDRESS"  TEXT,
  "MASK"  TEXT,
  "DEVICE"  TEXT,
  PRIMARY KEY("UUID")
);

