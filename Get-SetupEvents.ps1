Function Get-SetupEvents
{
<#
.Synopsis
Gets Setup events from Setup log from the past 30 days (by default)

.DESCRIPTION
Gets Setup events from Setup log from the past 30 days (by default)

.NOTES   
Name: Get-SetupEvents
Author: Jacob Boykin

.PARAMETER ComputerName
The computer in which the setup events will be fetched from

.EXAMPLE
Get-SetupEvents client01

Description:
Will fetch setup events from the past 30 days on client01

.EXAMPLE
'client01' | Get-SetupEvents

Description:
Will fetch setup events from the past 30 days on client01 using the piped input

#>
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            Position=0)]
        [string] $ComputerName = $env:COMPUTERNAME,
        [int] $DaysAgo = 30
    )

    process
    {
        foreach ($computer in $ComputerName)
        {
            $current = Get-Date
            $startTime = $current.AddDays(-$DaysAgo)

            try
            {
                if (!(Test-Connection -Computername $computer -BufferSize 16 -Count 2 -Quiet))
                {
                    throw "computerOffline"
                }

                $ErrorActionPreference = "Stop"

                $events = Get-WinEvent -ComputerName $computer -FilterHashtable @{LogName='Setup';StartTime=$startTime}
            }
            catch
            {
                Switch -Wildcard ($Error[0].Exception)
                {
                    "*computerOffline*"
                    {
                        Write-Host -BackgroundColor Black -ForegroundColor Red "`n$computer appears to be offline!`n"      
                    }
                    Default
                    {
                        Write-Host -BackgroundColor Black -ForegroundColor Red "`nUnable to fetch events!`n"
                        Write-Host -BackgroundColor black -ForegroundColor Red $Error[0].Exception
                    }
                }
            }
        }
    }
    
    end
    {
        $events | Out-GridView
    }
}