Param($ComputerName = "hostname") # Replace hostname with a valid system hostname (it will be ignored in the job)
invoke-command -ComputerName $ComputerName -ScriptBlock { & "C:\Program Files\McAfee\Agent\CmdAgent.exe" -p } # Edit path as required
