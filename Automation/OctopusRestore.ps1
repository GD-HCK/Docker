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

function removeBackups {
    $removeBackupFiles = Read-Host -Prompt "Do you want to remove the backup files? yes/no"
    if($removeBackupFiles -ieq "yes" -or $removeBackupFiles -ieq "y"){
        $items = Get-ChildItem -Path $backupfolder
        $items | Remove-Item
        Write-Host "Backups removed successfully" -ForegroundColor Green
    }elseif($removeBackupFiles -ine "no" -or $removeBackupFiles -ine "n" -or $null -ne $removeBackupFiles){
        Write-Warning "Invalid input. Answer either yes or no (y and n are also allowed)"
        removeBackups
    }
}

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
            $command = "rm -rf /var/opt/mssql/data/* && cd /var/opt/mssql/data && tar xvf /backup/"+$item.Name+" ."
            $task = "docker run --rm --volumes-from $OctopusDBContainerName -v $mountpoint ubuntu bash -c $command"
            Write-Progress -Activity "Restoring db files" -Status "Executing command" -CurrentOperation $task
            docker run --rm --volumes-from $OctopusDBContainerName -v $mountpoint ubuntu bash -c $command | Out-Null
        }else{
            $directory = ($item.Name).Split("_")
            $command = "rm -rf /"+$directory[0]+"/* && cd /"+$directory[0]+" && tar xvf /backup/"+$item.Name+" ."
            $task = "docker run --rm --volumes-from $OctopusWEBContainerName -v $mountpoint ubuntu bash -c $command"
            Write-Progress -Activity "Restoring Web filesystem files" -Status "Executing command" -CurrentOperation $task
            docker run --rm --volumes-from $OctopusWEBContainerName -v $mountpoint ubuntu bash -c $command | Out-Null
        }
        
    }
    
    Write-Host ""
    Write-Host "Restore completed." -ForegroundColor Green

    Write-Host ""
    Write-Host "Starting DB Container" -ForegroundColor Yellow
    docker container start $OctopusDBContainerName
    Write-Host "Waiting for DB containers to initialise" -ForegroundColor Yellow
    Start-Sleep 15
    Write-Host "" 
    Write-Host "Starting Web Container" -ForegroundColor Yellow
    docker container start $OctopusWEBContainerName
    Write-Host ""
    Write-Host "Containers started. Check Docker for issues" -ForegroundColor Green
    removeBackups
}