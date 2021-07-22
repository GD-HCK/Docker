[CmdletBinding()]
param (
    [Parameter()]
    [string]
    [ValidateNotNullOrEmpty()]
    $DockerRootDir
)
begin {
    # Variables definition
    $OctopusProjectName = "octopus"
    $WordpressProjectName = "wp"
    
    # Check if Backup Location exists
    $PathExist = Test-Path -Path $DockerRootDir -ErrorAction SilentlyContinue
    if ($PathExist) {
        $ProjectsDirs = Get-ChildItem -Path $DockerRootDir -ErrorAction SilentlyContinue -ErrorVariable isEmpty
        if(!$isEmpty){
            foreach ($Dir in $ProjectsDirs) {
                $PathExist = Test-Path -Path "$($Dir.FullName)\Backups" -ErrorAction SilentlyContinue
                if ($PathExist) {
                    $BackupDirectories += @("$($Dir.FullName)\Backups")
                }
            }
        
            if ($BackupDirectories.Count -gt 0) {
                foreach ($BackupDirectory in $BackupDirectories) {
                    $BackupFiles = Get-ChildItem -Path $BackupDirectory -ErrorAction SilentlyContinue -ErrorVariable isEmpty
                    if(!$isEmpty){
                        # Clear Backups older than 7 Days
                        foreach ($BackupFile in $BackupFiles) {
                            $Timespan = New-TimeSpan -days 7
                            $FolderLastWrite = $BackupFile.LastWriteTime
                            $isOlder = ((get-date) - $FolderLastWrite) -gt $Timespan | out-null
                            if ($isOlder) {
                                Remove-Item -Path $BackupFile -Recurse -InformationAction SilentlyContinue -ErrorAction SilentlyContinue
                            }
                        }
                    }
                }
            }
        }
    }
}
process {
    # Call the Backup Scripts for each container
    & "$PSScriptRoot\Octopus Container Automation\OctopusBackup.ps1"  -RootBackupLocation "$DockerRootDir\$OctopusProjectName\Backups" `
                                                                      -OctopusSQLContainerName "$OctopusProjectName`_sql_1" `
                                                                      -OctopusWEBContainerName "$OctopusProjectName`_web_1"
    & "$PSScriptRoot\Wordpress Container Automation\WordpressBackup.ps1"  -RootBackupLocation "$DockerRootDir\$WordpressProjectName\Backups" `
                                                                          -WordpressDBContainerName "$WordpressProjectName`_sql_1" `
                                                                          -WordpressWEBContainerName "$WordpressProjectName`_web_1"
}