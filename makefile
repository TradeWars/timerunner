VERSION := $(shell cat VERSION)
NEW_VERSION := $(shell date -u +%yw%W.%w.%H)
LDFLAGS := -ldflags "-X github.com/TradeWars/warehouse/server.version=$(VERSION)"
-include .env


# -
# Local
# -

next:
	echo $(NEW_VERSION) > VERSION

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

build: static
	docker build -t southclaws/tw-warehouse:$(VERSION) .

push:
	docker push southclaws/tw-warehouse:$(VERSION)

run:
	docker run \
		--name warehouse \
		--env-file .env \
		southclaws/tw-warehouse:$(VERSION)
