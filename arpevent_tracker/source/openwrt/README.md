<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
</head>
<body>
  <h1>arpevent_tracker.sh</h1>

  <p>This script reads the ARP table from <code> arp -a </code> and stores the information in a SQLite3 database.</p>

  <h2>Installation</h2>

  <ol>
    <li>Clone the repository</li>
    <li>Install SQLite3 if not already installed: <code>sudo apt-get install sqlite3</code> or on openwrt install the package <a href="https://openwrt.org/packages/pkgdata_owrt18_6/libsqlite3">libsqlite3</a> use the package manager: <code>opkg update && opkg install sqlite3</code></li>    
    <li>Run <code>chmod +x arpevent_tracker.sh</code> to make the script executable</li>
  </ol>

  <h2>Usage</h2>

  <ol>
    <li>Run the script: <code>./arpevent_tracker.sh</code></li>
    <li>The script will read the ARP table and store the information in a SQLite3 database named <code>tracker.db</code>.</li>
    <li>The database will be created if it does not exist.</li>
  </ol>

  <h2>Authors</h2>

  <ul>
    <li>Jens Heine &lt;binbash@gmx.net&gt;</li>
    <li>Andreas Stoecker &lt;a.stoecker@gmx.net&gt;</li>
  </ul>
</body>
</html>
