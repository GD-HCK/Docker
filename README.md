# Readme

## Getting Started on Windows


## Keep your docker up-to-date
* `Windows 10`

    Install docker via [Docker Hub](https://hub.docker.com/editions/community/docker-ce-desktop-windows/ "Docker Hub")
* `Windows Server`
    ```powershell
    # Run the below as administrator in Powershell 5.1 only for windows server
    install-module DockerProvider -Force 
    install-package Docker -ProviderName DockerProvider -Force
    ```


## Docker basic commands
* #### Start container in Detached mode (Background run):
    ```powershell
    # Syntax:
    docker run --detach --name $container_name --publish 8080:8080 `
               --env $required_environment_variable  "$image_name`:$tag"
    # Example:
    docker run -d --name ubuntu -p 8080:80 ubuntu:latest
    ``` 
* #### Start container in Interactive mode (Foreground run):
    ```powershell
    # Syntax:
    docker run --interactive --name $container_name --publish 8080:8080 `
               --env $required_environment_variable  "$image_name`:$tag"
    # Use Ctrl+P+Q to exit the foreground console and leave the container running in the background
    # Example:
    docker run -it --name ubuntu -p 8080:80 ubuntu:latest
    ```
* #### Remove all stopped containers and associated unused volumes
    ```powershell
    docker ps --filter "status=exited" -q | %{docker container rm -v $_} `
    && docker volume rm $(docker volume ls -f dangling=true -q)
    ```

## Docker Topics
`Check each folder's .md file for instructions`

1. [Automation](./Automation/README.md)
1. [Compose](./Compose/README.md) [In Progress]
1. [Octopus Container](./Octopus%20Container/README.md)
1. [Wordpress Container](./Wordpress%20Container/README.md)


```powershell

[CmdletBinding()]
param (
    [Parameter()]
    [switch]
    $Wordpress,

    [Parameter()]
    [switch]
    $Octopus
)
function New-PasswordSet {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [Int32]
        [ValidateNotNull()]
        [ValidateRange(1, 500)]
        $PasswordLength,

        [Parameter()]
        [switch]
        $RemoveSpecialCharacters,

        [Parameter()]
        [switch]
        $RemoveUpperCaseCharacters,

        [Parameter()]
        [switch]
        $RemoveLowerCaseCharacters,

        [Parameter()]
        [switch]
        $RemoveNumbers
    )

    [System.Collections.ArrayList]$chars = @()
    for ($i = 33; $i -le 126; $i++) {
        $chars.Add([char]$i) | Out-Null
    }
    if ($RemoveSpecialCharacters) {
        for ($i = 33; $i -le 47; $i++) {
            $char = [char]$i
            $chars.Remove($char) | Out-Null
        }
        for ($i = 58; $i -le 64; $i++) {
            $char = [char]$i
            $chars.Remove($char) | Out-Null
        }
        for ($i = 91; $i -le 96; $i++) {
            $char = [char]$i
            $chars.Remove($char) | Out-Null
        }
        for ($i = 123; $i -le 126; $i++) {
            $char = [char]$i
            $chars.Remove($char) | Out-Null
        }
    }
    if ($RemoveUpperCaseCharacters) {
    
        for ($i = 65; $i -le 90; $i++) {
            $char = [char]$i
            $chars.Remove($char) | Out-Null
        }
    }
    if ($RemoveLowerCaseCharacters) {
    
        for ($i = 97; $i -le 122; $i++) {
            $char = [char]$i
            $chars.Remove($char) | Out-Null
        }
    }
    if ($RemoveNumbers) {
    
        for ($i = 48; $i -le 57; $i++) {
            $char = [char]$i
            $chars.Remove($char) | Out-Null
        }
    }
    if ($chars.Count -eq 0) {
        Write-Host "You can't create a password out of nothing! Refine your filtering criteria and try again!" -ForegroundColor Red
    }
    else {
        [System.Collections.ArrayList]$password = @()

        for ($i = 1; $i -le $PasswordLength; $i++) {
            $char = $chars | Get-Random -Count 1 | ForEach-Object { [char]$_ }
            $password.Add($char) | Out-Null
        }
        [string]$password = -join ($password)
        return $password
    }
}

if ($Wordpress) {

    $WORDPRESS_DB_PASSWORD = New-PasswordSet -PasswordLength 20 -RemoveSpecialCharacters

    Write-Host "+==================================================+" -ForegroundColor Magenta
    Write-Host '| ' -ForegroundColor Magenta -NoNewline; Write-Host 'WORDPRESS_DB_PASSWORD    =  ' -ForegroundColor Yellow -NoNewline; Write-Host $WORDPRESS_DB_PASSWORD -ForegroundColor Cyan -NoNewline; Write-Host " |" -ForegroundColor Magenta
    Write-Host "+==================================================+" -ForegroundColor Magenta
}

if ($Octopus) {

    $ADMIN_PASSWORD = New-PasswordSet -PasswordLength 15
    $SA_PASSWORD = New-PasswordSet -PasswordLength 20 -RemoveSpecialCharacters
    $MASTER_KEY = New-PasswordSet -PasswordLength 22 -RemoveSpecialCharacters
    $ADMIN_API_KEY = New-PasswordSet -PasswordLength 30 -RemoveSpecialCharacters -RemoveLowerCaseCharacters

    Write-Host "+======================================================+" -ForegroundColor Magenta
    Write-Host '| ' -ForegroundColor Magenta -NoNewline; Write-Host 'SA_PASSWORD    =  ' -ForegroundColor Yellow -NoNewline; Write-Host $SA_PASSWORD -ForegroundColor Cyan -NoNewline; Write-Host "               |" -ForegroundColor Magenta
    Write-Host '| ' -ForegroundColor Magenta -NoNewline; Write-Host 'ADMIN_PASSWORD =  ' -ForegroundColor Yellow -NoNewline; Write-Host $ADMIN_PASSWORD -ForegroundColor Cyan -NoNewline; Write-Host "                    |" -ForegroundColor Magenta
    Write-Host '| ' -ForegroundColor Magenta -NoNewline; Write-Host 'MASTER_KEY     =  ' -ForegroundColor Yellow -NoNewline; Write-Host $MASTER_KEY"==" -ForegroundColor Cyan -NoNewline; Write-Host "           |" -ForegroundColor Magenta
    Write-Host '| ' -ForegroundColor Magenta -NoNewline; Write-Host 'ADMIN_API_KEY  =  ' -ForegroundColor Yellow -NoNewline; Write-Host "API-$ADMIN_API_KEY" -ForegroundColor Cyan -NoNewline; Write-Host " |"-ForegroundColor Magenta
    Write-Host "+======================================================+" -ForegroundColor Magenta
}
```
