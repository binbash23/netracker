<!DOCTYPE html>
<html>
  <head>
    <title>ARP Event Tracker</title>
  </head>
  <body>
    <h1>ARP Event Tracker</h1>
    <p>This PowerShell script tracks ARP events and writes the information in a SQLite database. It was authored by Jens Heine and Andreas Stöcker.</p>
    <h2>Dependencies</h2>
    <p>This script requires the <code>PSSQLite</code> module. If the module is not already installed, the script will attempt to install it with administrator rights using PowerShell's <code>Install-Module</code> cmdlet.</p>
    <h2>Configuration</h2>
    <p>The script creates a SQLite database file named <code>tracker.db</code> in the same directory as the script if it doesn't already exist. It also creates a table named <code>arpevent</code> with the following columns:</p>
    <ul>
      <li>UUID</li>
      <li>IP</li>
      <li>InterfaceIndex</li>
      <li>AddressFamily</li>
      <li>InterfaceAlias</li>
      <li>LinkLayerAddress</li>
      <li>State</li>
      <li>InvalidationCount</li>
      <li>CreationTime</li>
      <li>LastReachableTime</li>
      <li>LastUnreachableTime</li>
      <li>ReachableTime</li>
      <li>UnreachableTime</li>
    </ul>
    <p>If the <code>tracker.db</code> file already exists, the script will use the existing file and table.</p>
    <h2>Usage</h2>
    <p>To use the script, simply run it from PowerShell. It will retrieve ARP events using the <code>Get-NetNeighbor</code> cmdlet, format the results, and insert them into the <code>arpevent</code> table in the SQLite database. The script will generate a new UUID for each ARP event to use as the primary key in the <code>arpevent</code> table.</p>
    <h2>Disclaimer</h2>
    <p>This script is provided as-is, without warranty of any kind. Use at your own risk.</p>
  </body>
</html>
