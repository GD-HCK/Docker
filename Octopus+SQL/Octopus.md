# OctopusContainer

# Initial Setup
### docker run --interactive --detach --name OctopusDeploy --publish 8080:8080 --env ACCEPT_EULA="Y" --env DB_CONNECTION_STRING="..." octopusdeploy/octopusdeploy:2021.1.7508
### amend the .env file to use the mcr.microsoft.com/mssql/server:2019-latest image
docker-compose --project-name Octopus --env-file "Full_Path_To_File\octopus.env" up -d

# If Changing Image Filesystem Content, You Need Only A Backup Of The Container
## Backing up container to Dock Hub
## Create Image From Container
#### docker db_container_name backup_container_name:tag
docker commit octopus_db_1 octopus_db:18072021

## Push Image To Docker Hub. If Using MFA, Create An Access Token At [Docker Security Settings](https://hub.docker.com/settings/security)
docker login -u username

## Create Tag For Image
#### docker tag iamge_id your_docker_user/image_name:tag
docker images # this shows a list of images and the IDs
docker tag 258a147eb1c2 gdhck/octopus_db:18072021

## Push Image To Docker Registry (Or Docker Hub)
#### docker push your_docker_user/image_name:tag
docker push gdhck/octopus_db:18072021

## Remove Obsolete Images (i.e. backup just created)
#### docker rmi image_name_or_id
docker images #this shows a list of images and the IDs
docker rmi 258a147eb1c2

## For Subsequent Restores
#### Amend the .env file to use the octopus_db image just pushed and then run
docker-compose --project-name Octopus --env-file .\octopus.env up -d

## Backing up image from container to File
docker ps # this shows a list of containers and the IDs
Set-Location -Path Path_to_location
#### docker save -o zip_file_name.tar Container_Name # export container + volumes
#### Remember to compress the below files using 7zip, the -o switch saved the output to a file
docker export -o octopus_container.tar octopus

# BACKUP CONTAINER, IMAGE AND VOLUMES FOR DISASTER RECOVERY
## Backup Image And Volume
docker ps # this shows a list of containers and the IDs
Set-Location -Path Path_to_location
#### docker export -o zip_file_name.tar Container_Name # export container + volumes
#### Remember to compress the below files using 7zip, the -o switch saved the output to a file
docker export -o octopus_container.tar octopus_db_1
docker export -o octopus_container.tar octopus_octopus-server_1

## Import Container
#### docker load -i path_to_file
docker load -i .\octopus_container.tar

## Restore The Docker Composed Container
#### Since the composed containered images are already configured, we will run the compose command excluding the .env file
docker-compose --project-name Octopus

## Check Container Resource Utilisation
docker stats

## Troubloshooting
#### check if there are existing images volumes preventing octopus to work properly
docker volume ls -f dangling=true # List dangling volumes
#### delete unnecessary volume
docker volume rm $(docker volume ls -f dangling=true -q) # Remove dangling volumes
#### Example of volumes created by Octopus
d790ca76f11adce6a72523e1e88c62efd6c25d1e602092a8a55d0871c839be03
faf5b8014dc9115828dceffaad77cc5bc8741e10d68da1e6f169a409fbb2f070
octopus_artifacts
octopus_cache
octopus_import
octopus_repository
octopus_sqlvolume
octopus_taskLogs