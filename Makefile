APP_NAME			:= hello-app
APP_DOCKERFILE_PATH := ./hello-logger/
NETWORK_NAME 		:= logger-network

start: create-network create-volume start-app start-vector start-grafana start-elasticsearch

clean:
	-podman rm -f grafana elasticsearch $(APP_NAME) vector || true
	-podman network rm -f $(NETWORK_NAME) || true
	-podman volume rm -f hello-logger-logs || true

create-network:
	@podman network exists $(NETWORK_NAME) || podman network create $(NETWORK_NAME)

start-app: build-app
	podman run -d --replace --name $(APP_NAME) \
		--net $(NETWORK_NAME) \
		-v hello-logger-logs:/logs:rw \
		-p 8080:8080 \
		localhost/$(APP_NAME):latest

build-app:
	podman build -t $(APP_NAME) $(APP_DOCKERFILE_PATH)

create-volume:
	podman volume create hello-logger-logs

start-vector: 
	podman start vector || podman run -d --replace --name vector \
		--net $(NETWORK_NAME) \
		-v $(PWD)/vector.yaml:/etc/vector/vector.yaml:ro \
		-v hello-logger-logs:/logs:ro \
		docker.io/timberio/vector:latest-alpine \
		-c /etc/vector/vector.yaml

start-grafana:
	podman run -d --replace --name grafana \
		--net $(NETWORK_NAME) \
		--user root \
		-p 3000:3000 \
		docker.io/grafana/grafana:latest 

start-elasticsearch:
	podman run -d --replace --name elasticsearch \
		--net $(NETWORK_NAME) \
		--user 1000:1000 \
		-p 9200:9200 -p 9300:9300 \
		-e "discovery.type=single-node" \
		-e "xpack.security.enabled=false" \
		-e "ES_JAVA_OPTS=-Xms512m -Xmx512m" --memory=1g \
		docker.io/library/elasticsearch:9.0.2

