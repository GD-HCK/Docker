
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