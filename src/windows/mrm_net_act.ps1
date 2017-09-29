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

$current_host = $env:COMPUTERNAME  + '.cnpl.enbridge.com'
$dt = $a = Get-Date

if (!($psversiontable.psversion.major -ge 4)) {
	Fail-Json $result "Local powershell version is not at the required version [found version $($Psversiontable.psversion.tostring())]"
}

$Total = Invoke-Command -ScriptBlock {netsh int ipv4 show dynamicport tcp}
$TcpCount = Invoke-Command -ScriptBlock {(netstat -an | ? {($_ -notmatch 'LISTENING') -and ($_ -match '^  TCP')}).Count}
$UdpCount = Invoke-Command -ScriptBlock {(netstat -an | ? {($_ -notmatch 'LISTENING') -and ($_ -match '^  UDP')}).Count}

$regex = new-object System.Text.RegularExpressions.Regex (‘(Number of Ports : )(\d*)’, [System.Text.RegularExpressions.RegexOptions]::MultiLine)
$Total = ($regex.Match($Total)).Groups[2].Value

$PortsAvail = $Total – ($TcpCount + $UdpCount)

if ($Total) {
    $result = New-Object psobject @{
        changed = $false
        services = @()
    }

    $service = @{}
    $service.Add('host', $current_host)
    $service.Add('tcp_count', $TcpCount)		
    $service.Add('udp_count', $UdpCount)
    $service.Add('avail_ports', $PortsAvail)
    $service.Add('msg', "TCP count is $TcpCount and UDP count is $UdpCount, Remaining Ports: $PortsAvail on server $current_host")
    $service.Add('updated', $dt.ToShortDateString() + ' ' + $dt.ToShortTimeString())
    
    $result.services += $service
    Exit-Json $result    
} else {
	$result = New-Object psobject @{
		changed = $false
	}
	
	Fail-Json $result "No Openlink configurations found in the $src directory";
}
