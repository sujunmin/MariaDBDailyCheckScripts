SET @CriticalThresholdPCT := 95;
SET @WarningThresholdPCT  := 90;

SELECT '<tr><td>', table_schema, 
              '</td><td>',table_name,
              '</td><td>', concat(@@datadir, table_schema, '\\', table_name, '.*'),
              '</td><td>', Round((data_length + index_length + data_free) / 1024 / 1024 , 1),
 	      '</td><td>', Round((data_length + index_length) / 1024 / 1024 , 1),
 	      '</td><td>', Round((data_free) / 1024 / 1024 , 1),
 	      '</td><td>', CASE WHEN Round((data_length + index_length)/(data_length + index_length + data_free) * 100 , 2) > @CriticalThresholdPCT AND Round((data_length + index_length + data_free) / 1024 / 1024 , 1) > 1 THEN CONCAT('<div class="Critical">', Round((data_length + index_length)/(data_length + index_length + data_free) * 100 , 2),'</div>')
                                WHEN Round((data_length + index_length)/(data_length + index_length + data_free) * 100 , 2) > @WarningThresholdPCT AND Round((data_length + index_length + data_free) / 1024 / 1024 , 1) > 1 THEN CONCAT('<div class="Warning">', Round((data_length + index_length)/(data_length + index_length + data_free) * 100 , 2),'</div>')
		                ELSE CONCAT('<div class="Healthy">', Round((data_length + index_length)/(data_length + index_length + data_free) * 100 , 2),'</div>') END,
              '</td></tr>'
FROM   information_schema.tables where table_schema not in ('performance_schema', 'mysql', 'information_schema')
order by table_schema, table_name;
