SET @NumDays := 3;

select '<tr><td>', event_schema,
	      '</td><td>', event_name, 
	      '</td><td>', CASE status WHEN 'ENABLED' THEN '<div class="Healthy">Yes</div>' WHEN 'SLAVESIDE_DISABLED' THEN '<div class="Healthy">No</div>' ELSE '<div class="Warning">No</div>' END, 
              '</td><td>', CASE (select count(*) from master.event_history where db = ev.EVENT_SCHEMA and name = ev.EVENT_NAME and errno is null and start >= subdate(now(), @NumDays)) WHEN 0 THEN CONCAT('<div class="Warning">', (select count(*) from master.event_history where db = ev.EVENT_SCHEMA and name = ev.EVENT_NAME and errno is null and start >= subdate(now(), @NumDays)), '</div>') ELSE (select count(*) from master.event_history where db = ev.EVENT_SCHEMA and name = ev.EVENT_NAME and errno is null and start >= subdate(now(), @NumDays)) END,
              '</td><td>', CASE (select count(*) from master.event_history where db = ev.EVENT_SCHEMA and name = ev.EVENT_NAME and errno is not null and start >= subdate(now(), @NumDays)) WHEN 0 THEN '<div class="Healthy">0</div>' ELSE CONCAT('<div class="Critical">', (select count(*) from master.event_history where db = ev.EVENT_SCHEMA and name = ev.EVENT_NAME and errno is not null and start >= subdate(now(), @NumDays)),'</div>') END,
              '</td><td>', last_executed, 
              '</td><td>', case interval_field
                           when "YEAR"	then date_add(last_executed, interval interval_value YEAR)
	                   when "QUARTER"	then date_add(last_executed, interval interval_value QUARTER)
	                   when "MONTH"	then date_add(last_executed, interval interval_value MONTH)
	                   when "DAY"	then date_add(last_executed, interval interval_value DAY)
	                   when "HOUR"	then date_add(last_executed, interval interval_value HOUR)
	                   when "MINUTE"	then date_add(last_executed, interval interval_value MINUTE)
	                   when "WEEK"	then date_add(last_executed, interval interval_value WEEK)
	                   when "SECOND"	then date_add(last_executed, interval interval_value SECOND)
                           end,
              '</td><td>', (select CASE WHEN errno is null THEN CONCAT('<span class="Healthy">', message_text, '</span>') ELSE CONCAT('<span class="Critical">', message_text, '</span>') END from master.event_history where db = ev.EVENT_SCHEMA and name = ev.EVENT_NAME order by start limit 1), '</td></tr>'
from information_schema.EVENTS ev;