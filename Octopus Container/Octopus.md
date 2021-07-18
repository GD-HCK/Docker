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
1. ## Backup Container
    1. #### Show a list of containers and the IDs
        docker ps
    2. #### Export container & volumes to a file
        #### Syntax: docker export -o path_to_location\zip_file_name.tar Container_Name
        #### Remember to compress the below files using 7zip, the -o switch saved the output to a file
        docker export -o C:\test\octopus_db.tar octopus_db_1
        docker export -o C:\test\octopus_web.tar octopus_octopus-server_1

2. ## Import Containers (will appear as images)
    #### Syntax: docker import <path_to_tar_file> <container_name:tag>
    docker import C:\test\octopus_db.tar gdhck/octopus_db:latest
    docker import C:\test\octopus_web.tar gdhck/octopus_web:latest

3. ## Restore The Docker Composed Container
    #### Amend the .env file to include the newly imported containers (will appear as images)
    docker-compose --project-name Octopus --env-file "Full_Path_To_File\octopus.env" up -d

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