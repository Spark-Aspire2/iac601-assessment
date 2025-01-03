#1.Add MDT snap-in to support PowerShell cmdlets.
Add-PSSnapin Microsoft.BDD.PSSnapIn
Import-Module "C:\Program Files\Microsoft Deployment Toolkit\bin\MicrosoftDeploymentToolkit.psd1"

$deploymentShare = "C:\DeploymentShare"
$mdtPath = "$deploymentShare\Control"
$networkPath = "\\IAC-SERVER\DeploymentShare"
$domainName = "iac.com"

#2.Create a new share folder for the deployment
New-Item $deploymentShare -Type directory -Force
New-SmbShare -Name DeploymentShare -Path $deploymentShare  -FullAccess Administrators


#3.Initilize the deployment folder as a persistent drive named "DS001"
#Import-Module "C:\Program Files\Microsoft Deployment Toolkit\bin\MicrosoftDeploymentToolkit.psd1"
#Remove-PSDrive -Name "DS001"
new-PSDrive -Name "DS001" -PSProvider "MDTProvider" -Root "C:\DeploymentShare" -Description "MDT Deployment Share" -NetworkPath $networkPath -Verbose | add-MDTPersistentDrive -Verbose

#4.Create Bootstrap.ini
$bootstrapContent = @"
[Settings]
Priority=Default

[Default]
DeployRoot=$networkPath

UserID=Administrator
UserPassword=Aspire2
UserDomain=$domainName
TaskSequenceID=1
SkipTaskSequence=YES
KeyboardLocale=en-US
SkipBDDWelcome=YES
"@

Set-Content -Path "$mdtPath\Bootstrap.ini" -Value $bootstrapContent

#5.Create CustomSettings.ini
$customSettingsContent = @"
[Settings]
Priority=Default
Properties=MyCustomProperty

[Default]
OSInstall=Y
SkipCapture=YES
SkipAdminPassword=YES
SkipProductKey=YES
SkipComputerBackup=YES
SkipBitLocker=YES

SkipBDDWelcome=YES
SkipUserData=YES
SkipTimeZone=YES
SkipLocaleSelection=YES
SkipComputerName=YES
SkipSummary=YES
SkipDomainMembership=YES
SkipApplications=YES

KeyboardLocale=en-US
TimeZoneName=New Zealand StandardTime
EventService=http://Deployment:9800
"@

Set-Content -Path "$mdtPath\CustomSettings.ini" -Value $customSettingsContent


#6. Import Applications into MDT
Restore-MDTPersistentDrive -Verbose
Get-PSDrive -PSProvider Microsoft.BDD.PSSnapIn\MDTProvider

Import-MDTApplication -Name "Google Chrome" -Path "DS001:\Applications" -ApplicationSourcePath "C:\ShareFolder\Chrome" -DestinationFolder Chrome -WorkingDirectory ".\Applications\Chrome"  -CommandLine "ChromeStandaloneSetup64.exe /silent /install" -ShortName Chrome
Import-MDTApplication -Name "VLC Media Player"  -Path "DS001:\Applications" -ApplicationSourcePath "C:\ShareFolder\VLC" -DestinationFolder VLC -WorkingDirectory ".\Applications\VLC" -CommandLine "vlc-3.0.17.4-win32.exe /L=1033 /S"  -ShortName VLC
Import-MDTApplication -Name "Adobe Acrobat Reader"  -Path "DS001:\Applications" -ApplicationSourcePath "C:\ShareFolder\AcroRdr" -DestinationFolder AcroRdr  -WorkingDirectory ".\Applications\AcroRdr" -CommandLine "AcroRdrDC2400220857_en_US.exe /sAll /rs /msi EULA_ACCEPT=YES"  -ShortName AcroRdr


#Check import result
#Get-ItemProperty -Path 'DS001:\Applications\Google Chrome'

#7.Import Operating System
#import-mdtoperatingsystem -path "DS001:\Operating Systems" -SourcePath "D:\" -DestinationFolder "Windows 11 Home x64" -Verbose
import-mdtoperatingsystem -path "DS001:\Operating Systems" -SourcePath "D:\" -DestinationFolder "Windows Server 2022 SERVERSTANDARDCORE x64" -Verbose



#8.Create Tasksequece
#import-mdttasksequence -path "DS001:\Task Sequences" -Name "OS and Apps" -Template "Client.xml" -Comments "" -ID "1" -Version "1.0" -OperatingSystemPath "DS001:\Operating Systems\Windows 11 Pro in Windows 11 Home x64 install.wim" -FullName "Windows User" -OrgName "Media Labs" -HomePage "about:blank" -Verbose
import-mdttasksequence -path "DS001:\Task Sequences" -Name "Windows Server 2022 Installation" -Template "Client.xml" -Comments "" -ID "2" -Version "1.0" -OperatingSystemPath "DS001:\Operating Systems\Windows Server 2022 SERVERSTANDARD in Windows Server 2022 SERVERSTANDARDCORE x64 install.wim" -FullName "Windows User" -OrgName "spark.com" -HomePage "about:blank" -AdminPassword "Aspire2" -Verbose


#9.Add the Applications:Goolge Chrome, VLC, and Acrobat Reader to the Tasksequence manully.
#---------------------------------------------------------------------------------------------------------
#Before to generate the boot image, the applications should be added into tasksequence manully.
#---------------------------------------------------------------------------------------------------------

#10.Generate the boot image
#Since Windows 11 will be installed on X64 machines and x86 image will not be generated.
Set-ItemProperty -Path "DS001:" -Name "SupportX86" -value $false -Force -Verbose

#Generate the boot image.
Update-MDTDeploymentShare -Path "DS001:" -Force -Verbose 


#11. Install and Configure Windows Deployment Services (WDS)
# Remove-WindowsFeature -Name WDS, WDS-Deployment  -IncludeManagementTools
Install-WindowsFeature -Name WDS  -IncludeManagementTools
Import-Module WDS

#12.Initialize WDS 
wdsutil /Verbose /Progress /Initialize-Server  /remInst:$deploymentShare

#13.Configure WDS settings
wdsutil /Set-Server /AnswerClients:All #  /BootProgram:boot\x64\wdsnbp.com /Architecture:x64
wdsutil /Set-Server /PxePromptPolicy /Known:NoPrompt /New:NoPrompt
#wdsutil /get-server /show:all
#wdsutil /set-Server /UseDhcpPorts:No

#14.Start Windows Deployment Service
wdsutil /verbose /start-Server

#15.Add MDT Boot Image to WDS
#Remove-WdsBootImage -ImageName "Lite Touch Windows PE (x64)" -Architecture X64
Import-WdsBootImage -Path "$deploymentShare\Boot\LiteTouchPE_x64.wim" -NewImageName "Lite Touch Windows PE (x64)"  -SkipVerify -Verbose #  -ImageType "Microsoft Boot Image"


#16. Solve the error of "a boot image was not found"
#A machine configured with UEFI(GEN 2) will use boot\x64\wdsmgfw.efi on the WDS server when starting the boot. A legacy boot(GEN 1) will use boot\x64\wdsnbp.com.
#wdsmgfw.efi cannot be generated with powershell command but will be generated through GUI.
$BootImagePath = "$deploymentShare\Boot\LiteTouchPE_x64.wim"
$WdsBootFolder = 
$MountPath = "C:\Mount" 
New-Item $MountPath -Type directory -Force

$EfiFile = Join-Path -Path $MountPath -ChildPath "Windows\Boot\PXE\wdsmgfw.efi"
$DestinationFile = "$deploymentShare\Boot\x64\wdsmgfw.efi"

# Mount the boot image to check for wdsmgfw.efi
try {
    if (-Not (Test-Path $DestinationFile)) {
    	Write-Output "Mounting the boot image..."
    	Mount-WindowsImage -ImagePath $BootImagePath -Index 1 -Path $MountPath

    	# Check if the wdsmgfw.efi file exists
    	if (Test-Path $EfiFile) {
        	Write-Output "EFI file found: $EfiFile"
        	# Copy the wdsmgfw.efi file to the WDS boot folder if it does not exist there
            	Copy-Item -Path $EfiFile -Destination $DestinationFile -Force
            	Write-Output "EFI file copied to WDS folder: $DestinationFile"
       	}
    	else {
        	Write-Error "EFI file not found in the boot image."
    	}
     }
     else {
            Write-Output "EFI file already exists in the WDS folder."
     }
}
catch {
    Write-Error "Error occurred during mounting or copying: $_"
}
finally {
    # Unmount the boot image
    Dismount-WindowsImage -Path $MountPath -Discard
    Write-Output "Boot image unmounted."
}




