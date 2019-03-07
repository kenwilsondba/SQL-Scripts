--slow queries
select
[query]= SUBSTRING(qt.TEXT, (qs.statement_start_offset/2)+1, ((CASE qs.statement_end_offset WHEN -1 THEN DATALENGTH(qt.TEXT) ELSE qs.statement_end_offset END - qs.statement_start_offset)/2)+1)
,[db]= db_name(qt.dbid)
,[object]= object_name(qt.objectid, qt.dbid)
--,Text
,last_execution_time
,execution_count

--,[total_CPU_time]= total_worker_time/1000000
,[avg_CPU_time]= total_worker_time/execution_count/1000000.0
--,[last_CPU_time]= last_worker_time/1000000
--,[max_CPU_time]= max_worker_time/1000000

--,[total_elapsed_time]= total_elapsed_time/1000000
,[avg_elapsed_time]= total_elapsed_time/execution_count/1000000.0
--,[last_elapsed_time]= last_elapsed_time/1000000
--,[max_elapsed_time]= max_elapsed_time/1000000

--,total_logical_reads
,[avg_logical_reads]= total_logical_reads/execution_count
--,last_logical_reads
--,max_logical_reads

--,total_logical_writes
,[avg_logical_writes]= total_logical_writes/execution_count
--,last_logical_writes
--,max_logical_writes

--,total_physical_reads
,[avg_physical_reads]= total_physical_reads/execution_count
--,last_physical_reads
--,max_physical_reads

,query_plan
--,*
from
sys.dm_exec_query_stats qs
cross apply sys.dm_exec_sql_text(qs.sql_handle) qt
cross apply sys.dm_exec_query_plan(qs.plan_handle) qp
where 1=1
--and db_name(qt.dbid) = 'AdventureWorks'
and execution_count > 10
--and last_execution_time > getdate()-10
--and total_worker_time/1000000 > 10
and total_logical_reads > 100
--and total_physical_reads > 100
order by
--total_worker_time desc
--avg_logical_reads desc
avg_logical_writes desc