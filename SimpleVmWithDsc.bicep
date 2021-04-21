
param subnetName string = 'snet-shared-uks-002'
param existingvNetRg string = 'rg-vnet-hub-uks-001'
param virtualMachineName string = 'vm-dsc-uks-02'
param virtualMachineComputerName string = 'vm-dsc-uks-01'
param osDiskType string = 'StandardSSD_LRS'
param virtualMachineSize string = 'Standard_DS1_v2'
param adminUsername string = 'azure_admin'

param configurationFunction string = 'GMT-Timezone.ps1\\SetTimeZoneGMT'
param moduleFilePath string = 'GMT-Timezone.zip'
param _artifactsLocation string
@secure()
param _artifactsLocationSasToken string




@secure()
param adminPassword string
param patchMode string = 'manual'
param enableHotpatching bool = false
param zone string = '1'


var location = resourceGroup().location
var networkInterfaceName  = 'nic-${virtualMachineName}'
var ModulesUrl = '${_artifactsLocation}${moduleFilePath}${_artifactsLocationSasToken}'

resource existingvNet 'Microsoft.Network/virtualNetworks@2020-11-01' existing = {
  name: 'vnet-hub-uks-001'
  scope: resourceGroup(existingvNetRg)
}

resource networkInterfaceName_resource 'Microsoft.Network/networkInterfaces@2018-10-01' = {
  name: networkInterfaceName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: '${existingvNet.id}/subnets/${subnetName}'
          }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
  }
  dependsOn: []
}

resource virtualMachineName_resource 'Microsoft.Compute/virtualMachines@2020-12-01' = {
  name: virtualMachineName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: virtualMachineSize
    }
    storageProfile: {
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: osDiskType
        }
      }
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2019-Datacenter'
        version: 'latest'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterfaceName_resource.id
        }
      ]
    }
    osProfile: {
      computerName: virtualMachineComputerName
      adminUsername: adminUsername
      adminPassword: adminPassword
      windowsConfiguration: {
        enableAutomaticUpdates: false
        provisionVMAgent: true
        patchSettings: {
          enableHotpatching: enableHotpatching
          patchMode: patchMode
        }
      }
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
  zones: [
    zone
  ]
}

resource DSC 'Microsoft.Compute/virtualMachines/extensions@2020-12-01' = {
  location: location
  name: '${virtualMachineName_resource.name}/PowerShell.DSC'
  properties: {
    publisher: 'Microsoft.Powershell'
    type: 'DSC'
    typeHandlerVersion: '2.19'
    autoUpgradeMinorVersion: true
    settings: {
      //ModulesUrl: 'https://stggitchdsc01.blob.core.windows.net/dsc/GMT-Timezone.zip?sp=r&se=2021-04-21T16:29:19Z&sv=2020-02-10&sr=b&sig=wsQlcuJuzKQcUXJ4sD7vfWRLMdqKckyCCWHMK%2BPHvRg%3D'
      ModulesUrl: ModulesUrl
      ConfigurationFunction: configurationFunction
      properties: {}
    }
  }
}



output adminUsername string = adminUsername
