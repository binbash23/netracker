CREATE TABLE IF NOT EXISTS "arpevent" (
	"UUID"	TEXT,
	"CREATE_DATE"	datetime not null default (datetime(CURRENT_TIMESTAMP, 'localtime')),
	"IP"	TEXT,
	"HW_TYPE"	TEXT,
	"FLAGS"	TEXT,
	"HW_ADDRESS"	TEXT,
	"MASK"	TEXT,
	"DEVICE"	TEXT,
	PRIMARY KEY("UUID")
);
CREATE TABLE IF NOT EXISTS "sys_config" (
        "PROPERTY"      TEXT,
        "VALUE" TEXT,
        PRIMARY KEY("PROPERTY")
);

