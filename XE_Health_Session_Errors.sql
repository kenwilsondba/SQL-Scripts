--SELECT CAST(target_data as xml) AS targetdata
--FROM sys.dm_xe_session_targets xet
--JOIN sys.dm_xe_sessions xe
--ON xe.address = xet.event_session_address
--WHERE name = 'system_health'

;with events_cte as(
select
DATEADD(mi,
DATEDIFF(mi, GETUTCDATE(), CURRENT_TIMESTAMP),
xevents.event_data.value('(event/@timestamp)[1]', 'datetime2')) AS [err_timestamp],
xevents.event_data.value('(event/data[@name="severity"]/value)[1]', 'bigint') AS [err_severity],
xevents.event_data.value('(event/data[@name="error_number"]/value)[1]', 'bigint') AS [err_number],
xevents.event_data.value('(event/data[@name="message"]/value)[1]', 'nvarchar(512)') AS [err_message],
xevents.event_data.value('(event/action[@name="sql_text"]/value)[1]', 'nvarchar(max)') AS [sql_text],
xevents.event_data
from sys.fn_xe_file_target_read_file
('N:\SQLData_P104A\MSSQL11.PRD1\MSSQL\Log\system_health*.xel',
'N:\SQLData_P104A\MSSQL11.PRD1\MSSQL\Log\system_health*.xem',
null, null)
cross apply (select CAST(event_data as XML) as event_data) as xevents
)
SELECT *
from events_cte
order by err_timestamp;