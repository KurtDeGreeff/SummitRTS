#=======================================================================================
#  ____                            _ _   ____ _____ ____  
# / ___| _   _ _ __ ___  _ __ ___ (_) |_|  _ \_   _/ ___| 
# \___ \| | | | '_ ` _ \| '_ ` _ \| | __| |_) || | \___ \ 
#  ___) | |_| | | | | | | | | | | | | |_|  _ < | |  ___) |
# |____/ \__,_|_| |_| |_|_| |_| |_|_|\__|_| \_\|_| |____/ 
#=======================================================================================

function RunSQLCommand(){
	<#	
	.SYNOPSIS
		Performs MySQL Query
	.DESCRIPTION
		Performs MySQL Query
	.EXAMPLE
		$query = "select * from test_suites where name = '$testname'"
			$TestNameData = @(RunSQLCommand $query)
	.EXAMPLE
		$query = "INSERT INTO test_suites (name, status_id) VALUES ('$testname',3)"
			RunSQLCommand $query
	.NOTES
		requires Connection information imported.
	#>
	param(
		[Parameter (Mandatory = $True)]
		$Query
	)
	# Might need to figure this out.
	. "C:\OPEN_PROJECTS\SummitRTS\utilities\connection_details.ps1"
	# Create the connection string
	$ConnectionString = "server=" + $MySQLHost + ";port=3306;uid=" + $MySQLAdminUserName + ";pwd=" + $MySQLAdminPassword + ";database="+$MySQLDatabase
	# Load MySQL .NET Connector Objects
	[void][System.Reflection.Assembly]::LoadWithPartialName("MySql.Data")
	$Connection = New-Object MySql.Data.MySqlClient.MySqlConnection
	$Connection.ConnectionString = $ConnectionString
	# Open Connection
	$Connection.Open()
	
	# Create command object
	$Command = New-Object MySql.Data.MySqlClient.MySqlCommand($Query, $Connection)
	$DataAdapter = New-Object MySql.Data.MySqlClient.MySqlDataAdapter($Command)
	$DataSet = New-Object System.Data.DataSet
	$RecordCount = $dataAdapter.Fill($dataSet, "data")
	# Close the Connection
	$Connection.Close()
	# Return the data
	return $DataSet.Tables[0]
	}
#=======================================================================================
#    _  _  _____                    ____       _             
#  _| || ||_   _|__  __ _ _ __ ___ | __ )  ___| | __ _ _   _ 
# |_  ..  _|| |/ _ \/ _` | '_ ` _ \|  _ \ / _ \ |/ _` | | | |
# |_      _|| |  __/ (_| | | | | | | |_) |  __/ | (_| | |_| |
#   |_||_|  |_|\___|\__,_|_| |_| |_|____/ \___|_|\__,_|\__, |
#                                                      |___/ 
#=======================================================================================