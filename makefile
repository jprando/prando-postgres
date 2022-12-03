SLUG=prando

POSTGRES_DOCKER_IMAGE=docker.io/library/postgres:15-alpine
CONTAINER_NAME=$(SLUG)-postgres
USERNAME=64a712d6dec7949739e9f46a14f83075
PASSWORD=53e8c1c4e9b7af6ab75e1498912f9ab3
DATABASE=$(SLUG)db

run:
	-@make pull
	-@make __rm
	@seq 45 | xargs -I{} echo "🚨 $(CONTAINER_NAME) 🔴 STOPPED ⏰ $$(date)"
	@podman run --name $(CONTAINER_NAME) --restart unless-stopped \
		-e POSTGRES_USER=$(USERNAME) \
		-e POSTGRES_PASSWORD=$(PASSWORD) \
		-e POSTGRES_DB=$(DATABASE) \
		-e PGDATA=/srv/postgres/pg15/database \
		-v "$(PWD):/srv/postgres/pg15:z" \
		-w /srv/postgres/pg15 \
		-p 5432:5432 \
		--health-cmd "psql -h127.0.0.1 -p5432 -U$(USERNAME) -l" \
		--health-interval "20s" \
		--health-retries 3 \
		--health-timeout "10s" \
		--health-on-failure "restart" \
		--health-start-period "10s" \
	-d $(POSTGRES_DOCKER_IMAGE)
	@make log

start:
	@podman start $(CONTAINER_NAME)
stop:
	@podman stop $(CONTAINER_NAME)
__rm:
	-@make stop
	@podman rm $(CONTAINER_NAME)

cli:
	@make psql
psql:
	podman exec -it $(CONTAINER_NAME) /usr/local/bin/psql -h/var/run/postgresql $(DATABASE) $(USERNAME)
bash:
	@podman exec -it $(CONTAINER_NAME) bash

pull:
	@podman pull $(POSTGRES_DOCKER_IMAGE)
log:
	@podman logs -f $(CONTAINER_NAME)
