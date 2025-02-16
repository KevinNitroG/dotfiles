<#	
    .NOTES
    ==========================================================================
    Created with: 	ISE
    Created on:   	3/27/2022 1:46 PM
    Created by:   	Vikas Sukhija
    Organization: 	
    Filename:     	ExportTasks.ps1

    ==========================================================================
    .DESCRIPTION
    This script will export the tasks XML daily and write it to GItlab
#>
#################Export Scheduled Tasks except Microsoft######################
Get-ScheduledTask | ForEach-Object{
$TaskPath = $taskName = $Null
$taskName = $_.TaskName
$TaskPath = $_.TaskPath 
if($TaskPath -eq "\"){$TaskFolderPath = "root"}else{$TaskFolderPath = $taskpath.replace("\","")}
if(($TaskFolderPath) -and ($TaskFolderPath -notlike "*Microsoft*")){
if($(Test-Path -Path $TaskFolderPath) -eq $false){
$null = New-Item -Path (Get-Location).path -Name $TaskFolderPath -Type directory
}
Export-ScheduledTask -TaskName $taskName -TaskPath $TaskPath | out-file -FilePath $($TaskFolderPath + "\" + $taskName + ".xml")
}
}
#############################################################################
