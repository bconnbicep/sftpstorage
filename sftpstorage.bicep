
@description('Location of the storage.')
param location string = resourceGroup().location


// @description('Name of the blob container in the Azure Storage account.')
// param blobContainerName string

param utc string = utcNow()
var storageaccountname  = 'sftpstorage${uniqueString(utc)}'
var sftpRootContainerName = 'sftpcontainer${uniqueString(utc)}'
var sftpUserName = 'sftpuser1'

resource sftpStorageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: storageaccountname
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
      supportsHttpsTrafficOnly: true
       isHnsEnabled: true
       allowBlobPublicAccess: true 
  }

  resource blobContainer 'blobServices@2023-01-01' = {
    name: 'default'
    properties: {
       
    }
    resource sftpStorageContainer 'containers' = {
      name: sftpRootContainerName // The 'root' folder in the DLV2 storage will be 'sftp'
      properties: {}
    }
  }
  
}

resource sftpLocalUser 'Microsoft.Storage/storageAccounts/localUsers@2023-05-01' = {
  name: sftpUserName // Do not change this parameter, which is set to 'sftpuser'
  parent: sftpStorageAccount
  properties: {
    permissionScopes: [
      {
        permissions: 'rcwdl'
        service: 'blob'
        resourceName: sftpRootContainerName
      }
    ]
    // homeDirectory is set to the 'root' directory, which is named 'sftp'. Note the '/' which is required
    homeDirectory: '${sftpRootContainerName}/' // This user will have complete control over the "root" directory in sftpRootContainterName
    // The other end of the SFTP connection must supply an OpenSSH-generated (or compatible) public key
     hasSshPassword: true
  }
}

