#=======================================================================================
# Author: Justin Sider
# Purpose: Cmdlets for Powershell to run Device agent
#=======================================================================================

#=======================================================================================
# System Variables
#=======================================================================================
# This will remove the need to keep clicking R
set-ExecutionPolicy Bypass

#=======================================================================================
# Script Arguments
#=======================================================================================
# REQ - testName
# REQ - SUTName
$testName=$args[0]
$SUTname=$args[1]
$LogFile=$args[2]
$SharedDrive=$args[3]

#=======================================================================================
# Function to write properties.txt to correct path
#=======================================================================================
# First, lets create the properties file
$propertiesFile = "$SharedDrive\SutResults\$testName\$SUTname\properties.txt"
write-host $propertiesFile
New-Item $propertiesFile -type file

# Query the Database to get the properties Information
writeLog("Querying the Database for Properties Information")
$query = "select * from rts_properties"
$PropertiesData = @(RunSQLCommand $query)
# Use the array to get the data

foreach($row in $PropertiesData) {
	# Get the values for each row
	$property_name = $row.Name
	$property_value = $row.Val
	# Write each property to the properties file
	writeLog("Writing the Properties Information text file -($property_name :: $property_value)")
	Add-Content $propertiesFile "$property_name :: $property_value"
}

#=======================================================================================
# Future Function to write Software to properties.txt
# After review, this will be taken care of during provisioning
#=======================================================================================
# Hard-coding items for now
writeLog("Adding hardcoded software information")
$WIN_SW_COUNT = "1"
$WIN_SW_NAME_1 = "chrome"
$WIN_SW_VER_1 = "27.0.1"

Add-Content $propertiesFile "WIN_SW_COUNT :: $WIN_SW_COUNT"
Add-Content $propertiesFile "WIN_SW_NAME_1 :: $WIN_SW_NAME_1"
Add-Content $propertiesFile "WIN_SW_VER_1 :: $WIN_SW_VER_1"

# Hard-coding items for now
writeLog("Adding hardcoded software information")
$LINUX_SW_COUNT = "2"
$LINUX_SW_NAME_1 = "apache"
$LINUX_SW_VER_1 = "latest"
$LINUX_SW_NAME_2 = "firefox"
$LINUX_SW_VER_2 = "27.0.1"
Add-Content $propertiesFile "LINUX_SW_COUNT :: $LINUX_SW_COUNT"
Add-Content $propertiesFile "LINUX_SW_NAME_1 :: $LINUX_SW_NAME_1"
Add-Content $propertiesFile "LINUX_SW_VER_1 :: $LINUX_SW_VER_1"
Add-Content $propertiesFile "LINUX_SW_NAME_2 :: $LINUX_SW_NAME_2"
Add-Content $propertiesFile "LINUX_SW_VER_2 :: $LINUX_SW_VER_2"

