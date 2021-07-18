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

if(!$backupfolderlocation){
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
$mountpoint = $backupfolder+":/backup"
$command = "cd /var/opt/mssql/data && tar cvf /backup/octopus_dbs_"+$dateTime+".tar ."
docker run --rm --volumes-from $OctopusDBContainerName -v $mountpoint ubuntu bash -c $command

Write-Host ""
Write-Host "Backing up web filesystem files" -ForegroundColor Yellow
$command = "cd /repository && tar cvf /backup/repository_"+$dateTime+".tar ."
docker run --rm --volumes-from $OctopusWEBContainerName -v $mountpoint ubuntu bash -c $command
$command = "cd /artifacts && tar cvf /backup/artifacts_"+$dateTime+".tar ."
docker run --rm --volumes-from $OctopusWEBContainerName -v $mountpoint ubuntu bash -c $command
$command = "cd /taskLogs && tar cvf /backup/taskLogs_"+$dateTime+".tar ."
docker run --rm --volumes-from $OctopusWEBContainerName -v $mountpoint ubuntu bash -c $command
$command = "cd /cache && tar cvf /backup/cache_"+$dateTime+".tar ."
docker run --rm --volumes-from $OctopusWEBContainerName -v $mountpoint ubuntu bash -c $command
$command = "cd /import && tar cvf /backup/import_"+$dateTime+".tar ."
docker run --rm --volumes-from $OctopusWEBContainerName -v $mountpoint ubuntu bash -c $command

Write-Host ""
Write-Host "Backup completed." -ForegroundColor Green

Write-Host ""
Write-Host "Starting DB Container" -ForegroundColor Yellow
docker container start $OctopusDBContainerName
Write-Host "Waiting for DB containers to start"
Start-Sleep 15
Write-Host ""
Write-Host "Starting Web Container" -ForegroundColor Yellow
docker container start $OctopusWEBContainerName
Write-Host ""
Write-Host "Containers started. Check docker for issues" -ForegroundColor Green