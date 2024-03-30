--CREATE PROC SearchAllTables
--(
--	@SearchStr nvarchar(100)
--)
--AS
--BEGIN

	-- Copyright � 2002 Narayana Vyas Kondreddi. All rights reserved.
	-- Purpose: To search all columns of all tables for a given search string
	-- Written by: Narayana Vyas Kondreddi
	-- Site: http://vyaskn.tripod.com
	-- Tested on: SQL Server 7.0 and SQL Server 2000
	-- Date modified: 28th July 2002 22:50 GMT

/* 
	Modified by: howard@pincham.net, CoPilot for GitHub
	Date: 3/30/2023
		Need to improve search for credit card numbers in a database.
		Modified to search for credit card numbers in the following formats:
		Visa: Starts with a 4, 13 or 16 digit.
		MasterCard: Starts with the numbers 51 through 55 or 2221 through 2720. All have 16 digits.
		American Express: Starts with 34 or 37. All have 15 digits.
		Discover: Starts with 6011 or 65. All have 16 digits. 
		Added wildcard to locate extendedcard numbers
*/




DECLARE @SearchStr nvarchar(100)
--SET @SearchStr = '4[01234567890][01234567890][01234567890]-[01234567890][01234567890][01234567890][01234567890]-[01234567890][01234567890][01234567890][01234567890]-[01234567890][01234567890][01234567890][01234567890]'


	IF OBJECT_ID('tempdb..#Results') IS NOT NULL
		DROP TABLE #Results
	CREATE TABLE #Results (ColumnName nvarchar(370), ColumnValue nvarchar(3630))

	SET NOCOUNT ON

	DECLARE @TableName nvarchar(256), @ColumnName nvarchar(128), @SearchStr2 nvarchar(110)
	SET  @TableName = ''
	--SET @SearchStr2 = QUOTENAME('%' + @SearchStr + '%','''')

	WHILE @TableName IS NOT NULL
	BEGIN
		SET @ColumnName = ''
		SET @TableName = 
		(
			SELECT MIN(QUOTENAME(TABLE_SCHEMA) + '.' + QUOTENAME(TABLE_NAME))
			FROM 	INFORMATION_SCHEMA.TABLES
			WHERE 		TABLE_TYPE = 'BASE TABLE'
				AND	QUOTENAME(TABLE_SCHEMA) + '.' + QUOTENAME(TABLE_NAME) > @TableName
				AND	OBJECTPROPERTY(
						OBJECT_ID(
							QUOTENAME(TABLE_SCHEMA) + '.' + QUOTENAME(TABLE_NAME)
							 ), 'IsMSShipped'
						       ) = 0
		)

		WHILE (@TableName IS NOT NULL) AND (@ColumnName IS NOT NULL)
		BEGIN
			SET @ColumnName =
			(
				SELECT MIN(QUOTENAME(COLUMN_NAME))
				FROM 	INFORMATION_SCHEMA.COLUMNS
				WHERE 		TABLE_SCHEMA	= PARSENAME(@TableName, 2)
					AND	TABLE_NAME	= PARSENAME(@TableName, 1)
					AND	DATA_TYPE IN ('char', 'varchar', 'nchar', 'nvarchar')
					AND	QUOTENAME(COLUMN_NAME) > @ColumnName
			)
	
			IF @ColumnName IS NOT NULL
			BEGIN
				INSERT INTO #Results
				EXEC
				(
					--Visa, dash separated
					'SELECT ''' + @TableName + '.' + @ColumnName + ''', LEFT(' + @ColumnName + ', 3630) 
					FROM ' + @TableName + ' (NOLOCK) ' +
					' WHERE ' + @ColumnName + ' LIKE ''4[01234567890][01234567890][01234567890]-[01234567890][01234567890][01234567890][01234567890]-[01234567890][01234567890][01234567890][01234567890]-[01234567890][01234567890][01234567890][01234567890]'''
				)
				INSERT INTO #Results
				EXEC
				(
					--JCB, space separated
					'SELECT ''' + @TableName + '.' + @ColumnName + ''', LEFT(' + @ColumnName + ', 3630) 
					FROM ' + @TableName + ' (NOLOCK) ' +
					' WHERE ' + @ColumnName + ' LIKE ''3[01234567890][01234567890][01234567890] [01234567890][01234567890][01234567890][01234567890] [01234567890][01234567890][01234567890][01234567890] [01234567890][01234567890][01234567890][01234567890]'''
				)
				INSERT INTO #Results
				EXEC
				(
					--JCB, no seperators
					'SELECT ''' + @TableName + '.' + @ColumnName + ''', LEFT(' + @ColumnName + ', 3630) 
					FROM ' + @TableName + ' (NOLOCK) ' +
					' WHERE ' + @ColumnName + ' LIKE ''3[01234567890][01234567890][01234567890][01234567890][01234567890][01234567890][01234567890][01234567890][01234567890][01234567890][01234567890][01234567890][01234567890][01234567890][01234567890]'''
				)				INSERT INTO #Results
				EXEC
				(
					--JCB, dash separated
					'SELECT ''' + @TableName + '.' + @ColumnName + ''', LEFT(' + @ColumnName + ', 3630) 
					FROM ' + @TableName + ' (NOLOCK) ' +
					' WHERE ' + @ColumnName + ' LIKE ''3[01234567890][01234567890][01234567890]-[01234567890][01234567890][01234567890][01234567890]-[01234567890][01234567890][01234567890][01234567890]-[01234567890][01234567890][01234567890][01234567890]'''
				)
				INSERT INTO #Results
				EXEC
				(
					--Visa, space separated
					'SELECT ''' + @TableName + '.' + @ColumnName + ''', LEFT(' + @ColumnName + ', 3630) 
					FROM ' + @TableName + ' (NOLOCK) ' +
					' WHERE ' + @ColumnName + ' LIKE ''4[01234567890][01234567890][01234567890] [01234567890][01234567890][01234567890][01234567890] [01234567890][01234567890][01234567890][01234567890] [01234567890][01234567890][01234567890][01234567890]'''
				)
				INSERT INTO #Results
				EXEC
				(
					--Visa, no seperators
					'SELECT ''' + @TableName + '.' + @ColumnName + ''', LEFT(' + @ColumnName + ', 3630) 
					FROM ' + @TableName + ' (NOLOCK) ' +
					' WHERE ' + @ColumnName + ' LIKE ''4[01234567890][01234567890][01234567890][01234567890][01234567890][01234567890][01234567890][01234567890][01234567890][01234567890][01234567890][01234567890][01234567890][01234567890][01234567890]'''
				)
				INSERT INTO #Results
				EXEC
				(
					--Visa, dash seperated
					'SELECT ''' + @TableName + '.' + @ColumnName + ''', LEFT(' + @ColumnName + ', 3630) 
					FROM ' + @TableName + ' (NOLOCK) ' +
					' WHERE ' + @ColumnName + ' LIKE ''4[01234567890][01234567890][01234567890]-[01234567890][01234567890][01234567890][01234567890]-[01234567890][01234567890][01234567890][01234567890]-[01234567890][01234567890][01234567890][01234567890]'''
				)
				INSERT INTO #Results
				EXEC
				(
					--MasterCard, dash separated
					'SELECT ''' + @TableName + '.' + @ColumnName + ''', LEFT(' + @ColumnName + ', 3630) 
					FROM ' + @TableName + ' (NOLOCK) ' +
					' WHERE ' + @ColumnName + ' LIKE ''[2,5][01234567890][01234567890][01234567890]-[01234567890][01234567890][01234567890][01234567890]-[01234567890][01234567890][01234567890][01234567890]-[01234567890][01234567890][01234567890][01234567890]'''
				)
				INSERT INTO #Results
				EXEC
				(
					--MasterCard, space separated
					'SELECT ''' + @TableName + '.' + @ColumnName + ''', LEFT(' + @ColumnName + ', 3630) 
					FROM ' + @TableName + ' (NOLOCK) ' +
					' WHERE ' + @ColumnName + ' LIKE ''[2,5][01234567890][01234567890][01234567890] [01234567890][01234567890][01234567890][01234567890] [01234567890][01234567890][01234567890][01234567890] [01234567890][01234567890][01234567890][01234567890]'''
				)
				INSERT INTO #Results
				EXEC
				(
					--MasterCard, no seperators
					'SELECT ''' + @TableName + '.' + @ColumnName + ''', LEFT(' + @ColumnName + ', 3630) 
					FROM ' + @TableName + ' (NOLOCK) ' +
					' WHERE ' + @ColumnName + ' LIKE ''[2,5][01234567890][01234567890][01234567890][01234567890][01234567890][01234567890][01234567890][01234567890][01234567890][01234567890][01234567890][01234567890][01234567890][01234567890][01234567890]'''
				)
				INSERT INTO #Results
				EXEC
				(
					--Discover, dash separated
					'SELECT ''' + @TableName + '.' + @ColumnName + ''', LEFT(' + @ColumnName + ', 3630) 
					FROM ' + @TableName + ' (NOLOCK) ' +
					' WHERE ' + @ColumnName + ' LIKE ''6[01234567890][01234567890][01234567890]-[01234567890][01234567890][01234567890][01234567890]-[01234567890][01234567890][01234567890][01234567890]-[01234567890][01234567890][01234567890][01234567890]%'''
				)
				INSERT INTO #Results
				EXEC
				(
					--Discover, no seperators
					'SELECT ''' + @TableName + '.' + @ColumnName + ''', LEFT(' + @ColumnName + ', 3630) 
					FROM ' + @TableName + ' (NOLOCK) ' +
					' WHERE ' + @ColumnName + ' LIKE ''6[01234567890][01234567890][01234567890][01234567890][01234567890][01234567890][01234567890][01234567890][01234567890][01234567890][01234567890][01234567890][01234567890][01234567890][01234567890]%'''
				)
				INSERT INTO #Results
				EXEC
				(
					--Discover, space separated
					'SELECT ''' + @TableName + '.' + @ColumnName + ''', LEFT(' + @ColumnName + ', 3630) 
					FROM ' + @TableName + ' (NOLOCK) ' +
					' WHERE ' + @ColumnName + ' LIKE ''6[01234567890][01234567890][01234567890] [01234567890][01234567890][01234567890][01234567890] [01234567890][01234567890][01234567890][01234567890] [01234567890][01234567890][01234567890][01234567890]%'''
				)
				INSERT INTO #Results
				EXEC
				(
					--American Express, space separated
					'SELECT ''' + @TableName + '.' + @ColumnName + ''', LEFT(' + @ColumnName + ', 3630) 
					FROM ' + @TableName + ' (NOLOCK) ' +
					' WHERE ' + @ColumnName + ' LIKE ''3[01234567890][01234567890][01234567890] [01234567890][01234567890][01234567890][01234567890][01234567890][01234567890] [01234567890][01234567890][01234567890][01234567890][01234567890]'''
				)
				INSERT INTO #Results
				EXEC
				(
					--American Express, dash separated
					'SELECT ''' + @TableName + '.' + @ColumnName + ''', LEFT(' + @ColumnName + ', 3630) 
					FROM ' + @TableName + ' (NOLOCK) ' +
					' WHERE ' + @ColumnName + ' LIKE ''3[01234567890][01234567890][01234567890]-[01234567890][01234567890][01234567890][01234567890][01234567890][01234567890]-[01234567890][01234567890][01234567890][01234567890][01234567890]'''
				)
				INSERT INTO #Results
				EXEC
				(
					--American Express, no seperators
					'SELECT ''' + @TableName + '.' + @ColumnName + ''', LEFT(' + @ColumnName + ', 3630) 
					FROM ' + @TableName + ' (NOLOCK) ' +
					' WHERE ' + @ColumnName + ' LIKE ''3[01234567890][01234567890][01234567890][01234567890][01234567890][01234567890][01234567890][01234567890][01234567890][01234567890][01234567890][01234567890][01234567890][01234567890]'''
				)

			END
		END	
	END

	SELECT ColumnName, ColumnValue FROM #Results
	--DROP TABLE #Results
--END

