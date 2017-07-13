#!powershell 
# WANT_JSON
# POWERSHELL_COMMON

Set-StrictMode -Version 2.0

$Logfile = "D:\ansible.log"

Function Write-Log {
    [CmdletBinding()]
    Param(
		[Parameter(Mandatory=$False)]
		[ValidateSet("INFO","WARN","ERROR","FATAL","DEBUG")]
		[String]
		$Level = "INFO",

		[Parameter(Mandatory=$True)]
		[string]
		$Message,

		[Parameter(Mandatory=$False)]
		[string]
		$logfile
    )

    $Stamp = (Get-Date).toString("yyyy/MM/dd HH:mm:ss")
    $Line = "$Stamp $Level $Message"
    If($logfile) {
        Add-Content $logfile -Value $Line
    }
    Else {
        Write-Output $Line
    }
}

$params = Parse-Args $args -supports_check_mode $true

$check_mode = Get-AnsibleParam -obj $params -name "_ansible_check_mode" -type "bool" -default $false
$src = Get-AnsibleParam -obj $params -name "src" -type "path" -default "D:\Openlink\Endur"
$svc = Get-AnsibleParam -obj $params -name "svc" -type "str" -default "ALL"
$state = Get-AnsibleParam -obj $params -name "state" -type "str" -default "ALL"

$current_host = $env:COMPUTERNAME
$dt = $a = Get-Date

if (!($psversiontable.psversion.major -ge 4)) {
	Fail-Json $result "Local powershell version is not at the required version [found version $($Psversiontable.psversion.tostring())]"
}

if (-not (Test-Path -Path $src)) {
    Fail-Json $result "Cannot find or read src directory: $src directory does not exist or cannot be read"
}

$lines = Select-String "$src\svc_olf_*.cfg" -pattern "SET AB_ENDUR_VERSION=" | Select-Object Filename,Line

if ($lines -is [system.array]){
	$result = New-Object psobject @{
		changed = $false
		services = @()
	}

	Foreach ($line in $lines) {
		$line.Filename -match "^svc_olf_app[0-9]{2}.(?<service>.+).cfg" > null
		$svc_name = $matches['service'].ToString()
		$svc_version = $line.Line.TrimStart('SET AB_ENDUR_VERSION=')
		$svc_object = Get-Service -Name "Openlink_Endur_$svc_name" -ErrorAction SilentlyContinue
				
		if (($svc -eq 'ALL') -or ($svc_name -eq $svc) -and ($svc_object)) {
			$wmi_svc = Get-WmiObject Win32_Service | Where-Object { $_.Name -eq $svc_object.Name }
			$svc_mode = $wmi_svc.StartMode.ToString()
			$svc_status = $svc_object.Status.ToString()
			
			$svc_exe_path,$extra,$nt_svc = $wmi_svc.Pathname.ToString().split(' ')
			#"D:\\Openlink\\Endur\\V14_0_08082015ENB_12212015_1081\\bin.win64\\master.exe"
			$svc_exe_parts = $svc_exe_path.Split([system.io.path]::DirectorySeparatorChar)
			$svc_exe = $svc_exe_parts[3].Substring($svc_exe_parts[3].Length - 4)
			
			if (($state -eq 'ALL') -or ($svc_status -eq $state)) {
				$service = @{}
				$service.Add('host', $current_host)
				
				if ($current_host.Substring(0,2) -eq "VP") {
					$service.Add('dc', 'TORONTO')
				} elseif ($current_host.Substring(0,2) -eq "EW") {
					$service.Add('dc', 'EDMONTON')
				} else {
					$service.Add('dc', 'UNKNOWN')
				}
				
				$service.Add('service', $svc_name.ToUpper())
				$service.Add('version', $svc_version.Substring($svc_version.get_Length() - 4))		
				$service.Add('mode', $svc_mode.ToUpper())
				$service.Add('svc_exe', $svc_exe)
				$service.Add('nt_svc', $nt_svc)
				
				if ($svc_status -eq 'running') {
					$service.Add('state', $true)
				} else {
					$service.Add('state', $false)
				}
				
				$service.Add('updated', $dt.ToShortDateString() + ' ' + $dt.ToShortTimeString())
				
				$result.services += $service
			}
		}
	}
	
	Exit-Json $result
} else {
	$result = New-Object psobject @{
		changed = $false
	}
	
	Fail-Json $result "No Openlink configurations found in the $src directory";
}
