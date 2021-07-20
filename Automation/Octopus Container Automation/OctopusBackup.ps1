[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]
    [ValidateNotNullOrEmpty()]
    $backupfolder,

    [Parameter(Mandatory = $true)]
    [string]
    [ValidateNotNullOrEmpty()]
    $OctopusDBContainerName,

    [Parameter(Mandatory = $true)]
    [string]
    [ValidateNotNullOrEmpty()]
    $OctopusWEBContainerName
)
$dateTime = Get-Date -Format "dd-MM-yyyy_hh-mm-ss"

$backupfolderlocation = Test-Path -Path $backupfolder

if (!$backupfolderlocation) {
    New-Item -Path $backupfolder -ItemType Directory
}

# Stop containers
Write-Host "Stopping containers" -ForegroundColor Yellow

docker container stop $OctopusDBContainerName
docker container stop $OctopusWEBContainerName

Write-Host "Containers stopped" -ForegroundColor Green
Start-Sleep 10

Write-Host ""
Write-Host "Backing up database files" -ForegroundColor Yellow
$mountpoint = $backupfolder + ":/backup"
$command = "cd /var/opt/mssql/data && tar cvf /backup/octopus_dbs_" + $dateTime + ".tar ."
docker run --rm --volumes-from $OctopusDBContainerName -v $mountpoint ubuntu bash -c $command

Write-Host ""
Write-Host "Backing up web filesystem files" -ForegroundColor Yellow
$directories = @("repository", "artifacts", "taskLogs", "cache", "import", "Octopus")
$backupdirectory = "C:\Docker_Volumes_backups"
$mountpoint = $backupdirectory + ":/backup"
foreach ($directory in $directories){
    $command = "cd /"+$directory+" && tar cvf /backup/"+$directory+"_"+ $dateTime + ".tar ."
    docker run --rm --volumes-from $octopusWebServer -v $mountpoint ubuntu bash -c $command
}

Write-Host ""
Write-Host "Backup completed." -ForegroundColor Green

Write-Host ""
Write-Host "Starting DB Container" -ForegroundColor Yellow
docker container start $OctopusDBContainerName
Write-Host "Waiting for DB containers to start" -ForegroundColor Yellow
Start-Sleep 15
Write-Host ""
Write-Host "Starting Web Container" -ForegroundColor Yellow
docker container start $OctopusWEBContainerName
Write-Host ""
Write-Host "Containers started. Check docker for issues" -ForegroundColor Green