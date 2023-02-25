<!DOCTYPE html>
<html>
<head>
	<title>Track arp events and write information in sqlite db</title>
</head>
<body>
	<h1>Track arp events and write information in sqlite db</h1>

	<p>This script was authored by Jens Heine and Andreas Stöcker, with the purpose of tracking arp events and writing information in a SQLite database.</p>

	<h2>Dependencies</h2>
	<p>The script checks if the <code>PSSQLite</code> module is installed, and if not, it installs it with administrator rights.</p>

	<h2>Configuration</h2>
	<p>The script sets the name and path of the database file, and creates a new SQLite database file if it does not already exist. It also creates an <code>arpevent</code> table within the database.</p>

	<h2>Main</h2>
	<p>The script retrieves information about network neighbors using the <code>Get-NetNeighbor</code> cmdlet, and inserts this information into the <code>arpevent</code> table of the SQLite database. The information includes UUID, IP address, interface index, address family, interface alias, link layer address, state, invalidation count, creation time, last reachable time, last unreachable time, reachable time, and unreachable time.</p>

	<h2>Usage</h2>
	<ol>
		<li>Clone the repository or download the script file.</li>
		<li>Open PowerShell and navigate to the directory containing the script.</li>
		<li>Run the script by entering <code>.\\&lt;script-name&gt;.ps1</code> and press Enter.</li>
		<li>The script will track arp events and write the information to the SQLite database file.</li>
	</ol>

	<h2>Troubleshooting</h2>
	<p>If the <code>PSSQLite</code> module fails to install with administrator rights, you will need to install it manually and then run the script again.</p>

	<h2>PowerShell Execution Policies</h2>
	<p>PowerShell Execution Policies are security settings that determine the conditions under which PowerShell scripts are allowed to run. They are used to prevent the execution of malicious scripts that could harm your computer or network.</p>

	<p>There are several levels of execution policies:</p>

	<ul>
		<li><code>Restricted</code>: This is the default execution policy, and it prevents all scripts from running.</li>
		<li><code>AllSigned</code>: Only scripts signed by a trusted publisher can run.</li>
		<li><code>RemoteSigned</code>: Scripts downloaded from the internet must be signed by a trusted publisher, but locally created scripts can run without a signature.</li>
		<li><code>Unrestricted</code>: Any script can run, regardless of its origin or signature.</li>
		<li><code>Bypass</code>: No restrictions are applied, and all scripts can run. This is not recommended for production environments.</li>
	</ul>

	<p>You can view the current execution policy by running the <code>Get-ExecutionPolicy</code> cmdlet in PowerShell. To change the execution policy, you can run the <code>Set-ExecutionPolicy</code> cmdlet with the desired policy level as the parameter.</p>

	<p>It is important to note that changing the execution policy can have security implications, and should be done with caution. In general, it is best to use the most restrictive policy that allows your scripts to run. If you are unsure
