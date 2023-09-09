build: 
	docker build -t local/ece391_docker -f ./Dockerfile .

build-arm: 
	docker buildx build -t local/ece391_docker_arm --platform linux/arm64/v8 -f ./Dockerfile.arm64v8 .

build-release:
	docker build -t averagefossenjoyer/ece391_docker:latest-amd64 -f ./Dockerfile .

build-test:
	docker buildx build -t local/ece391_docker_test --platform linux/arm64/v8 -f ./Dockerfile.test .

run: 
	docker run -it --rm -p 8080:8080 -p 6901:6901 -p 37391:37391 local/ece391_docker

run-arm:
	docker run -it --rm -p 8080:8080 -p 6901:6901 -p 37391:37391 --platform linux/arm64/v8 local/ece391_docker_arm

run-release:
	docker run -it --rm -p 8080:8080 -p 6901:6901 -p 37391:37391 averagefossenjoyer/ece391_docker:latest-amd64

run-test:
	docker run -it --rm -p 8080:8080 -p 6901:6901 -p 37391:37391 --platform linux/arm64/v8 local/ece391_docker_test

setup-static:
	docker run --rm --privileged multiarch/qemu-user-static --reset -p yes --credential yes