
IMAGE_NAME = etapa2_img
CONTAINER_NAME = etapa2_container

.PHONY: all start-docker build run clean

all: start-docker build run

start-docker:
	sudo systemctl start docker

build: clean
	docker build -t $(IMAGE_NAME) .

run: build
	docker run -it --name $(CONTAINER_NAME) $(IMAGE_NAME)

clean:
	docker stop $(CONTAINER_NAME) || true
	docker rm $(CONTAINER_NAME) || true
	docker rmi $(IMAGE_NAME) || true
