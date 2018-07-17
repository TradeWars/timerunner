# -
# `VERSION` contains the current version - aka the last tagged version of the
# repository. It's stored in a file named `VERSION` and should only ever be
# updated by running `make next`.
#
# `NEXT_VERSION` contains the next version number which is generated using the
# date and contains: the two-digit year, the week number, day of week and hour.
#
# `next` updates the `VERSION` file with the `NEXT_VERSION` value which
# signifies a new version has been reached and will be released.
# `release` applies the `VERSION` to the repository by tagging the current
# repository state with the `VERSION` value and then pushes the repo to the
# git server. It's important that your `.git/config` file contains the necessary
# `push` fields under the `origin` remote (or whatever remote you use).
# -

VERSION := $(shell cat VERSION)
NEXT_VERSION := $(shell date -u +%yw%W.%w.%H)

next:
	echo $(NEXT_VERSION) > VERSION

release:
	# re-tag this commit
	-git tag -d $(VERSION)
	git tag $(VERSION)
	# note: this requires that the configuration contains:
	# [remote "origin"]
	#     url = ...
	#     fetch = +refs/heads/*:refs/remotes/origin/*
	#     push = +refs/heads/*
	#     push = +refs/tags/*
	# in order to force tags to push alongside everything else.
	git push


# -
# Local
# -

-include .env

local:
	cargo run

# -
# Testing
# -

databases:
	-docker stop timescaledb
	-docker rm timescaledb
	-docker stop pgadmin
	-docker rm pgadmin
	docker run \
		--name timescaledb \
		--publish 5432:5432 \
		--detach \
		-e POSTGRES_USER=default \
		-e POSTGRES_PASSWORD=default \
		timescale/timescaledb:0.10.0-pg9.6
	sleep 5
	docker run \
		--name pgadmin \
		--publish 8082:80 \
		-e "PGADMIN_DEFAULT_EMAIL=u@d.co" \
		-e "PGADMIN_DEFAULT_PASSWORD=password" \
		--link=timescaledb \
		--detach \
		dpage/pgadmin4

# -
# Docker
# -

build:
	docker build -t southclaws/tw-timerunner:$(VERSION) .

push:
	docker push southclaws/tw-timerunner:$(VERSION)

run:
	docker run \
		--name timerunner \
		--env-file .env \
		southclaws/tw-timerunner:$(VERSION)
