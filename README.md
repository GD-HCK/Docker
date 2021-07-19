#                                                                   Docker

# Docker basic commands
* #### Syntax - detached (Background run): 
  #### $ docker run --detach --name <container_name> --publish 8080:8080 --env <required_environment_variable>  <image_name:tag>
    $ docker run -d --name ubuntu -p 8080:80 ubuntu:latest 
* #### Syntax - interactive (Foreground run): 
  #### $ docker run --interactive --name <container_name> --publish 8080:8080 --env <required_environment_variable>  <image_name:tag>
    -> Use ctrl+P+Q to exit the foreground console and leave the container running in the background <-
    $ docker run -it --name ubuntu -p 8080:80 ubuntu:latest

# Initial Setup
Check each folder's .md file for instructions

1. [Octopus.md](./Octopus%20Container/Octopus.md)
2. [Automation.md](./Automation/Automation.md)
3. [Compose.md](./Compose/Compose.md) [In Progress]
