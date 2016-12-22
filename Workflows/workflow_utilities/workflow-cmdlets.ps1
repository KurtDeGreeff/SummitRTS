#=======================================================================================
# Purpose: Support routines for various Automated tasks
#=======================================================================================
# This will remove the need to keep clicking R
set-ExecutionPolicy Bypass

#=======================================================================================
function AddSUTLogFilesToDB($Testcase_Id, $testName, $vmName, $testcase_name){
	$SUTLogPath = "c:\share\SutResults\${testName}\${vmName}\${testcase_name}"
	$SUTLogfiles = Get-ChildItem "$SUTLogPath"
	foreach ($SUTfile in $SUTLogfiles) {
		$SingleFilePath = $SUTfile.fullname
		$SingleFilePath = $SingleFilePath.Replace('\',"\\")
		writeLog("Adding $SingleFilePath to the DB")
		$query = "insert into test_case_log_files (test_cases_id, log_path, log_file_name) VALUES ($Testcase_Id,'$SingleFilePath','$SUTfile')"
		RunSQLCommand $query
	}
}
#=======================================================================================