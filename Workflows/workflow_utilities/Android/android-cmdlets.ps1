#=======================================================================================
# Author: Justin Sider
# Purpose: Support routines for various Automated tasks
#=======================================================================================
# This will remove the need to keep clicking R
set-ExecutionPolicy Bypass

#=======================================================================================
function Pause($Sleep=10) {
	start-sleep -s $Sleep
}

#=======================================================================================
function UnixTime($tDate=$Null) {
	
	if (! $tDate) {$tDate = Get-Date}
	return [double] (Get-Date($tDate) -UFormat %s)
}

#=======================================================================================
function Unix2Date($UnixTime=0) {
	return ([datetime]'1/1/1970').AddSeconds($UnixTime)
}

#=======================================================================================
function GetTimestamp{
	return $(get-date).ToString("yyyy-MM-dd HH:mm:ss")
}

#=======================================================================================
function deviceLog($Msg, [switch] $Quiet=$False, [switch] $Q=$False) {

	if($Q) {$Quiet = $Q}
	
	$dateNow = GetTimestamp
	if (! $Quiet) {
		Write-Host ""
		Write-Host "${dateNow} $Msg"
	}
	Write-Output "$dateNow $Msg" | Out-File $deviceLogFile -append -encoding ASCII
}
