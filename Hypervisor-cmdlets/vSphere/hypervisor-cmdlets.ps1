#=======================================================================================
# Purpose: Support routines for various Automated VMware tasks
#=======================================================================================
# This will remove the need to keep clicking R
set-ExecutionPolicy Bypass

# Enables all of the needed cmdlets
writeLog("Root Execution directory is '${SCRIPTDIR}'")

#=======================================================================================
function enable-vsphere-cli-in-powershell {
	#Add-PSSnapin VMWare.VimAutomation.Core -ErrorAction SilentlyContinue
	#. "C:\Program Files (x86)\VMware\Infrastructure\vSphere PowerCLI\Scripts\Initialize-PowerCLIEnvironment.ps1"
	Get-Module -ListAvailable VMware.vimautomation.core | Import-Module
}

#=======================================================================================
function SetVCenter($Tvcenter=$Vcenter) {
	$Tvcenter = $vCenter
	return $Tvcenter
}

#=======================================================================================
function ConnectVcenter($Tvcenter=$vCenter, $User=$hyp_UN, $Pass=$hyp_PW) {
	
	#Connect to the Vcenter
	if (! $DEVICECONN){ enable-vsphere-cli-in-powershell }
	
	$Tvcenter = SetVCenter $Tvcenter
	
	$DEVICECONN = (Connect-VIServer $Tvcenter -user $User -Password $Pass -ErrorAction SilentlyContinue)

	return $DEVICECONN
}

#=======================================================================================
function WaitForPower($vmName, $maxWaitTimeInSecs=$MAXWAITSECS) {

	$Start = UnixTime
	$DelaySecs=5
	$VmPowerState = Get-VM $vmname
	$VmPowerState = $VmPowerState.PowerState
	while ($VmPowerState -eq "PoweredOff") {
		if((UnixTime) -gt $Start + $maxWaitTimeInSecs) {return $false}
		Pause($DelaySecs)
	}
	return $true
}

#=======================================================================================
function WaitForTools($vmName, $maxWaitTimeInSecs=$MAXWAITSECS) {

	$Start = UnixTime
	$DelaySecs = 15
	while (! ($tVmName = Wait-Tools -VM $vmName -TimeoutSeconds $maxWaitTimeInSecs -ErrorAction SilentlyContinue)) {
		if((UnixTime) -gt $Start + $maxWaitTimeInSecs) {return $false}
		Pause($DelaySecs)
	}
	return $true
}

#=======================================================================================
function StopVm($vmName, $maxWaitTimeInSecs=$MAXWAITSECS, [switch] $Kill=$false) {

	$Start = UnixTime
	$DelaySecs = 30
	$bKill = [boolean] $Kill
	$VmPowerState = Get-VM $vmname
	$VmPowerState = $VmPowerState.PowerState
	while ($VmPowerState -eq "PoweredOn") {
		$tJob = Stop-VM -VM $vmName -Confirm:$false -RunAsync -Kill:$bKill -ErrorAction SilentlyContinue
		if((UnixTime) -gt $Start + $maxWaitTimeInSecs) {return $false}
		Pause($DelaySecs)
		$VmPowerState = Get-VM $vmname
		$VmPowerState = $VmPowerState.PowerState
	}
	return $true
}

#=======================================================================================
function Reboot-Vm($vmName, $maxWaitTimeInSecs=$MAXWAITSECS, [switch] $Kill=$false) {

	$Start = UnixTime
	$DelaySecs = 30
	$bKill = [boolean] $Kill
	$tJob = Restart-Vm -VM $vmName -Confirm:$false -RunAsync -Kill:$bKill -ErrorAction SilentlyContinue
	if((UnixTime) -gt $Start + $maxWaitTimeInSecs) {return $false}
	Pause($DelaySecs)
	return $true
}

#=======================================================================================
function ShutdownVm($vmName, $maxWaitTimeInSecs=$MAXWAITSECS) {

	$Start = UnixTime
	$DelaySecs = 20
	$VmPowerState = Get-VM $vmname
	$VmPowerState = $VmPowerState.PowerState
	while ($VmPowerState -eq "PoweredOn") {
		$tVmName = Shutdown-VMGuest -vm $vmName -Confirm:$false -ErrorAction SilentlyContinue
		if((UnixTime) -gt $Start + $maxWaitTimeInSecs) {return $false}
		Pause($DelaySecs)
		$VmPowerState = Get-VM $vmname
		$VmPowerState = $VmPowerState.PowerState
	}
	return $true
}

#=======================================================================================
function RestartVm($vmName, $maxWaitTimeInSecs=$MAXWAITSECS) {

	$Start = UnixTime
	$DelaySecs = 15
	$tVmName = Restart-VMGuest -vm $vmName -Confirm:$false -ErrorAction SilentlyContinue
	if((UnixTime) -gt $Start + $maxWaitTimeInSecs) {return $false}
	Pause($DelaySecs)
	return $True
}

#=======================================================================================
function SetHardDisk($State, $vmName, $maxWaitTimeInSecs=$MAXWAITSECS) {
	
	$Hd = (Get-HardDisk -VM $vmName | Set-HardDisk -Persistence $State -Confirm:$false -ToolsWaitSecs $maxWaitTimeInSecs)
	return ($Hd.Persistence -eq $State)
}

#=======================================================================================
function RemoveVm($vmName, $maxWaitTimeInSecs=$MAXWAITSECS) {
	
	Remove-VM -vm $vmName -Confirm:$false -ErrorAction SilentlyContinue
	Pause(5)
	return $True
}

#=======================================================================================
function DeRegisterVm($vmName, $maxWaitTimeInSecs=$MAXWAITSECS) {
	
	if (! (ShutdownVm $vmName $maxWaitTimeInSecs)) {
		if (! (StopVm $vmName $maxWaitTimeInSecs)) {
			return $False
		}
	}
	
	# Set Hard drive back to Persistent
	if (! (SetHardDisk "Persistent" $vmName $maxWaitTimeInSecs)) {
		return $False
	}
	
	# Un-Register Vm
	RemoveVm $vmName $maxWaitTimeInSecs
	
	return $True
}

#=======================================================================================
function CloneVM($vmName, $vmClone) {
	writeLog("The Template vm being used is ${vmName}, and the clone/SUT vm is ${vmClone}")
	New-VM -Name $vmClone -VM $vmName -Datastore $DATASTORE -VMHost $ESXhost
	return $True
}

#=======================================================================================
function StartVM($vmName) {
	#Start the VM
	Start-VM -VM $vmName -Server $VCcenterCONN -RunAsync
	return $True
}

#=======================================================================================
function GetConsoleUrl($vmName, $hypVersion, $maxWaitTimeInSecs=$MAXWAITSECS) {
	if ($hypVersion -eq 6){
		$ConsolePort = 9443 
		$myVM = Get-VM $vmName
		$VMMoRef = $myVM.ExtensionData.MoRef.Value
		
		#Get Vcenter from advanced settings
		$UUID = ((Connect-VIServer $Vcenter -user $hyp_UN -Password $hyp_PW -ErrorAction SilentlyContinue).InstanceUUID)
		$SettingsMgr = Get-View $global:DefaultVIServer.ExtensionData.Client.ServiceContent.Setting
		$Settings = $SettingsMgr.Setting.GetEnumerator() 
		$AdvancedSettingsFQDN = ($Settings | Where {$_.Key -eq "VirtualCenter.FQDN" }).Value
		
		#Get vCenter ticket
		$SessionMgr = Get-View $global:DefaultVIServer.ExtensionData.Client.ServiceContent.SessionManager
		$Session = $SessionMgr.AcquireCloneTicket()
		
		#Create URL and place it in the Database
		$ConsoleLink = "https://$($Vcenter):$($ConsolePort)/vsphere-client/webconsole.html?vmId=$($VMMoRef)&vmName=$($myVM.Name)&serverGuid=${UUID}&host=$($AdvancedSettingsFQDN)&sessionTicket=$($Session)&thumbprint=5A:AB:D4:75:29:E8:D5:94:09:8F:D2:91:CF:DC:AB:C0:69:03:37:42"	
		$query = "update suts set remote_Console_URL='$ConsoleLink',Console_Active='1' where Name = '$SUTname'"
		RunSQLCommand $query
		return $True
	}
	Else {
		#Create URL and place it in the Database
		$myVM = Get-VM $vmName
		$UUID = ((Connect-VIServer $Vcenter -user $hyp_UN -Password $hyp_PW -ErrorAction SilentlyContinue).InstanceUUID).ToUpper()
		$MoRef = $myVM.ExtensionData.MoRef.Value
		$ConsoleLink = "https://${Vcenter}:9443/vsphere-client/vmrc/vmrc.jsp?vm=urn:vmomi:VirtualMachine:${MoRef}:${UUID}"
		$query = "update suts set remote_Console_URL='$ConsoleLink',Console_Active='1' where Name = '$SUTname'"
		RunSQLCommand $query
		return $True
	}
	return $True
}
	
#=======================================================================================
function CreateSnapshot($vmName, $maxWaitTimeInSecs=$MAXWAITSECS) {
	#set the Snapshot name
	$SnapshotName = "PostProvision"
	
	#Take a snapshot of the VM
	New-Snapshot -vm $vmName -Name $SnapshotName -Memory:$True	
	return $True
}

#=======================================================================================
function RevertSnapshot($vmName, $maxWaitTimeInSecs=$MAXWAITSECS) {
	# Revert the Snapshot
	$SnapshotName = "PostProvision"
	Set-VM -vm $vmName -snapshot $SnapshotName -confirm:$false
	return $True
}

#=======================================================================================
function DeleteVm($vmName) {
	# Permanently delete the Vm
	Remove-VM $vmName -DeletePermanently -Confirm:$False
	Pause(5)
	return $True
}

#=======================================================================================
function DisconnetVC($DEVICECONN, $maxWaitTimeInSecs=$MAXWAITSECS) {
	# Disconnect from Vcenter or esx host
	Disconnect-VIServer -Server $DEVICECONN -Confirm:$false -Force
	$DEVICECONN = $Null
	return $True
}

#=======================================================================================
function GetIPAddress($vmName) {
	$vmIPdata = (Get-View -Viewtype VirtualMachine -Property Name, Guest.Net | where-object {$_.Name -eq "$vmName"} | Select @{n="IPAddr"; e={($_.Guest.Net | %{$_.IpAddress} ) }})
	$VMIP = $vmIPdata.IPAddr
	writeLog("Adding IP: $VMIP to DB for SUT $vmName")
	$query = "update suts set IP_Address='$VMIP' where Name = '$vmName'"
	RunSQLCommand $query
	return $True
}

#=======================================================================================
function CopyFilestoSUT {
	writeLog("Copying files to $vmName")
	if ($OS_Type -eq "Windows") {
		Copy-VMGuestFile -Source "c:\share\SutResults\${testName}\${SUTname}\properties.txt" -Destination "c:\LocalDropbox" -LocalToGuest -vm $vmName -GuestUser $VMUN -GuestPassword $VMPW
		Copy-VMGuestFile -Source "C:\OPEN_PROJECTS\SummitRTS\Workflows\workflow_utilities\Windows\provisionVM.bat" -Destination "c:\LocalDropbox" -LocalToGuest -vm $vmName -GuestUser $VMUN -GuestPassword $VMPW
		Copy-VMGuestFile -Source "C:\OPEN_PROJECTS\SummitRTS\Workflows\workflow_utilities\Windows\execute_testcase.bat" -Destination "c:\LocalDropbox" -LocalToGuest -vm $vmName -GuestUser $VMUN -GuestPassword $VMPW
		Copy-VMGuestFile -Source "C:\OPEN_PROJECTS\SummitRTS\Workflows\workflow_utilities\Windows\connectShare.bat" -Destination "c:\LocalDropbox" -LocalToGuest -vm $vmName -GuestUser $VMUN -GuestPassword $VMPW
		Copy-VMGuestFile -Source "C:\OPEN_PROJECTS\SummitRTS\Workflows\workflow_utilities\Windows\copyScripts.bat" -Destination "c:\LocalDropbox" -LocalToGuest -vm $vmName -GuestUser $VMUN -GuestPassword $VMPW
		return $true
	} Elseif ($OS_Type -eq "Linux") {
		Copy-VMGuestFile -Source "c:\share\SutResults\${testName}\${SUTname}\properties.txt" -Destination "/LocalDropbox/properties.txt" -LocalToGuest -vm $vmname -GuestUser $VMUN -GuestPassword $VMPW
		Copy-VMGuestFile -Source "C:\OPEN_PROJECTS\SummitRTS\Workflows\workflow_utilities\Linux\provisionVM.sh" -Destination "/LocalDropbox/provisionVM.sh" -LocalToGuest -vm $vmname -GuestUser $VMUN -GuestPassword $VMPW
		Copy-VMGuestFile -Source "C:\OPEN_PROJECTS\SummitRTS\Workflows\workflow_utilities\Linux\execute_testcase.sh" -Destination "/LocalDropbox/execute_testcase.sh" -LocalToGuest -vm $vmname -GuestUser $VMUN -GuestPassword $VMPW
		Copy-VMGuestFile -Source "C:\OPEN_PROJECTS\SummitRTS\Workflows\workflow_utilities\Linux\connectShare.sh" -Destination "/LocalDropbox/connectShare.sh" -LocalToGuest -vm $vmname -GuestUser $VMUN -GuestPassword $VMPW
		Copy-VMGuestFile -Source "C:\OPEN_PROJECTS\SummitRTS\Workflows\workflow_utilities\Linux\copyScripts.sh" -Destination "/LocalDropbox/copyScripts.sh" -LocalToGuest -vm $vmname -GuestUser $VMUN -GuestPassword $VMPW
		return $true
	} Elseif ($OS_Type -eq "Android") {
		# No files to copy for ADB, command run on the agent via ADB
		writeLog("No files were copied for Android")
		return $true
	} Else {
		#No OP
		WriteLog("No OS_Type-($OS_Type) was found to copy the files")
		return $false
	}	
}

#=======================================================================================
function ExecuteSUTScript {
	if ($OS_Type -eq "Windows") {
		writeLog("Running Windows Script: $Script_Path")
		$Echo = Invoke-VMScript -ScriptText "c:\LocalDropbox\execute_testcase.bat $testName $vmName $testcase_name $Script_Path" -VM $vmName -GuestUser $VMUN -GuestPassword $VMPW -ScriptType Bat -ErrorAction SilentlyContinue
		if ($Echo.ExitCode -ne 0) {
			writeLog("${vmName} Invoke-VMScript Failed. $Script_Path failed to run. ")
			$AgentStatus = $False
			return $AgentStatus
			Break
		}
	} ElseIf ($OS_Type -eq "Linux") {
		#Perform the Linux equivalent
		$Echo = Invoke-VMScript -ScriptText "/bin/bash /LocalDropbox/execute_testcase.sh $testName $vmname $testcase_name $Script_Path" -VM $vmname -GuestUser $VMUN -GuestPassword $VMPW -ErrorAction SilentlyContinue
		if ($Echo.ExitCode -ne 0) {
			# pause 15 seconds try again.
			writeLog("Failed to execute the script, waiting 30 seconds and trying again.")
			pause 30
			$Echo = Invoke-VMScript -ScriptText "/bin/bash /LocalDropbox/execute_testcase.sh $testName $vmname $testcase_name $Script_Path" -VM $vmname -GuestUser $VMUN -GuestPassword $VMPW -ErrorAction SilentlyContinue
			if ($Echo.ExitCode -ne 0) {
				writeLog("${vmName} Invoke-VMScript Failed. $Script_Path failed to run.")
				$AgentStatus = $False
				return $AgentStatus
				Break
			}
		}
	} Elseif ($OS_Type -eq "Android") {
		#Start the ADB Provision script
		if (! (. "C:\OPEN_PROJECTS\SummitRTS\Workflows\workflow_utilities\Android\$Script_Path" $testname $vmName $SUTname)) {
			writeLog("The provision1 script: $Script_Path failed to run")
			$AgentStatus = $False
			return $AgentStatus
			break
		}
	} Else {
		WriteLog("No OS_Type-($OS_Type) was found to execute the script")
		$AgentStatus = $False
		return $AgentStatus
	}
	writeLog("The script is complete!")
	return $true
}

#=======================================================================================
function ExecuteSUTProvisionScript {
	if ($OS_Type -eq "Windows") {
		writeLog("Running Windows Script: $Script_Path")
		$Echo = Invoke-VMScript -ScriptText "c:\LocalDropbox\$Script_Path $testName $vmName" -VM $vmName -GuestUser $VMUN -GuestPassword $VMPW -ScriptType Bat -ErrorAction SilentlyContinue
		if ($Echo.ExitCode -ne 0) {
			writeLog("${vmName} Invoke-VMScript Failed. $Script_Path failed to run. ")
			$AgentStatus = $False
			return $AgentStatus
			Break
		}
	} ElseIf ($OS_Type -eq "Linux") {
		#Perform the Linux equivalent
		$Echo = Invoke-VMScript -ScriptText "/bin/bash /LocalDropbox/$Script_Path $testName $vmname" -VM $vmname -GuestUser $VMUN -GuestPassword $VMPW -ErrorAction SilentlyContinue
		if ($Echo.ExitCode -ne 0) {
			writeLog("${vmName} Invoke-VMScript Failed. $Script_Path failed to run. ")
			$AgentStatus = $False
			return $AgentStatus
			Break
		}
	} Elseif ($OS_Type -eq "Android") {
		#Start the ADB Provision script
		if (! (. "C:\OPEN_PROJECTS\SummitRTS\Workflows\workflow_utilities\Android\$Script_Path" $testname $vmName $SUTname)) {
			writeLog("The provision1 script: $Script_Path failed to run")
			$AgentStatus = $False
			return $AgentStatus
			break
		}
	} Else {
		WriteLog("No OS_Type-($OS_Type) was found to execute the script")
		$AgentStatus = $False
		return $AgentStatus
	}
	writeLog("The script is complete!")
	return $true
}