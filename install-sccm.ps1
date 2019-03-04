#Add-Type -Name win -MemberDefinition '[DllImport("user32.dll")] public static extern bool ShowWindow(int handle, int state);' -Namespace native
#[native.win]::ShowWindow(([System.Diagnostics.Process]::GetCurrentProcess() | Get-Process).MainWindowHandle,0)

#ConfigMgr Client Installer
#InEight - SiteCode: IN8
#Created:  01-25-2019
#Modified: 02-28-2019
#Author:  Roger Tillmon
#LastChange:  Changed Ping Method for detecting MP to use Test-Connection cmdlet.

$Error.Clear()

Try
{
    #Does The CCMEXEC Service Exist
        $sccmstatus = Get-Service -Name ccmexec -ErrorAction Stop
}

Catch [System.Exception]
{
    Write-Host "CCMEXEC SERVICE NOT FOUND... INSTALLING CONFIGMGR CLIENT..."

    #Set Variables
        $destination = "c:\sccminstall\"
        $sccmzip = "c:\sccminstall\cm_client.zip"        
        $installer = "c:\sccminstall\ccmsetup.exe"
        $mpcheck = Test-Connection -ComputerName "CL1SSCMMPS001.harddollar.local" -Count 1 -ErrorAction SilentlyContinue -ErrorVariable pingerr
        if ($pingerr.Count -eq 0) {
            $arguments = "/retry:2 /UsePkiCert /mp:CL1SSCMMPS001.harddollar.local SMSSITECODE=IN8 FSP=CL1SSCMMPS001"
            $sccmurl = "http://cl1sscmmps001.harddollar.local/cm_client.zip"
            $mp = "LOCAL MANAGEMENT POINT"
            }
        else {
            $arguments = "/UsePkiCert /NOCRLCheck SMSSITECODE=IN8 CCMHOSTNAME=CL1SCMCLMP001.CLOUDAPP.NET/CCM_Proxy_MutualAuth/72057594037937947"
            $sccmurl = "https://cl1scmclmp001.cloudapp.net/cm_client.zip"
            $mp = "AZURE CLOUD MANAGEMENT GATEWAY"}
        Write-Host "Local Computer will install from $mp"

    #Delete Old Versions of the Source Folder
        Write-Host "Deleting Old Copies of Source Folder..."
        Remove-Item $destination -Recurse -ErrorAction Ignore

    #Create the directory
        Write-Host "Creating Source Folder on Local Computer..."
        New-Item -ItemType directory -Path $destination

    #Download the file
        Write-Host "Downloading Source File..."
        (New-Object System.Net.WebClient).DownloadFile($sccmurl, $sccmzip)

    #extract the zip file
        Write-Host "Extracting Source Files..."
        (New-Object -COM Shell.Application).NameSpace($destination).CopyHere((New-Object -COM Shell.Application).NameSpace($sccmzip).Items(), 16);

    #remove zip file
        Write-Host "Delete Downloaded Zip File..."
        Remove-Item $sccmzip

    #Install ConfigMgr Client
        Write-Host "Installing ConfigMgr Client..."
        Set-Location $destination
        Start-Process .\ccmsetup.exe $arguments
        $nid = (Get-Process ccmsetup).Id
        Wait-Process -Id $nid

    #Activate Interlocks, Dynotherms Connected, Infracells Are Up, Megathrusters are a go!
        Write-Host "Sleep For 5 Minutes as Processes Launch for the First Time..."
        Start-Sleep -s 300

    #Copy CMTrace
        Write-Host "Copying CMTrace LogViewer to c:\windows\CCM..."
        Copy-Item c:\sccminstall\cmtrace.exe C:\Windows\CCM\cmtrace.exe
        Remove-Item -Recurse -Force $destination

    #Cleanup Source Directory
        Write-Host "Deleting Source Folder..."
        Set-Location C:\Windows\CCM\Logs
        Remove-Item $destination -Recurse -ErrorAction SilentlyContinue        

}

Finally
{
    Write-Host "CCMEXEC Service Status..."
    $sccmpoststatus = Get-Service -Name ccmexec -ErrorAction SilentlyContinue
    Write-Host ConfigMgr Client is $sccmpoststatus.Status
}
