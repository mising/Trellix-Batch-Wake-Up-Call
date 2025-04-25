# Multi thread Trellix Agent WakeUp
# Author - Michael Ising
# Version 1.1 Sept 2024

 Param($ScriptFile = $("C:\Scripts\WakeUp\WakeUpSingle.ps1"), # Edit to match your environment
    $ComputerList = $("C:\Scripts\WakeUp\wakeup.txt"), # Edit to match your environment
    $MaxThreads = 20,
    $SleepTimer = 500,
    $MaxWaitAtEnd = 600,
    $OutputType = "text")
    
$Computers = Get-Content $ComputerList


"Killing existing jobs . . ."
Get-Job | Remove-Job -Force
"Done."

$i = 0

ForEach ($Computer in $Computers){
    While ($(Get-Job -state running).count -ge $MaxThreads){
        Write-Progress  -Activity "Creating Computer List" -Status "Waiting for threads to close" -CurrentOperation "$i threads created - $($(Get-Job -state running).count) threads open" -PercentComplete ($i / $Computers.count * 100)
        Start-Sleep -Milliseconds $SleepTimer
    }

    #"Starting job - $Computer"
    $i++
    Start-Job -FilePath $ScriptFile -ArgumentList $Computer -Name $Computer | Out-Null
    Write-Progress  -Activity "Creating Computer List" -Status "Starting Threads" -CurrentOperation "$i threads created - $($(Get-Job -state running).count) threads open" -PercentComplete ($i / $Computers.count * 100)
    
}

$Complete = Get-date

While ($(Get-Job -State Running).count -gt 0){
    $ComputersStillRunning = ""
    ForEach ($System  in $(Get-Job -state running)){$ComputersStillRunning += ", $($System.name)"}
    $ComputersStillRunning = $ComputersStillRunning.Substring(2)
    Write-Progress  -Activity "Creating Computer List" -Status "$($(Get-Job -State Running).count) threads remaining" -CurrentOperation "$ComputersStillRunning" -PercentComplete ($(Get-Job -State Completed).count / $(Get-Job).count * 100)
    If ($(New-TimeSpan $Complete $(Get-Date)).totalseconds -ge $MaxWaitAtEnd){"Killing all jobs still running . . .";Get-Job -State Running | Remove-Job -Force}
    Start-Sleep -Milliseconds $SleepTimer
}

"Reading all jobs"

If ($OutputType -eq "Text"){
    ForEach($Job in Get-Job){
        "$($Job.Name)"
        "****************************************"
        Receive-Job $Job
        " "
    }
}
ElseIf($OutputType -eq "GridView"){
    Get-Job | Receive-Job | Select-Object * -ExcludeProperty RunspaceId | out-gridview
    
}
