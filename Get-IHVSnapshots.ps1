
function Get-IHVSnapshots {

	[CmdletBinding()]
	param(
		[Parameter(Mandatory=$True)]
		[String]$HostName,
	
		[Parameter(Mandatory=$True)]
		[String]$VMName
	)
	
	begin {
		$results = @() 
	}
	process {
		$query = "Select * From Msvm_ComputerSystem Where ElementName='$VMName'" 
		$SourceVm = Get-WmiObject -computerName $HostName -Namespace root\virtualization -Query $query
		
		$query = "Associators Of {$SourceVm} Where AssocClass=Msvm_ElementSettingData ResultClass=Msvm_VirtualSystemSettingData" 
		$Snapshots = Get-WmiObject -computerName $HostName -Namespace root\virtualization -Query $query
	
		foreach ($Snapshot in $Snapshots) 
		{
			$SnapObj = New-Object -TypeName System.Object 
			$SnapObj | Add-Member -MemberType NoteProperty -Name Name -Value $Snapshot.ElementName 
			$SnapObj | Add-Member -MemberType NoteProperty -Name ID -Value $Snapshot.InstanceID 
			$SnapObj | Add-Member -MemberType NoteProperty -Name ParentName -Value ([WMI]$Snapshot.Parent).ElementName 
			$SnapObj | Add-Member -MemberType NoteProperty -Name CreationTime -Value ([System.Management.ManagementDateTimeconverter]::ToDateTime($Snapshot.CreationTime))
			$results += $SnapObj 
		} 
	}
	end {
		$results
	}
}

$HostName = $(Read-Host -prompt "Hyper-V Host Name")
$VMName = $(Read-Host -prompt "Virtual Machine Name")

Get-IHVSnapshots -HostName $HostName -VMName $VMName | 
	format-table Name, ID, ParentName, CreationTime -autosize
	