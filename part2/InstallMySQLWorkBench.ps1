
#New-item -Name "Downloads" -Path "C:\" -ItemType directory -Force

# 1. Download and Install the Latest Microsoft Visual C++ Redistributable
$vc_redist = "https://aka.ms/vs/17/release/vc_redist.x64.exe"
$vc_redistInstaller = "C:\Downloads\vc_redist.x64.exe"
#Invoke-WebRequest -Uri $vc_redist -OutFile $vc_redistInstaller -TimeoutSec 30

Start-Process -FilePath $vc_redistInstaller  -ArgumentList "/quiet", "/norestart" -Wait



# 2. Download and Install the latest mysql-workbench
$mysqlwb = "https://cdn.mysql.com//Downloads/MySQLGUITools/mysql-workbench-community-8.0.38-winx64.msi"
$mysqlwbInstaller = "C:\Downloads\mysql-workbench-community-8.0.38-winx64.msi"
#Invoke-WebRequest -Uri $mysqlwb -OutFile $mysqlwbInstaller -TimeoutSec 30

Start-Process -FilePath "msiexec.exe" -ArgumentList "/i", $mysqlwbInstaller, "/quiet", "/norestart" -Wait

