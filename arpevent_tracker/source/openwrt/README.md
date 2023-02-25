<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
</head>
<body>
  <h1>Tracker.sh</h1>

  <p>This script reads the ARP table from <code>/proc/net/arp</code> and stores the information in a SQLite3 database.</p>

  <h2>Installation</h2>

  <ol>
    <li>Clone the repository</li>
    <li>Install SQLite3 if not already installed: <code>sudo apt-get install sqlite3</code></li>
    <li>Run <code>chmod +x tracker.sh</code> to make the script executable</li>
  </ol>

  <h2>Usage</h2>

  <ol>
    <li>Run the script: <code>./tracker.sh</code></li>
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
