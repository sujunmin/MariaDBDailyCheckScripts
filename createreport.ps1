Set-Location "<path>"
$ServerName = "<servername>"
$ServerIP = "<serverip>"
$mysqlexe = "<mysqlexepath>"
$FullBackupPath = "<fullbackuppath>"
$rptuser = "<rptuser>"
$rptpass = "<rptpass>"
$NumDays = 3
$FreeDiskSpacePercentWarningThreshold = 15
$FreeDiskSpacePercentCriticalThreshold = 10
$MailFrom = "<mailfrom>"
$MailTo = "<rcptto>"
$MailServer = "<mailserverip>"


$Html = "<!DOCTYPE HTML PUBLIC ""-//W3C//DTD HTML 4.01 Transitional//EN"">
<html>
<head>
<style type=""text/css"">
table {
font:8pt tahoma,arial,sans-serif;
}
th {
color:#FFFFFF;
font:bold 8pt tahoma,arial,sans-serif;
background-color:#204c7d;
padding-left:5px;
padding-right:5px;
}
td {
color:#000000;
font:8pt tahoma,arial,sans-serif;
border:1px solid #DCDCDC;
border-collapse:collapse;
padding-left:3px;
padding-right:3px;
}
.Warning {
background-color:#FFFF00; 
color:#2E2E2E;
}
.Critical {
background-color:#FF0000;
color:#FFFFFF;
}
.Healthy {
background-color:#458B00;
color:#FFFFFF;
}
h1 {
color:#FFFFFF;
font:bold 16pt arial,sans-serif;
background-color:#204c7d;
text-align:center;
}
h2 {
color:#204c7d;
font:bold 14pt arial,sans-serif;
}
h3 {
color:#204c7d;
font:bold 12pt arial,sans-serif;
}
body {
color:#000000;
font:8pt tahoma,arial,sans-serif;
margin:0px;
padding:0px;
}
</style>
</head>
<body>
<h1>DBA Checks Report for " + $ServerName + " [" + $ServerIP + "]</h1>
<h2>General Health</h2>
<b>System Uptime (MariaDB): "

& $mysqlexe -u $rptuser --password=$rptpass -h $ServerIP -sN -e "source .\Uptime.sql" > out.html

$Html = $Html + (Get-Content .\out.html) + "<br><b>Version: </b>"

& $mysqlexe -u $rptuser --password=$rptpass -h $ServerIP -sN -e "source .\Version.sql" > out.html

$Html = $Html + (Get-Content .\out.html) + "<h2>Disk Drives</h2>"

$Disks = get-wmiobject -Class win32_logicaldisk -Filter "DriveType='3'"

if ($Disks.length -gt 0)
{
  $Html = $Html + "<table>
	<tr>
	<th>Drive</th>
	<th>Label</th>
	<th>Size</th>
	<th>Free</th>
	<th>Free %</th>
	</tr>"

  foreach ($d in $Disks)
  {
    $Html = $Html + "<tr><td>" + $d.DeviceID + "</td><td>" + $d.VolumeName + "</td><td>" + ("{0:N2}" -f ($d.Size / 1073741824)) + " GB</td><td>" + ("{0:N2}" -f ($d.FreeSpace / 1073741824)) + " GB</td><td>" 

    if (($d.FreeSpace / $d.Size * 100) -lt $FreeDiskSpacePercentCriticalThreshold) {$Html = $Html + "<div class=""Critical"">" + ("{0:N2}" -f ($d.FreeSpace / $d.Size * 100))+ "</div></td></tr>"}
     elseif (($d.FreeSpace / $d.Size * 100) -lt $FreeDiskSpacePercentWarningThreshold) {$Html = $Html + "<div class=""Warning"">" + ("{0:N2}" -f ($d.FreeSpace / $d.Size * 100))+ "</div></td></tr>"}
      else {$Html = $Html + "<div class=""Healthy"">" + ("{0:N2}" -f ($d.FreeSpace / $d.Size * 100))+ "</div></td></tr>"}       
  }
  $Html = $Html + "</table>"
   
} else {
          $Html = $Html + "No Disks<br/>"
       }

if ($FullBackupPath -eq ""){}
else {
	$Html = $Html + "<h2>Full Backup Status</h2><table>
		<tr>
		<th>File Name</th>
		<th>Backup Start</th>
		<th>Backup End</th>
		<th>Backup Size</th>
		</tr>"
	Get-ChildItem $FullBackupPath -Filter FullBackup* |
        Foreach-Object {
	   $Html = $Html + "<tr><td>" + $_.FullName + "</td><td>" + $_.CreationTime + "</td><td>" + $_.LastWriteTime + "</td><td>" + ("{0:N2}" -f ($_.Length / 1048576)) + " MB</td></tr>" 
        }

        $Html = $Html  + "</table>"

      }

& $mysqlexe -u $rptuser --password=$rptpass -h $ServerIP -sN -e "source .\CheckSlave.sql" > out.html

if ((Get-Content .\out.html) -ne "")
{
	$Html = $Html + "<h2>Slave Status</h2>"
	& $mysqlexe -u $rptuser --password=$rptpass -h $ServerIP -sN -e "source .\ShowSlaveStatus.sql" > out.html

	if ((Get-Item .\out.html).length -gt 0)
	{
		$Html = $Html + "<table>
		<tr>
		<th>Master Host</th>
		<th>Master Log File</th>
		<th>Relay Master Log File</th>
		<th>Slave IO State</th>
		<th>Slave IO Running</th>
		<th>Slave SQL Running</th>
		<th>Relay Log Space</th>
		<th>Seconds Behind Master</th>
		<th>Last Errno</th>
		<th>Last Error</th>
		<th>Last IO Errno</th>
		<th>Last IO Error</th>
		<th>Last SQL Errno</th>
		<th>Last SQL Error</th>
		</tr>"

		$stat = [string[]](Get-Content .\out.html)

		$Html = $Html + "<tr><td>" + $stat[2] + "</td><td>" + $stat[6] + "</td><td>" + $stat[10] + "</td><td>" + $stat[1] + "</td><td>" + $stat[11] + "</td><td>" + $stat[12] + "</td><td>" + $stat[23] + "</td><td>" + $stat[33] + "</td><td>"

                if ($stat[19] -eq "0") {$Html = $Html + $stat[19] + "</td><td>" + $stat[20] + "</td><td>"}
                else {$Html = $Html + "<div class=""Critical"">" + $stat[19] + "</div></td><td><div class=""Critical"">" + $stat[20] + "</div></td><td>"}
		
		if ($stat[35] -eq "0") {$Html = $Html + $stat[35] + "</td><td>" + $stat[36] + "</td><td>"}
                else {$Html = $Html + "<div class=""Critical"">" + $stat[35] + "</div></td><td><div class=""Critical"">" + $stat[36] + "</div></td><td>"}

		if ($stat[37] -eq "0") {$Html = $Html + $stat[37] + "</td><td>" + $stat[38] + "</div></td></tr></table>"}
                else {$Html = $Html + "<div class=""Critical"">" + $stat[37] + "</div></td><td><div class=""Critical"">" + $stat[38] + "</div></td></tr></table>"}
}
else {
        $Html = $Html + "<span class=""Critical"">No Slave Status</span><br/>"
     }
}

$Html = $Html + "<h2>Events Stats in the last " + $NumDays + " days</h2>"
& $mysqlexe -u $rptuser --password=$rptpass -h $ServerIP -sN -e "source .\EventStatus.sql" > out.html
if ((Get-Item .\out.html).length -gt 0)
{
	$Html = $Html + "<table>
	<tr>
	<th>Database</th>
	<th>Event Name</th>
	<th>Enabled</th>
	<th>Succeed</th>
	<th>Failed</th>
	<th>Last Run Time</th>
	<th>Next Run Time</th>
	<th>Last Result</th>
	</tr>"
        $Html = $Html + (Get-Content .\out.html) + "</table>"
}
else {
        $Html = $Html + "No events<br/>"
     }


$Html = $Html + "<h2>Failed Events in the last " + $NumDays + " days</h2>"
& $mysqlexe -u $rptuser --password=$rptpass -h $ServerIP -sN -e "source .\FailEventStat.sql" > out.html
if ((Get-Item .\out.html).length -gt 0)
{
	$Html = $Html + "<table>
	<tr>
	<th>Database</th>
	<th>Event Name</th>
	<th>Start At</th>
	<th>End At</th>
	<th>Error SQL State</th>
	<th>Errno</th>
	<th>Error Messages</th>
	<th>Record Time</th>
	</tr>"
        $Html = $Html + (Get-Content .\out.html) + "</table>"
}
else {
        $Html = $Html + "<span class=""Healthy"">No failed events</span><br/>"
     }

$Html = $Html + "<h2>Database Files</h2>"
& $mysqlexe -u $rptuser --password=$rptpass -h $ServerIP -sN -e "source .\DatabaseFiles.sql" > out.html
if ((Get-Item .\out.html).length -gt 0)
{
	$Html = $Html + "<table>
	<tr>
	<th>Database</th>
	<th>Table Name</th>
	<th>File Path</th>
	<th>Size in MB</th>
	<th>Used in MB</th>
	<th>Free in MB</th>
	<th>Used %</th>
	</tr>"
        $Html = $Html + (Get-Content .\out.html) + "</table>"
}
else {
        $Html = $Html + "No Database Files<br/>"
     }


$Html = $Html + "<h2>Sessions List</h2>"
& $mysqlexe -u $rptuser --password=$rptpass -h $ServerIP -sN -e "source .\SessionsList.sql" > out.html
if ((Get-Item .\out.html).length -gt 0)
{
	$Html = $Html + "<table>
	<tr>
	<th>id</th>
	<th>user</th>
	<th>host</th>
	<th>db</th>
	<th>command</th>
	<th>info</th>
	<th>state</th>
	<th>memory used</th>
	<th>time</th>
	<th>query id</th>
	</tr>"
        $Html = $Html + (Get-Content .\out.html) + "</table>"
}
else {
        $Html = $Html + "No Sessions<br/>"
     }


$Html = $Html + "</body></html>"

Send-MailMessage -To $MailTo -From $MailFrom -Subject ("DBA Checks (" + $ServerName + ")[" + $ServerIP + "]") -Body "$Html" -BodyAsHtml -SmtpServer $MailServer -Encoding ([System.Text.Encoding]::UTF8)
