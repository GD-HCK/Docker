[CmdletBinding()]
param (
    [Parameter()]
    [string]
    [ValidateNotNullOrEmpty()]
    $DockerRootDir
)
begin {
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
    & '..\Automation\Octopus Container Automation\OctopusBackup.ps1' -RootBackupLocation "$DockerRootDir\Octopus\Backups" -OctopusSQLContainerName octopus_sql_1 -OctopusWEBContainerName octopus_web_1
    & '..\Automation\Wordpress Container Automation\WordpressBackup.ps1' -RootBackupLocation "$DockerRootDir\Wordpress\Backups" -WordpressDBContainerName wp_sql_1 -WordpressWEBContainerName wp_web_1
}