$actionsVer   = "2.319.1" #version of actions runner
$actionsRepo  = "REPLACEURLHERE" #URL of repo
$actionsToken = "REPLACETOKENHERE" #Token of repo
$jenkinsVer   = "2.462.2" #Version of Jenkins to download
$javaVer      = "17.0.11" #Version of Java

# Download Github Actions runner
Invoke-RestMethod "https://github.com/actions/runner/releases/download/v$actionsVer/actions-runner-win-x64-$actionsVer.zip" -OutFile "$env:TEMP\actions-runner.zip"

# Extract archive
Expand-Archive -Path "$env:TEMP\actions-runner.zip" -DestinationPath "$env:SYSTEMDRIVE\actions-runner"

# Install Github Runner
Start-Process "$env:SYSTEMDRIVE\actions-runner\config.cmd" -Wait -ArgumentList "--unattended","--url","$actionsRepo","--token","$actionsToken","--runasservice","--windowslogonaccount","NT AUTHORITY\NETWORK SERVICE","--windowslogonpassword"," "

# Download Java 17
$javaVerMajor=$javaVer.Split('.')[0]
Invoke-RestMethod "https://download.oracle.com/java/$javaVerMajor/archive/jdk-$javaVer_windows-x64_bin.exe" -OutFile "$env:TEMP\java.exe"

# Install Java 17
Start-Process "$env:TEMP\java.exe" -Wait -ArgumentList "/s"

# Download Jenkins
Invoke-RestMethod "https://get.jenkins.io/windows-stable/$jenkinsVer/jenkins.msi" -OutFile "$env:TEMP\jenkins.msi"

# Install Jenkins
Start-Process -Wait msiexec.exe -ArgumentList '/i','C:\temp\jenkins.msi','/quiet','/norestart','JAVA_HOME="C:\Program Files\Java\jdk-17"','SERVICE_USERNAME="NT AUTHORITY\SYSTEM"'