param imageTemplateName string
param galleryName string
param galleryResourceGroup string
param imageVersion string
param userAssignedIdentityId string
param imageDefinitionName string

var location = resourceGroup().location
var publisher = 'Canonical'
var offer = '0001-com-ubuntu-server-jammy'
var sku = '22_04-lts-gen2'
var baseImageVersion = 'latest'
var vmSize = 'Standard_D4s_v3'
var osDiskSizeGB = 30
var buildTimeoutInMinutes = 180
var galleryResourceId = resourceId(galleryResourceGroup, 'Microsoft.Compute/galleries', galleryName)

module imageDefinitionModule 'ubuntu-linux-vm-22.04-definition.bicep' = {
  name: 'imageDefinitionDeployment'
  scope: resourceGroup(galleryResourceGroup)
  params: {
    galleryName: galleryName
    imageDefinitionName: imageDefinitionName
    location: location
    publisher: publisher
    offer: offer
    sku: sku
  }
}

resource imageTemplate 'Microsoft.VirtualMachineImages/imageTemplates@2022-02-14' = {
  name: imageTemplateName
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${userAssignedIdentityId}': {}
    }
  }
  properties: {
    buildTimeoutInMinutes: buildTimeoutInMinutes
    vmProfile: {
      vmSize: vmSize
      osDiskSizeGB: osDiskSizeGB
    }
    source: {
      type: 'PlatformImage'
      publisher: publisher
      offer: offer
      sku: sku
      version: baseImageVersion
    }
    customize: [
      {
        type: 'Shell'
        name: 'UpdateAndInstallPackages'
        inline: [

          'apt update'
          'apt install -y curl'
        ]
      }
      {
        type: 'Shell'
        name: 'CleanUp'
        inline: [
          'apt clean'
          'rm -rf /var/lib/apt/lists/*'
        ]
      }
    ]
    distribute: [
      {
        type: 'SharedImage'
        galleryImageId: '${galleryResourceId}/images/${imageDefinitionName}/versions/${imageVersion}'
        replicationRegions: [
          location
        ]
        runOutputName: imageDefinitionName
        artifactTags: {
          source: 'azureVmImageBuilder'
          baseosimg: '${publisher}:${offer}:${sku}:${baseImageVersion}'
        }
      }
    ]
  }
  dependsOn: [
    imageDefinitionModule
  ]
}

output imageTemplateId string = imageTemplate.id
