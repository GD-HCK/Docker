# OctopusContainer

# Initial Setup
  #### Amend the .env file to use the mcr.microsoft.com/mssql/server:2019-latest image
  -> docker-compose --project-name Octopus --env-file "Full_Path_To_File\octopus.env" up -d

# Steps to backup Container's filesystem only -- no volumes
 1. ## Backing up container to Dock Hub
    1. ### Create Image From Container
        #### Syntax: docker db_container_name backup_container_name:tag
        docker commit octopus_db_1 octopus_db:18072021

    2. ### Push Image To Docker Hub. If Using MFA, Create An Access Token At [Docker Security Settings](https://hub.docker.com/settings/security)
        docker login -u username

    3. ### Create Tag For Image
        #### Syntax: docker tag iamge_id your_docker_user/image_name:tag
        docker images # this shows a list of images and the IDs
        docker tag 258a147eb1c2 gdhck/octopus_db:18072021

    4. ### Push Image To Docker Registry (Or Docker Hub)
        #### Syntax: docker push your_docker_user/image_name:tag
        docker push gdhck/octopus_db:18072021

    5. ### Remove Obsolete Images (i.e. backup just created)
        1.  #### Show a list of images and the IDs
            docker images
        2.  #### Remove images
            #### Syntax: docker rmi image_name_or_id
            docker rmi 258a147eb1c2

    6. ### Image Restore
        #### Amend the .env file to use the octopus_db image just pushed (i.e. SQL_IMAGE=gdhck/octopusserver:latest) and then run
        docker-compose --project-name Octopus --env-file .\octopus.env up -d

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
1. ## Backup Container volumes files
    1. #### Show a list of containers and the IDs
        docker ps
    2. #### Export container's data to an archive file
        #### Syntax: docker run --rm --volumes-from <container_name> -v <Local_Backup_Folder>:<container_mounted_folder> ubuntu bash -c "cd <folder_to_backup> && tar cvf /<container_mounted_folder>/<archive_name>.tar ."
        #### Remember to compress the files using 7zip
        docker run --rm --volumes-from octopus_db_1 -v C:\Docker_Volumes_backups:/backup ubuntu bash -c "cd /var/opt/mssql/data && tar cvf /backup/octopus_dbs.tar ."

2. ## Restore The Docker Composed Container
    1. #### Create the composed container from scratch
        docker-compose --project-name Octopus --env-file "Full_Path_To_File\octopus.env" up -d
    2. #### Overwrite the content of /var/opt/mssql with the one coming from the new volume
        1. #### Stop the composed container
        2. #### Import data back in the volumes
            docker run --rm --volumes-from octopus_db_1 -v C:\Docker_Volumes_backups:/backup ubuntu bash -c "rm -rf /var/opt/mssql/data/* && cd /var/opt/mssql/data && tar xvf /backup/octopus_dbs.tar ."
        3. #### Start the composed container
             1. Start SQL container
             2. Start WEB container 
       

# Check Container Resource Utilisation
docker stats

# Troubloshooting
#### check if there are existing images volumes preventing octopus to work properly
docker volume ls -f dangling=true # List dangling volumes
#### delete dangling volumes
docker volume rm $(docker volume ls -f dangling=true -q)
#### Example of volumes created by Octopus
d790ca76f11adce6a72523e1e88c62efd6c25d1e602092a8a55d0871c839be03
faf5b8014dc9115828dceffaad77cc5bc8741e10d68da1e6f169a409fbb2f070
octopus_artifacts
octopus_cache
octopus_import
octopus_repository
octopus_sqlvolume
octopus_taskLogs