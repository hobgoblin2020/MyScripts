set nocount on;
-- Set the two variables newmodel and oldmodel to the appropriate database names and execute the script

declare @newmodel varchar(50), @oldmodel varchar(50);

Set @newmodel = '[NewModel to Compare]';
set @oldmodel = '[OldModel to Compare]';


Declare @Temp table (TABLE_SCHEMA varchar(40), TABLE_NAME varchar(40), COLUMN_NAME varchar(50), ORDINAL_POSITION int, IS_NULLABLE varchar(5), NullChange varchar(5), Comment varchar(50));

Declare @script varchar(5000);


set @script = '
Select nc.TABLE_SCHEMA, nc.TABLE_NAME, nc.COLUMN_NAME, nc.ORDINAL_POSITION, nc.IS_NULLABLE, IIF(nc.IS_NULLABLE <> oc.IS_NULLABLE, ''Yes'', ''No''), 
        IIF(oc.COLUMN_NAME IS NULL, convert(varchar(20), ''ADDED COLUMN''), convert(varchar(20), ''--'')) as Comment
    from {NEW}.INFORMATION_SCHEMA.COLUMNS nc
        LEFT join {OLD}.INFORMATION_SCHEMA.COLUMNS oc 
            on nc.TABLE_NAME = oc.TABLE_NAME and nc.COLUMN_NAME = oc.COLUMN_NAME
UNION ALL
    Select oc.TABLE_SCHEMA, oc.TABLE_NAME, oc.COLUMN_NAME, oc.ORDINAL_POSITION, oc.IS_NULLABLE, ''No'', ''DELETED COLUMN'' as Comment
    from {OLD}.INFORMATION_SCHEMA.COLUMNS oc
    where CONCAT(oc.TABLE_NAME, ''.'', oc.COLUMN_NAME) 
        not in (Select CONCAT(TABLE_NAME, ''.'', COLUMN_NAME) from {NEW}.INFORMATION_SCHEMA.COLUMNS)
';


Set @script = replace(@script, '{OLD}', @oldmodel);
Set @script = replace(@script, '{NEW}', @newmodel);

--print @script

Insert into @Temp
    exec(@script);

Select * from @Temp where Comment <> '--'
order by TABLE_NAME, ORDINAL_POSITION, COLUMN_NAME;
go
