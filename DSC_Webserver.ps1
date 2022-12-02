Configuration DSC_Webserver
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName cChoco 
    Import-DscResource -ModuleName 'GPRegistryPolicyDsc'


    Node 'demo-vm' {
        cChocoInstaller installChoco
        {
            InstallDir = "c:\ProgramData\chocolatey"
        }

        cChocoPackageInstaller 7zip
        {
            Name     = "7zip"
            Version  = "22.1"
            DependsOn = "[cChocoInstaller]installChoco"
        }

        cChocoPackageInstaller notepadplusplus
        {
            Name     = "notepadplusplus"
            Version  = "8.4.7"
            DependsOn = "[cChocoInstaller]installChoco"
        }
        WindowsFeature RoleExample
        {
            Ensure = "Present"
            # Alternatively, to ensure the role is uninstalled, set Ensure to "Absent"
            Name = "Web-Server" # Use the Name property from Get-WindowsFeature
        }
        Environment EnvironmentExample
        {
            Ensure = "Present"  # You can also set Ensure to "Absent"
            Name = "DemoEnvironmentVariable"
            Value = "DemoValue"
        }
        # Configuration that will enable the the policy the prohibits changes to the desktop only
        # for the Users group (Non-administrators) account.
        RegistryPolicyFile 'DisableDesktopChanges'
        {
            Key         = 'Software\Microsoft\Windows\CurrentVersion\Policies\Explorer'
            TargetType  = 'Account'
            ValueName   = 'NoActiveDesktopChanges'
            AccountName = 'Users'
            ValueData   = 1
            ValueType   = 'DWORD'
            Ensure      = 'Present'
        }

        RefreshRegistryPolicy 'RefreshPolicyAfterDisableDesktopChanges'
        {
            IsSingleInstance = 'Yes'
            DependsOn        = '[RegistryPolicyFile]DisableDesktopChanges'
        }
    }
}

DSC_Webserver