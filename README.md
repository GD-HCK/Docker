# Readme

## Keep your docker up-to-date
```powershell
# Run the below as administrator in Powershell 5.1 only for windows server
PS> install-module DockerProvider -Force 
PS> install-package Docker -ProviderName DockerProvider -Force
```

## Docker basic commands
* #### Detached (Background run):
    ```powershell
    # Syntax:
    PS> docker run --detach --name <container_name> --publish 8080:8080 --env <required_environment_variable>  <image_name:tag>
    # Example:
    PS> docker run -d --name ubuntu -p 8080:80 ubuntu:latest
    ``` 
* #### Interactive (Foreground run):
    ```powershell
    # Syntax:
    PS> docker run --interactive --name <container_name> --publish 8080:8080 --env <required_environment_variable>  <image_name:tag>
    # Use Ctrl+P+Q to exit the foreground console and leave the container running in the background
    # Example:
    PS> docker run -it --name ubuntu -p 8080:80 ubuntu:latest
    ```

## Docker Topics
`Check each folder's .md file for instructions`

1. [Octopus.md](./Octopus%20Container/Octopus.md)
2. [Automation.md](./Automation/Automation.md)
3. [Compose.md](./Compose/Compose.md) [In Progress]
