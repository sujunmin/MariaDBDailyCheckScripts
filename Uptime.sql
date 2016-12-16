SET @UptimeCritical := 1440;
SET @UptimeWarning := 2880;



SELECT CONCAT(CASE WHEN CAST(VARIABLE_VALUE as unsigned integer) < @UptimeCritical * 60 THEN '<span class="Critical">'
                   WHEN CAST(VARIABLE_VALUE as unsigned integer) < @UptimeWarning * 60 THEN '<span class="Warning">'
		   ELSE '<span class="Healthy">' END,
FLOOR(HOUR(SEC_TO_TIME(VARIABLE_VALUE)) / 24), ' day(s), ',
MOD(HOUR(SEC_TO_TIME(VARIABLE_VALUE)), 24), ' hour(s), ',
MINUTE(SEC_TO_TIME(VARIABLE_VALUE)), ' minute(s)</span>')
from information_schema.GLOBAL_STATUS where VARIABLE_NAME='UPTIME';
