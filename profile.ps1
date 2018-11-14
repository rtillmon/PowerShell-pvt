#Requires -RunAsAdministrator
# PowerShell Default Profile
# Roger Tillmon
# roger.tillmon@ineight.com
# InEight
#
#

# Set Appropriate Execution Policy
    Set-ExecutionPolicy BYPASS -Force

# Import Some Module Thingies
    $content = Get-Content $env:USERPROFILE'\My Documents\WindowsPowerShell\mymodules.txt'
        foreach ($line in $content)
            {
            Write-Host "Importing Module $($line)..."
            Import-Module $line
            }

# Configure the Terminal

# Configure a Code-Signing Certificate

# Other Settings

# Welcome Deets in ISE
    if ($psISE)
    {
    Write-Host
    Write-Host "Welcome $($env:USERNAME)"
    Write-Host "Your ComputerName is:  $($env:COMPUTERNAME)"
    Write-Host "Your Logon Server is:  $($env:LOGONSERVER)"
    Write-Host "Your Domain is:  $($env:USERDNSDOMAIN)"
    Get-NetIPAddress|Format-Table
    Write-Host
    Write-Host "Now Entering BEAST MODE (╯°□°)╯︵ ┻━┻..."
    }
# Set-Location
    Set-Location $env:USERPROFILE'\My Documents\'