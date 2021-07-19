# OctopusContainer

# Initial Setup
  #### `Amend the .env file to use the mcr.microsoft.com/mssql/server:2019-latest image as the SQL container's baseline`
  #### Create project (composed container)
  ```powershell
  # Syntax: 
  $ docker-compose --project-name <project_name> --env-file <Full_Path_To_File\env_file_name.env> up -d
  # Example:
  $ docker-compose --project-name Octopus --env-file .\octopus.env up -d
  ```
# Steps to backup Container's filesystem only -- no volumes' content
 1. ## Backing up container to Docker Hub
    1. ### Create Image From Container
        ```powershell
        # Syntax: 
        $ docker db_container_name backup_container_name:tag
        # Example:
        $ docker commit octopus_db_1 octopus_db:18072021
        ```

    2. ### Push Image To Docker Hub. 
        #### `If Using MFA, Create An Access Token At [Docker Security Settings](https://hub.docker.com/settings/security)`
        ```powershell
        $ docker login -u username
        ```

    3. ### Create Tag For Image
        ```powershell
        # List images and IDs:
        $ docker images
        # Tagging Syntax: 
        $ docker tag iamge_id your_docker_user/image_name:tag
        # Example:
        $ docker tag 258a147eb1c2 gdhck/octopus_db:18072021
        ```

    4. ### Push Image To Docker Registry (Or Docker Hub)
        ```powershell
        # Syntax: 
        $ docker push your_docker_user/image_name:tag
        # Example:
        $ docker push gdhck/octopus_db:18072021
        ```
    5. ### Remove Obsolete Images (i.e. backup just created)
        ```powershell
        # List images and IDs:
        $ docker images
        # Remove Image Syntax: 
        $ docker rmi image_name_or_id
        # Example:
        $ docker rmi 258a147eb1c2
        ```
    6. ### Image Restore
        #### `Amend the .env file to use the octopus_db image just pushed (i.e. SQL_IMAGE=gdhck/octopusserver:latest) and then run`
        ```powershell
        # Create docker compose:
        PS> docker-compose --project-name Octopus --env-file .\octopus.env up -d
        ```
2. ## Backing up image to File
    1.  #### Show a list of images and the IDs
        docker images
    2.  #### Save Image
        #### Syntax: docker save -o <zip_file_name.tar> <image_name_or_id:tag>
        #### Remember to compress the below files using 7zip, the -o switch saved the output to a file
        docker save -o C:\test\octopus_image.tar octopusdeploy/octopusdeploy:latest
    3.  #### Import Image
        #### Syntax: docker load -i path_to_tar_file
        docker load -i C:\test\octopus_db.tar
        docker load -i C:\test\octopus_web.tar

# Steps to backup Container's filesystem & volumes -- disaster recovery
### There is no way to backup volumes. However, files such as databases, documents and so on can be backed up externally in a .tar archive.
1. ## Backup DB Container volumes files
    1. #### Show a list of containers and the IDs
        docker ps
    2. #### Export container's data to an archive file
        #### Syntax: docker run --rm --volumes-from <container_name> -v <Local_Backup_Folder>:<container_mounted_folder> ubuntu bash -c "cd <folder_to_backup> && tar cvf /<container_mounted_folder>/<archive_name>.tar ."
        #### Remember to compress the files using 7zip
        docker run --rm --volumes-from octopus_db_1 -v C:\Docker_Volumes_backups:/backup ubuntu bash -c "cd /var/opt/mssql/data && tar cvf /backup/octopus_dbs.tar ."

2. ## Backup Web Server Container's file system
    1. #### Show a list of containers and the IDs
        docker ps
    2. #### Export container's data to an archive file
        #### Syntax: docker run --rm --volumes-from <container_name> -v <Local_Backup_Folder>:<container_mounted_folder> ubuntu bash -c "cd <folder_to_backup> && tar cvf /<container_mounted_folder>/<archive_name>.tar ."
        #### Remember to compress the files using 7zip
        #### Backup of 
        1. /repository,
        docker run --rm --volumes-from octopus_octopus-server_1 -v C:\Docker_Volumes_backups:/backup ubuntu bash -c "cd /repository && tar cvf /backup/repository.tar ."
        2. /artifacts,
        docker run --rm --volumes-from octopus_octopus-server_1 -v C:\Docker_Volumes_backups:/backup ubuntu bash -c "cd /artifacts && tar cvf /backup/artifacts.tar ."
        3. /taskLogs,
        docker run --rm --volumes-from octopus_octopus-server_1 -v C:\Docker_Volumes_backups:/backup ubuntu bash -c "cd /taskLogs && tar cvf /backup/taskLogs.tar ."
        4. /cache,
        docker run --rm --volumes-from octopus_octopus-server_1 -v C:\Docker_Volumes_backups:/backup ubuntu bash -c "cd /cache && tar cvf /backup/cache.tar ."
        5. /import,
        docker run --rm --volumes-from octopus_octopus-server_1 -v C:\Docker_Volumes_backups:/backup ubuntu bash -c "cd /import && tar cvf /backup/import.tar ."
        6. /Octopus: //TODO

3. ## Restore The Docker Composed Container
    1. #### Create the composed container from scratch
        docker-compose --project-name Octopus --env-file "Full_Path_To_File\octopus.env" up -d
    2. #### Overwrite the content of /var/opt/mssql with the one coming from the new volume
        1. #### Stop the composed container
        2. #### Import database data back in the volumes
           #### Syntax: docker run --rm --volumes-from <container_name> -v <Local_Backup_Folder>:<container_mounted_folder> ubuntu bash -c "rm -rf /<folder_to_clear>/* && cd <folder_to_clear> && tar xvf /<container_mounted_folder>/<archive_name>.tar ."
            docker run --rm --volumes-from octopus_db_1 -v C:\Docker_Volumes_backups:/backup ubuntu bash -c "rm -rf /var/opt/mssql/data/* && cd /var/opt/mssql/data && tar xvf /backup/octopus_dbs.tar ."
        3. #### Import web file system's data back in the volumes
            #### Syntax: docker run --rm --volumes-from <container_name> -v <Local_Backup_Folder>:<container_mounted_folder> ubuntu bash -c "rm -rf /<folder_to_clear>/* && cd <folder_to_clear> && tar xvf /<container_mounted_folder>/<archive_name>.tar ."
            #### Remember to compress the files using 7zip
            #### Backup of 
            1. /repository,
            docker run --rm --volumes-from octopus_octopus-server_1 -v C:\Docker_Volumes_backups:/backup ubuntu bash -c "rm -rf /repository/* && cd /repository && tar xvf /backup/repository.tar ."
            2. /artifacts,
            docker run --rm --volumes-from octopus_octopus-server_1 -v C:\Docker_Volumes_backups:/backup ubuntu bash -c "rm -rf /artifacts/* && cd /artifacts && tar xvf /backup/artifacts.tar ."
            3. /taskLogs,
            docker run --rm --volumes-from octopus_octopus-server_1 -v C:\Docker_Volumes_backups:/backup ubuntu bash -c "rm -rf /taskLogs/* && cd /taskLogs && tar xvf /backup/taskLogs.tar ."
            4. /cache,
            docker run --rm --volumes-from octopus_octopus-server_1 -v C:\Docker_Volumes_backups:/backup ubuntu bash -c "rm -rf /cache/* && cd /cache && tar xvf /backup/cache.tar ."
            5. /import,
            docker run --rm --volumes-from octopus_octopus-server_1 -v C:\Docker_Volumes_backups:/backup ubuntu bash -c "rm -rf /import/* && cd /import && tar xvf /backup/import.tar ."
            6. /Octopus: //TODO

        3. #### Start the composed container
             * Start SQL container
             * Start WEB container

# Perform Automated Tasks
Checkout the task automation scripts for octopus containers within [Automation](../Automation)
       

# Check Container Resource Utilisation
docker stats

# Troubloshooting
1. #### check if there are existing images volumes preventing octopus to work properly
    docker volume ls -f dangling=true # List dangling volumes
2. #### delete dangling volumes
    docker volume rm $(docker volume ls -f dangling=true -q)
    #### Example of volumes created by Octopus
    * d790ca76f11adce6a72523e1e88c62efd6c25d1e602092a8a55d0871c839be03
    * faf5b8014dc9115828dceffaad77cc5bc8741e10d68da1e6f169a409fbb2f070
    * octopus_artifacts
    * octopus_cache
    * octopus_import
    * octopus_repository
    * octopus_sqlvolume
    * octopus_taskLogs

3. #### Start interactive shell with running container (works only with debian/linux/ubuntu based containers)
    #### Syntax: docker exec -it <container_id> /bin/bash
    docker exec -it b4924f4768bd /bin/bash