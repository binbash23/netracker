CREATE TABLE IF NOT EXISTS "arpevent" (
"UUID" TEXT PRIMARY KEY,
"IP" TEXT NOT NULL,
"InterfaceIndex" INTEGER,
"AddressFamily" INTEGER,
"InterfaceAlias" TEXT,
"LinkLayerAddress" TEXT,
"State" INTEGER,
"InvalidationCount" INTEGER,
"CreationTime" INTEGER,
"LastReachableTime" INTEGER,
"LastUnreachableTime" INTEGER,
"ReachableTime" INTEGER,
"UnreachableTime" INTEGER
);  