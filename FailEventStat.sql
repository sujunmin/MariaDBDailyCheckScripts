SET @NumDays := 3;

select '<tr><td>', `db`, '</td><td>', `name`, '</td><td>', `start`, '</td><td>', `end`, '</td><td>', `sqlstate`, '</td><td>', `errno` , '</td><td>', `message_text`, '</td><td>', `record_time`, '</td></tr>' from master.event_history where errno is not null and start >= subdate(now(), @NumDays);