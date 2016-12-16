CREATE PROCEDURE `proc_for_event_history`(
	IN `idb` char(64),
	IN `iname` char(64),
	IN `sql` TEXT
)
LANGUAGE SQL
NOT DETERMINISTIC
CONTAINS SQL
SQL SECURITY DEFINER
COMMENT ''
BEGIN
      DECLARE EXIT HANDLER FOR SQLEXCEPTION
	  BEGIN
		GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE,  @errno = MYSQL_ERRNO, @text = MESSAGE_TEXT;
		select now() into @start from dual;
		insert into master.event_history (`db`, `name`, `start`, `end`, `sqlstate`, `errno`, `message_text`) values (idb, iname, @start, now(), @sqlstate, @errno, @text); 
	  END;
      
     set @sql := `sql`; 
     prepare stmt from @sql;
     
     select now() into @start from dual;
     set @outs := '';
	  execute stmt;
	  if instr(@sql, '@outv') <> 0 then
      select concat('OK ', @outv) into @outs;
     else
      select 'OK' into @outs;
     end if;
  	  insert into master.event_history (`db`, `name`, `start`, `end`, `sqlstate`, `errno`, `message_text`) values (idb, iname, @start, now(), NULL, NULL, @outs); 
     
     DEALLOCATE PREPARE stmt;
END