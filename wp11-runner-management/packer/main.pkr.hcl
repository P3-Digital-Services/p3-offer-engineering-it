packer {
  required_plugins {
    azure     = {
      source  = "github.com/hashicorp/azure"
      version = "~> 2"
    }
  }
}

source "azure-arm" "cariad_runner_vm" {
  build_resource_group_name         = var.buildResourceGroupName
  use_azure_cli_auth                = true
  communicator                      = "winrm"
  image_offer                       = "WindowsServer"
  image_publisher                   = "MicrosoftWindowsServer"
  image_sku                         = var.imageSku
  managed_image_name                = var.managedImageName
  managed_image_resource_group_name = var.buildResourceGroupName
  os_type                           = "Windows"
  vm_size                           = var.vmSize
  winrm_insecure                    = true
  winrm_timeout                     = "5m"
  winrm_use_ssl                     = true
  winrm_username                    = var.winrmUsername
}

build {
  sources             = ["source.azure-arm.cariad_runner_vm"]
  provisioner "powershell" {
    inline            = [
      # Ensure agent is prepared
      "while ((Get-Service RdAgent).Status -ne 'Running') { Start-Sleep -s 5 }",
      "while ((Get-Service WindowsAzureGuestAgent).Status -ne 'Running') { Start-Sleep -s 5 }",
      # Switch to Temp directory
      "Set-Location $env:TEMP",
      # Install Chocolatey for apps, run official installation script
      "Write-Host -ForegroundColor White Installing Chocolatey...",
      "Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))",
      # Visual Studio step
      ## Download
      "Invoke-RestMethod -Uri https://aka.ms/vs/17/release/vs_community.exe -OutFile vs_community.exe",
      ## Install
      "Write-Host -ForegroundColor White Creating offline Visual Studio...",
      "Start-Process .\\vs_Community.exe -Wait -ArgumentList '--wait','--quiet','--layout','C:\\localVSlayout\\','--add','Microsoft.VisualStudio.Workload.NativeDesktop','--includeRecommended','--includeOptional','--lang','en-US'",
      "Write-Host -ForegroundColor White Installing Visual Studio...",
      "Start-Process $env:SYSTEMDRIVE\\localVSlayout\\vs_Community.exe -Wait -ArgumentList '--wait','--quiet','--noWeb','--add','Microsoft.VisualStudio.Workload.NativeDesktop','--includeRecommended','--includeOptional'",
      # Telegraf installation step
      "Write-Host -ForegroundColor White Installing Telegraf...",
      "choco install telegraf -y",
      # Docker installation step
      "Write-Host -ForegroundColor White Installing Docker CLI...",
      "choco install docker-cli -y",
      "Write-Host -ForegroundColor White Installing Docker Desktop...",
      "choco install docker-desktop -y",
      "Write-Host -ForegroundColor White Automatically start Docker Desktop...",
      "Set-Service -Name com.docker.service -StartupType Automatic",
      # Install Hyper-V
      "Write-Host -ForegroundColor White Installing Hyper-V...",
      "Install-WindowsFeature -Name Hyper-V -IncludeManagementTools"
    ]
    timeout           = "4h"
    elevated_user     = "packer"
    elevated_password = build.Password
    valid_exit_codes  = [ 0, 1 ]
  }
  provisioner "windows-restart" {
    restart_command   = "shutdown /r /f /t 90 /c for-sysprep-not-to-fail"
    pause_before      = "30s"
    timeout           = "15m"
  }
  provisioner "powershell" {
    inline            = [
      # Enable Ansible remoting
      "Write-Host -ForegroundColor White Enabling Ansible remoting...",
      "Invoke-RestMethod https://raw.githubusercontent.com/ansible/ansible-documentation/devel/examples/scripts/ConfigureRemotingForAnsible.ps1 -OutFile $env:SYSTEMDRIVE\\ConfigureRemotingForAnsible.ps1",
      "New-Item HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\RunOnce -Name AnsibleRemote -Value 'C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe -ExecutionPolicy Bypass -File C:\\ConfigureRemotingForAnsible.ps1 -ForceNewSSLCert'",
      # Do sysprep
      "Write-Host -ForegroundColor White Sysprepping machine...",
      "Start-Process $env:WINDIR\\System32\\Sysprep\\sysprep.exe -ArgumentList '/oobe','/generalize','/quiet','/quit'",
      # Check that Sysprep is actually finished and shut down when it is
      "while($true) { $imageState = Get-ItemProperty HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Setup\\State | Select ImageState; if($imageState.ImageState -ne 'IMAGE_STATE_GENERALIZE_RESEAL_TO_OOBE') { Write-Output $imageState.ImageState; Start-Sleep -s 10  } else { break } }"
    ]
    timeout           = "30m"
    elevated_user     = "packer"
    elevated_password = build.Password
    valid_exit_codes  = [ 0, 1 ]
  }
}
