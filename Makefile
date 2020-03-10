default: docker_build_debian

DOCKER_IMAGE ?= unicornsquad/k8s-maven
GIT_BRANCH ?= `git rev-parse --abbrev-ref HEAD`

ifeq ($(GIT_BRANCH), master)
	DOCKER_TAG = latest
else
	DOCKER_TAG = $(GIT_BRANCH)
endif

docker_build_debian:
	docker build -f Dockerfile.debian -t $(DOCKER_IMAGE):$(DOCKER_TAG)-graal-debian .
docker_build_centos:
	docker build -t $(DOCKER_IMAGE):$(DOCKER_TAG)-graal-centos .

	  
docker_push_debian:
	# Push to DockerHub
	docker push $(DOCKER_IMAGE):$(DOCKER_TAG)-graal-debian
docker_push_centos:
	# Push to DockerHub
	docker push $(DOCKER_IMAGE):$(DOCKER_TAG)-graal-centos

test_debian:
	docker run $(DOCKER_IMAGE):$(DOCKER_TAG)-graal-debian mvn --version

test_centos:
	docker run $(DOCKER_IMAGE):$(DOCKER_TAG)-graal-centos mvn --version