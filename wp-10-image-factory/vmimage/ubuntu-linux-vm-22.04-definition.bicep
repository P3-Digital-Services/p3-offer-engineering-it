param galleryName string
param imageDefinitionName string
param location string
param publisher string
param offer string
param sku string

resource imageDefinition 'Microsoft.Compute/galleries/images@2022-03-03' = {
  name: '${galleryName}/${imageDefinitionName}'
  location: location
  properties: {
    osType: 'Linux'
    osState: 'Generalized'
    identifier: {
      publisher: publisher
      offer: offer
      sku: sku
    }
    recommended: {
      vCPUs: {
        min: 2
        max: 8
      }
      memory: {
        min: 4
        max: 32
      }
    }
    hyperVGeneration: 'V2'
  }
}

output imageDefinitionId string = imageDefinition.id
