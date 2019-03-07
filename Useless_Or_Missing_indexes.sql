--useless indexes
select
[table] = object_name(s.object_id)
,[index] = i.name
,reads = s.user_seeks + s.user_scans + s.user_lookups
,writes = s.user_updates
,si.rows
from sys.dm_db_index_usage_stats s
join sys.indexes i on i.index_id = s.index_id and i.object_id = s.object_id
join sysindexes si on si.id = s.object_id and si.indid < 2  -- to get row count
where
OBJECTPROPERTY(s.object_id,'IsUserTable') = 1
--and OBJECT_NAME(s.object_id) = 'IntegrationQueueOut'
and si.rows > 100000
and s.user_updates - (s.user_seeks + s.user_scans + s.user_lookups) > 10000
and s.user_seeks + s.user_scans + s.user_lookups < 10
order by si.rows desc, writes desc, reads

select
statement,
round( migs.avg_total_user_cost * migs.avg_user_impact * (migs.user_seeks + migs.user_scans) , 0) [cost],
mid.equality_columns,
mid.inequality_columns,
mid.included_columns,
migs.user_seeks,
migs.user_scans,
migs.avg_total_user_cost,
migs.avg_user_impact
from sys.dm_db_missing_index_groups mig
join sys.dm_db_missing_index_group_stats migs ON migs.group_handle = mig.index_group_handle
join sys.dm_db_missing_index_details mid ON mig.index_handle = mid.index_handle
order by cost desc
GO

