# MariaDBDailyCheckScripts
MariaDB Daily Check Scripts in PowerShell and SQL for Windows

This scripts are inspired from [WiseSoft](http://www.wisesoft.co.uk/) [DBA Daily Checks Email Report](http://www.wisesoft.co.uk/articles/dba_daily_checks_email_report.aspx).

# Preparations
- `CREATE DATABASE master`
- execute [`event_history.sql`](https://raw.githubusercontent.com/sujunmin/MariaDBDailyCheckScripts/master/prep/event_history.sql) to make event history table.
- execute [`proc_for_event_history`](https://raw.githubusercontent.com/sujunmin/MariaDBDailyCheckScripts/master/prep/proc_for_event_history.sql) and make sure all event will be called in this procedure.
- Settings
    
  In createreport.ps1
  - `Set-Location "<path>"` The scripts root path.
  - `$ServerName = "<servername>"` MariaDB server name
  - `$ServerIP = "<serverip>"` MariaDB server IP
  - `$mysqlexe = "<mysqlexepath>"` Path to mysql.exe
  - `$FullBackupPath = "<fullbackuppath>"` Full backup path (If any)
  - `$rptuser = "<rptuser>"` Scripts runner username
  - `$rptpass = "<rptpass>"` Scripts runner password
  - `$NumDays = 3` Get 3 days checks
  - `$FreeDiskSpacePercentWarningThreshold = 15` Free disk space below 15% for warning
  - `$FreeDiskSpacePercentCriticalThreshold = 10` Free disk space below 10% for critical
  - `$MailFrom = "<mailfrom>"` Report sender
  - `$MailTo = "<rcptto>"` Report rcpts
  - `$MailServer = "<mailserverip>"` Mail server IP

  In DatabaseFiles.sql
  - `SET @CriticalThresholdPCT := 95;` More than 95% of Table size for data will be critical 
  - `SET @WarningThresholdPCT := 90;` More than 90% of Table size for data will be warning

  In EventStatus.sql
  - `SET @NumDays := 3;` Get 3 days checks

  In FailEventStat.sql
  - `SET @NumDays := 3;` Get 3 days checks

  In Uptime.sql 
  - `SET @UptimeCritical := 1440;` Less then 1440 min for uptime will be critical
  - `SET @UptimeWarning := 2880;` Less then 2880 min for uptime will be warning
  
# Usage

`powershell createreport.ps1`




