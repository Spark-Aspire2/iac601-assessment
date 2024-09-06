
New-item -Name "Downloads" -Path "C:\" -ItemType directory -Force

# 1. Download and Install the latest Microsoft Deployment Toolkit (MDT)
$MDTUrl = "https://download.microsoft.com/download/3/3/9/339BE62D-B4B8-4956-B58D-73C4685FC492/MicrosoftDeploymentToolkit_x64.msi"
$MDTInstaller = "C:\Downloads\MicrosoftDeploymentToolkit_x64.msi"
Invoke-WebRequest -Uri $MDTUrl -OutFile $MDTInstaller

Start-Process -FilePath "msiexec.exe" -ArgumentList "/i", $MDTInstaller, "/quiet", "/norestart" -Wait


# 2. Download and Install Windows ADK (Microsoft, 2022)
$ADKUrl = "https://go.microsoft.com/fwlink/?linkid=2196127"
$ADKInstaller = "C:\Downloads\adksetup.exe"
Invoke-WebRequest -Uri $ADKUrl -OutFile $ADKInstaller

Start-Process -FilePath $ADKInstaller  -ArgumentList "/quiet", "/norestart" -Wait


# 3. Download and Install Windows PE add-on for the Windows ADK (Microsoft, 2022)
$ADKWinPEUrl = "https://go.microsoft.com/fwlink/?linkid=2196224"
$ADKWinPEInstaller = "C:\Downloads\adkwinpesetup.exe"
Invoke-WebRequest -Uri $ADKWinPEUrl -OutFile $ADKWinPEInstaller

Start-Process -FilePath $ADKWinPEInstaller  -ArgumentList "/quiet", "/norestart" -Wait
