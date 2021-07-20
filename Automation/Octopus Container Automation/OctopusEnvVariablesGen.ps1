[System.Collections.ArrayList]$chars = @()
for ($i = 33; $i -le 126; $i++) {
    $chars.Add([char]$i) | Out-Null
}

function passwordGen($number) {
    [System.Collections.ArrayList]$password = @()

    for ($i = 1; $i -le $number; $i++) {
        $char = $chars | Get-Random -Count 1 | ForEach-Object { [char]$_ }
        $password.Add($char) | Out-Null
    }
    [string]$password = -join ($password)
    return $password
}

for ($i = 40; $i -le 47; $i++) {
    $char = [char]$i
    $chars.Remove($char) | Out-Null
}
for ($i = 58; $i -le 62; $i++) {
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

$ADMIN_PASSWORD = passwordGen 15

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

$SA_PASSWORD = passwordGen 20
$MASTER_KEY = passwordGen 22

for ($i = 97; $i -le 122; $i++) {
    $char = [char]$i
    $chars.Remove($char) | Out-Null
}

$ADMIN_API_KEY = passwordGen 30


Write-Host "========================================================" -ForegroundColor Magenta
Write-Host '| ' -ForegroundColor Magenta -NoNewline; Write-Host 'SA_PASSWORD    =  ' -ForegroundColor Yellow -NoNewline; Write-Host $SA_PASSWORD -ForegroundColor Cyan -NoNewline; Write-Host "               |" -ForegroundColor Magenta
Write-Host '| ' -ForegroundColor Magenta -NoNewline; Write-Host 'ADMIN_PASSWORD =  ' -ForegroundColor Yellow -NoNewline; Write-Host $ADMIN_PASSWORD -ForegroundColor Cyan -NoNewline; Write-Host "                    |" -ForegroundColor Magenta
Write-Host '| ' -ForegroundColor Magenta -NoNewline; Write-Host 'MASTER_KEY     =  ' -ForegroundColor Yellow -NoNewline; Write-Host $MASTER_KEY"==" -ForegroundColor Cyan -NoNewline; Write-Host "           |" -ForegroundColor Magenta
Write-Host '| ' -ForegroundColor Magenta -NoNewline; Write-Host 'ADMIN_API_KEY  =  ' -ForegroundColor Yellow -NoNewline; Write-Host "API-$ADMIN_API_KEY" -ForegroundColor Cyan -NoNewline; Write-Host " |"-ForegroundColor Magenta
Write-Host "========================================================" -ForegroundColor Magenta
