IMAGE_NAME=ki-compute
DOCKER_HUB_ID=TODO-ADD-THIS
TAG=ubuntu.21.04


# Build the docker image.
.PHONY: build
build:
	sudo docker build --tag $(IMAGE_NAME):$(TAG) .


# Run the image in the background.
.PHONY: run
run:
	sudo docker run --tty --detach --name $(IMAGE_NAME) $(IMAGE_NAME):$(TAG)


# Connect to the container with a shell.
.PHONY: connect
connect:
	sudo docker exec -it $(IMAGE_NAME) /bin/bash


# List all running containers.
.PHONY: ps
ps:
	sudo docker ps -a


# Stop the running container.
.PHONY: start
start:
	sudo docker start $(IMAGE_NAME)


# Stop the running container.
.PHONY: stop
stop:
	sudo docker stop $(IMAGE_NAME)


# Delete the container from Docker.
.PHONY: rm
rm:
	sudo docker rm $(IMAGE_NAME)


# Build and publish the container to Docker Hub.
.PHONY: push
push: build
	sudo docker login -u $(DOCKER_HUB_ID)
	sudo docker tag $(IMAGE_NAME):$(TAG) $(DOCKER_HUB_ID)/$(IMAGE_NAME):$(TAG)
	sudo docker push $(DOCKER_HUB_ID)/$(IMAGE_NAME):$(TAG)
