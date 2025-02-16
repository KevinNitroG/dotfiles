<#	
    .NOTES
    ==========================================================================
    Created with: 	ISE
    Created on:   	3/27/2022 1:46 PM
    Created by:   	Vikas Sukhija
    Organization: 	
    Filename:     	ImportTasks.ps1

    ==========================================================================
    .DESCRIPTION
    This script can import tasks to the new server
#>
param (
  [string]$task_path = $(Read-Host "Enter Task Folder Path for XML"),
  [string]$task_Folder = $(Read-Host "Enter Task Scheduler Folder"),
  [string]$task_user = $(Read-Host "Enter userID to be used"),
  [string]$task_pass = $(Read-Host "Enter the Password for the user")
)

$gettasks = Get-ChildItem $task_path
foreach ($task in $gettasks){
[xml]$gettask = get-content $task.FullName
$gettaskxmlstring  = get-content $task.FullName | Out-String
$taskname = ($gettask.task.RegistrationInfo.URI).split("\")[-1]
Register-ScheduledTask -xml $gettaskxmlstring -TaskName $taskname -TaskPath "\$task_Folder\" -User $task_user -Password $task_pass
}
####################################################################