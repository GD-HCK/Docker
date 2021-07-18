# OctopusContainer

# Initial Setup
#docker run --interactive --detach --name OctopusDeploy --publish 8080:8080 --env ACCEPT_EULA="Y" --env DB_CONNECTION_STRING="..." octopusdeploy/octopusdeploy:2021.1.7508
#amend the .env file to use the mcr.microsoft.com/mssql/server:2019-latest image
docker-compose --project-name Octopus --env-file "Full_Path_To_File\octopus.env" up -d

# Create Image From Container
#docker db_container_name backup_container_name:tag
docker commit octopus_db_1 octopus_db:18072021

# Push Image To Docker Hub. If Using MFA, Create An Access Token At https://hub.docker.com/settings/security
docker login -u username

# Create Tag For Image
#docker tag iamge_id your_docker_user/image_name:tag
docker images # this shows a list of images and the IDs
docker tag 258a147eb1c2 gdhck/octopus_db:18072021

# Push Image To Docker Registry (Or Docker Hub)
#docker push your_docker_user/image_name:tag
docker push gdhck/octopus_db:18072021

# Remove Obsolete Images (i.e. backup just created)
#docker rmi image_name_or_id
docker images #this shows a list of images and the IDs
docker rmi 258a147eb1c2

# For Subsequent Restores
#amend the .env file to use the octopus_db image just pushed and then run
docker-compose --project-name Octopus --env-file .\octopus.env up -d

# Check Container Resource Utilisation
docker stats
