APP_NAME := hello-app
APP_DOCKERFILE_PATH = ./hello-logger/
NETWORK_NAME := logger-network

start: create-network start-elasticsearch start-grafana start-app start-vector

clean:
	-podman rm -f grafana elasticsearch $(APP_NAME) vector || true
	-podman network rm $(NETWORK_NAME) || true

create-network:
	@podman network exists $(NETWORK_NAME) || podman network create $(NETWORK_NAME)

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

start-app:
	podman run -d --replace --name $(APP_NAME) \
		--net $(NETWORK_NAME) \
		-p 8080:8080 \
		--log-driver k8s-file \
		localhost/$(APP_NAME):latest

build-app:
	podman build -t $(APP_NAME) $(APP_DOCKERFILE_PATH)

start-vector: 
	$(eval APP_ID := $(shell podman inspect --format '{{.Id}}' $(APP_NAME)))
	$(eval LOG_PATH := $(HOME)/.local/share/containers/storage/overlay-containers/$(APP_ID)/userdata/ctr.log)

	@if [ ! -f "$(LOG_PATH)" ]; then \
		echo "❌ Log file not found: $(LOG_PATH)"; \
		echo "   Make sure $(APP_NAME) is running and uses --log-driver=k8s-file"; \
		exit 1; \
	fi

	podman start vector || podman run -d --name vector \
		--net $(NETWORK_NAME) \
		-v $(PWD)/vector.yaml:/etc/vector/vector.yaml:ro \
		-v $(LOG_PATH):/logs/ctr.log:ro \
		docker.io/timberio/vector:latest-alpine \
		-c /etc/vector/vector.yaml

