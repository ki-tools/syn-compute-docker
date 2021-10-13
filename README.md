# Synapse Ki Compute Docker Image

## Image Location
- [https://www.synapse.org/#!Synapse:syn26232086/docker]([https://www.synapse.org/#!Synapse:syn26232086/docker)

## Sage Compute Environment Usage

### Notebook

- Connect to the RStudio web interface from the AWS console.
- Clone the repo so you can use the Make commands and scripts: `git clone https://github.com/ki-tools/syn-compute-docker.git`
- Go into the repo directory: `cd syn-compute-docker`
- Install and configure the base packages: `make install_notebook`

### Docker
- SSH into your EC2 compute instance.
- Clone the repo so you can use the Make commands and scripts: `git clone https://github.com/ki-tools/syn-compute-docker.git`
- Go into the repo directory: `cd syn-compute-docker`
- Pull the docker image from Synapse: `make pull`
- Start and run the container: `make run`
- Connect to a shell in the running container: `make connect`

## Dev Usage

- Build the docker image: `make build`
- Start the container: `make run`
- Connect to the container: `make connect`
- Stop the container: `make stop`

See [Makefile](Makefile) for all commands

See [Dockerfile](Dockerfile) for installed packages.
