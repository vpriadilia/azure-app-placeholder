@description('Short prefix used to build resource names, e.g. "phapp".')
@minLength(2)
@maxLength(10)
param namePrefix string = 'phapp'

@description('Environment name, e.g. dev, test, prod.')
param environmentName string = 'dev'

@description('Location for most resources (App Service, Log Analytics, App Insights).')
param location string = resourceGroup().location

@description('Location for the Static Web App. Static Web Apps are only available in a subset of regions.')
@allowed([
  'centralus'
  'eastus2'
  'eastasia'
  'westeurope'
  'westus2'
])
param staticWebAppLocation string = 'westeurope'

@description('App Service Plan SKU for the API.')
param appServicePlanSku string = 'B1'

@description('.NET runtime version for the API, must match an available Linux App Service stack (e.g. az webapp list-runtimes --os linux).')
param dotnetVersion string = '10.0'

var resourceToken = toLower(uniqueString(resourceGroup().id, namePrefix, environmentName))
var appServicePlanName = '${namePrefix}-plan-${environmentName}'
var apiAppName = '${namePrefix}-api-${environmentName}-${resourceToken}'
var staticWebAppName = '${namePrefix}-ui-${environmentName}-${resourceToken}'
var logAnalyticsName = '${namePrefix}-log-${environmentName}-${resourceToken}'
var appInsightsName = '${namePrefix}-appi-${environmentName}-${resourceToken}'

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: logAnalyticsName
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
  }
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalytics.id
    IngestionMode: 'LogAnalytics'
  }
}

resource appServicePlan 'Microsoft.Web/serverfarms@2023-12-01' = {
  name: appServicePlanName
  location: location
  kind: 'linux'
  sku: {
    name: appServicePlanSku
  }
  properties: {
    reserved: true
  }
}

resource staticWebApp 'Microsoft.Web/staticSites@2024-04-01' = {
  name: staticWebAppName
  location: staticWebAppLocation
  sku: {
    name: 'Free'
    tier: 'Free'
  }
  properties: {}
}

resource apiApp 'Microsoft.Web/sites@2023-12-01' = {
  name: apiAppName
  location: location
  kind: 'app,linux'
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
    siteConfig: {
      linuxFxVersion: 'DOTNETCORE|${dotnetVersion}'
      alwaysOn: true
      ftpsState: 'Disabled'
      appSettings: [
        {
          name: 'ASPNETCORE_ENVIRONMENT'
          value: 'Production'
        }
        {
          name: 'AllowedOrigins__0'
          value: 'https://${staticWebApp.properties.defaultHostname}'
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: appInsights.properties.ConnectionString
        }
        {
          name: 'WEBSITE_RUN_FROM_PACKAGE'
          value: '1'
        }
      ]
    }
  }
}

output apiUrl string = 'https://${apiApp.properties.defaultHostName}'
output staticWebAppUrl string = 'https://${staticWebApp.properties.defaultHostname}'
output apiAppName string = apiApp.name
output staticWebAppName string = staticWebApp.name
output resourceGroupName string = resourceGroup().name
