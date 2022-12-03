SLUG=prando
POSTGRES_DOCKER_IMAGE=docker.io/library/postgres:15-alpine
CONTAINER_NAME=$(SLUG)-postgres
USERNAME=64a712d6dec7949739e9f46a14f83075
PASSWORD=53e8c1c4e9b7af6ab75e1498912f9ab3
DATABASE=$(SLUG)db

pull:
	@podman pull $(POSTGRES_DOCKER_IMAGE)

run:
	-@make pull
	-@make __rm
	@seq 45 | xargs -I{} echo "🚨 $(CONTAINER_NAME) 🔴 STOPPED ⏰ $$(date)"
	@podman run --name $(CONTAINER_NAME) --restart unless-stopped \
		-e POSTGRES_USER=$(USERNAME) \
		-e POSTGRES_PASSWORD=$(PASSWORD) \
		-e POSTGRES_DB=$(DATABASE) \
		-e PGDATA=/srv/postgres/database \
		-v "$(SLUG)-postgres-bin:/usr/local/bin" \
		-v "$(PWD):/srv/postgres:z" \
		-w /srv/postgres \
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

log:
	@podman logs -f $(CONTAINER_NAME)
cli:
	@podman exec -it $(CONTAINER_NAME) psql $(DATABASE) $(USERNAME)
