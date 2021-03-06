SYN_PROJECT_ID=syn26232086
CONTAINER_NAME=ki-compute
IMAGE_NAME=docker.synapse.org/$(SYN_PROJECT_ID)/$(CONTAINER_NAME)
VOLUME_NAME=$(CONTAINER_NAME)-home-root

# Build the docker image.
.PHONY: build
build:
	sudo docker build --tag $(IMAGE_NAME) --tag $(CONTAINER_NAME) .


# Run the image in the background (with SSH port forwarding).
.PHONY: run
run:
	sudo docker run --tty --detach --volume $(VOLUME_NAME):/root -p 2222:22 --name $(CONTAINER_NAME) $(IMAGE_NAME)


# Connect to the container with a shell.
.PHONY: connect
connect:
	sudo docker exec --interactive --tty --workdir /root $(CONTAINER_NAME) /bin/bash


# List volumes.
.PHONY: list_volumes
list_volumes:
	sudo docker volume ls


# Inspect the container's volume.
.PHONY: inspect_volume
inspect_volume:
	sudo docker volume inspect $(VOLUME_NAME)

# List all images.
.PHONY: list_images
list_images:
	sudo docker images -a


# Delete the image from Docker.
.PHONY: rm_image
rm_image:
	sudo docker image rm $(IMAGE_NAME)


# List all running containers.
.PHONY: ps
ps:
	sudo docker ps -a


# Start a stopped container.
.PHONY: start
start:
	sudo docker start $(CONTAINER_NAME)


# Stop a running container.
.PHONY: stop
stop:
	sudo docker stop $(CONTAINER_NAME)


# Delete the container from Docker.
.PHONY: rm_container
rm_container:
	sudo docker rm $(CONTAINER_NAME)


# Pull the image from Synapse.
.PHONY: pull
pull:
	sudo docker login docker.synapse.org
	sudo docker pull $(IMAGE_NAME)


# Build and publish the container to Synapse.
.PHONY: push
push: build
	sudo docker login docker.synapse.org
	sudo docker push $(IMAGE_NAME)


# Install and configure the base packages for the Notebook instance.
.PHONY: install_notebook
install_notebook:
	./notebook_install.sh 2>&1 | tee notebook_install.log


# Install and configure R for the Notebook instance.
.PHONY: install_notebook_r
install_notebook_r:
	./notebook_install_r.sh 2>&1 | tee notebook_install_r.log
