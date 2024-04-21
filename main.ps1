#Connect-MgGraph -Scopes "User.Read.All","Group.ReadWrite.All"
Connect-AzAccount


$moduleName = "Microsoft.Graph"

if (Get-Module -ListAvailable -Name $moduleName) {
    Write-Host " $moduleName exists!!  Initializing the module right now"
    Import-Module Microsoft.Graph.Users
    
    
    $params = @{
	    accountEnabled = $true
	    displayName = "Rauni Ribeiro"
	    mailNickname = "raunirr98"
	    userPrincipalName = "raunirr98@gmail.com"
	    passwordProfile = @{
		    forceChangePasswordNextSignIn = $true
		    password = "xWwvJ]6NMw+bWH-dfffzc"
	    }
    }

    New-MgUser -BodyParameter $params


    Write-Host "user $displayName was successfully created!"
    
} else {
    Write-Host "nothing found - installing $moduleName"
    Install-Module $moduleName -Scope CurrentUser -Force
    Write-Host "Installation Complete!"
}