declare @Date nvarchar(1024)
declare @BackUpDest nvarchar(1024)
declare @db_name nvarchar(1024)
declare @db_back nvarchar(1024)
declare @back_desc nvarchar(1024)
declare @back_desc_log nvarchar(1024)
declare @backup_opt nvarchar(1024)

--テストのための変数
--SET @Date = N'20131101';
--SET @Date = convert(varchar(10),getDate(),112)
--SET @BackUpDest = 'C:\shimizu\'

--運用時の変数（バッチファイルから渡される）
SET @Date = N'$(Date)';
SET @BackUpDest = N'$(BackUpDest)' + N'\';

select @Date;
select @BackUpDest;

DECLARE db_cursor CURSOR FOR  
SELECT name
FROM master.dbo.sysdatabases
WHERE name NOT IN ('master','model','msdb','tempdb')  ORDER BY name -- exclude these databases

OPEN db_cursor
FETCH NEXT FROM db_cursor INTO @db_name
WHILE @@FETCH_STATUS = 0
BEGIN
        --select @db_name
        set @db_back = @BackUpDest + @db_name + N'_' + @Date + N'.bak';
        set @back_desc = N'DB Backup of ' + @db_name + N' as of  ' + @Date;
        set @back_desc_log = N'LOG Backup of ' + @db_name + N' as of  ' + @Date;
        --SELECT 'DBCC CHECKDB' +  N' ''' + @db_name + N''''
        DBCC CHECKDB (@db_name)
        --select 'BACKUP DATABASE ' + @db_name +' TO  DISK = ' +@db_back +' WITH NOFORMAT, NOINIT,  NAME = '+ @back_desc +' , SKIP, NOREWIND, NOUNLOAD,  STATS = 10, CHECKSUM'
        BACKUP DATABASE @db_name TO  DISK = @db_back WITH NOFORMAT, NOINIT,  NAME = @back_desc , SKIP, NOREWIND, NOUNLOAD,  STATS = 10, CHECKSUM
        BACKUP LOG @db_name TO  DISK = @db_back WITH NOFORMAT, NOINIT,  NAME = @back_desc_log , SKIP, NOREWIND, NOUNLOAD,  STATS = 10, CHECKSUM
    FETCH NEXT FROM db_cursor INTO @db_name
END

CLOSE db_cursor
DEALLOCATE db_cursor