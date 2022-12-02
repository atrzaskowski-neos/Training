#Connect to your Azure Tenant
Connect-AzAccount
#Select the subscription you want to deploy to
Select-AzSubscription 'VSEnt - Adam'
#Create a new resource group, where the resources will be placed
$ResourceGroupName = 'demo'
New-AzResourceGroup -Name $ResourceGroupName -Location westeurope

#Create the VM, along with underlying network infrastructure

#Password needs to be passed-in as secure string
$securePassword = ConvertTo-SecureString "password12345!@#$%" -AsPlainText
#Run the deployment to resource group previously created
New-AzResourceGroupDeployment -ResourceGroupName $ResourceGroupName -TemplateFile VM.bicep -adminUsername "adminUser" -adminPassword $securePassword

#Install PowerShell Chocolatey Module
$moduleName = 'cChoco'
$moduleVersion = '2.5.0.0'
New-AzAutomationModule -AutomationAccountName 'DemoAutomationAccount' -ResourceGroupName $ResourceGroupName -Name $moduleName -ContentLinkUri "https://www.powershellgallery.com/api/v2/package/$moduleName/$moduleVersion"

#Install PowerShell DSC GPRegistryPolicyDsc
$moduleName = 'GPRegistryPolicyDsc'
$moduleVersion = '1.2.0'
New-AzAutomationModule -AutomationAccountName 'DemoAutomationAccount' -ResourceGroupName $ResourceGroupName -Name $moduleName -ContentLinkUri "https://www.powershellgallery.com/api/v2/package/$moduleName/$moduleVersion"

#Import both DSC Configurations
Import-AzAutomationDscConfiguration -AutomationAccountName "DemoAutomationAccount" -ResourceGroupName $ResourceGroupName -SourcePath .\DSC_WebServer.ps1 -Published -Force

#Compile DSC Configuration
Start-AzAutomationDscCompilationJob -ConfigurationName "DSC_WebServer" -ResourceGroupName $ResourceGroupName -AutomationAccountName "DemoAutomationAccount"

#Assign DSC Configuration to the new VM
Register-AzAutomationDscNode -AutomationAccountName 'DemoAutomationAccount' -AzureVMName "demo-vm" -ResourceGroupName $ResourceGroupName -NodeConfigurationName "DSC_WebServer.demo-vm" -ConfigurationMode ApplyAndAutocorrect