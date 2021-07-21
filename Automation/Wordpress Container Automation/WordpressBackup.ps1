[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]
    [ValidateNotNullOrEmpty()]
    $backupfolder,

    [Parameter(Mandatory = $true)]
    [string]
    [ValidateNotNullOrEmpty()]
    $WordpressDBContainerName,

    [Parameter(Mandatory = $true)]
    [string]
    [ValidateNotNullOrEmpty()]
    $WordpressWEBContainerName
)
$dateTime = Get-Date -Format "dd-MM-yyyy_hh-mm-ss"

$backupfolderlocation = Test-Path -Path $backupfolder

if (!$backupfolderlocation) {
    New-Item -Path $backupfolder -ItemType Directory
}

# Stop containers
Write-Host "Stopping containers" -ForegroundColor Yellow

docker container stop $WordpressDBContainerName
docker container stop $WordpressWEBContainerName

Write-Host "Containers stopped" -ForegroundColor Green
Start-Sleep 10

Write-Host ""
Write-Host "Backing up database files" -ForegroundColor Yellow
$mountpoint = $backupfolder + ":/backup"
$command = "cd /var/lib/mysql && tar cvf /backup/wordpress_dbs_" + $dateTime + ".tar ."
docker run --rm --volumes-from $WordpressDBContainerName -v $mountpoint ubuntu bash -c $command

Write-Host ""
Write-Host "Backing up web filesystem files" -ForegroundColor Yellow
$mountpoint = $backupfolder + ":/backup"
$command = "cd /var/www/html && tar cvf /backup/wordpress_web_"+ $dateTime + ".tar ."
docker run --rm --volumes-from $WordpressWebServer -v $mountpoint ubuntu bash -c $command

Write-Host ""
Write-Host "Backup completed." -ForegroundColor Green

Write-Host ""
Write-Host "Starting DB Container" -ForegroundColor Yellow
docker container start $WordpressDBContainerName
Write-Host "Waiting for DB containers to start" -ForegroundColor Yellow
Start-Sleep 15
Write-Host ""
Write-Host "Starting Web Container" -ForegroundColor Yellow
docker container start $WordpressWEBContainerName
Write-Host ""
Write-Host "Containers started. Check docker for issues" -ForegroundColor Green