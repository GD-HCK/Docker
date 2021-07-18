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

$backupfolderlocation = Test-Path -Path $backupfolder

if (!$backupfolderlocation) {
    Write-Error "Backup folder does not exist. Aborting restore"
    exit
}
else {
# Stop containers
Write-Host "Stopping containers" -ForegroundColor Yellow

docker container stop $OctopusDBContainerName
docker container stop $OctopusWEBContainerName

Write-Host "Containers stopped" -ForegroundColor Green
Start-Sleep 10

    Write-Host ""
    
    $items = Get-ChildItem -Path $backupfolder
    $mountpoint = $backupfolder+":/backup"
    foreach ($item in $items){
        Write-Host ""
        Write-Host "I am working on" $item.Name -ForegroundColor Cyan
        if(($item.Name).Contains("db")){
            Write-Host "Restoring db files" -ForegroundColor Yellow
            $command = "rm -rf /var/opt/mssql/data/* && cd /var/opt/mssql/data && tar xvf /backup/"+$item.Name+" ."
            Write-Host "Executing command" -ForegroundColor Yellow
            $command
            docker run --rm --volumes-from $OctopusDBContainerName -v $mountpoint ubuntu bash -c $command
        }else{
            Write-Host "Restoring Web filesystem files" -ForegroundColor Yellow
            $directory = ($item.Name).Split("_")
            $command = "rm -rf /"+$directory[0]+"/* && cd /"+$directory[0]+" && tar xvf /backup/"+$item.Name+" ."
            Write-Host "Executing command" -ForegroundColor Yellow
            $command
            docker run --rm --volumes-from $OctopusWEBContainerName -v $mountpoint ubuntu bash -c $command
        }
        
    }
    
    Write-Host ""
    Write-Host "Restore completed." -ForegroundColor Green

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
}