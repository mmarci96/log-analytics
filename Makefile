# Configuration
NETWORK_NAME := logger-network
ELASTIC_PORTS := -p 9200:9200 -p 9300:9300
GRAFANA_PORT := -p 3000:3000
APP_NAME := hello-app
APP_PORT := 8080
APP_IMAGE_NAME := hello-logger

start-app: start-elastic start-grafana start-vector
	@echo "Starting app: $(APP_NAME) - from image: $(APP_IMAGE_NAME)..."
	- podman start $(APP_NAME) || podman run -d --name $(APP_NAME) \
		--net $(NETWORK_NAME) \
		-p $(APP_PORT):$(APP_PORT) \
		--log-driver=journald \
		localhost/hello-logger:latest 

stop-app: 
	@echo "Stopping app: $(APP_NAME)..."
	- podman stop $(APP_NAME)

clean-app: stop-app
	@echo "Removing $(APP_NAME) container..."
	- podman rm $(APP_NAME)

# Start both services
start: start-elastic start-grafana start-vector start-app

# Stop both services
stop: stop-elastic stop-grafana stop-vector stop-app

# Clean both containers and destroy network
clean: clean-elastic clean-grafana clean-vector clean-app destroy-network


start-vector: create-network start-elastic
	@echo "Starting Vector..."
	$(eval APP_ID := $(shell podman inspect --format '{{.Id}}' $(APP_NAME)))

	$(eval LOG_PATH := $(HOME)/.local/share/containers/storage/overlay-containers/$(APP_ID)/userdata/ctr.log)

	- podman start vector || podman run -d --name vector \
		--net $(NETWORK_NAME) \
		-v $(PWD)/vector.yaml:/etc/vector/vector.yaml:ro \
		-v $(LOG_PATH):/logs/ctr.log:ro \
		timberio/vector:latest-alpine \
		-c /etc/vector/vector.yaml

# Stop Vector
stop-vector:
	@echo "Stopping Vector..."
	- podman stop vector

# Remove Vector container
clean-vector: stop-vector
	@echo "Removing Vector container..."
	- podman rm vector

# Create Podman network if it doesn't exist
create-network:
	@echo "Creating network if not exists..."
	- podman network create $(NETWORK_NAME)

# Remove Podman network if exists
destroy-network:
	@echo "Removing network if exists..."
	- podman network rm $(NETWORK_NAME)

# Start Elasticsearch
start-elastic: create-network
	@echo "Starting Elasticsearch..."
	- podman start elasticsearch || podman run -d --name elasticsearch \
		--net $(NETWORK_NAME) \
		$(ELASTIC_PORTS) \
		-e "discovery.type=single-node" \
		-e "xpack.security.enabled=false" \
		-e "ES_JAVA_OPTS=-Xms512m -Xmx512m" \
		--memory=1g \
		docker.io/library/elasticsearch:9.0.2

# Start Grafana
start-grafana: create-network
	@echo "Starting Grafana..."
	- podman start grafana || podman run -d --name=grafana \
		--net $(NETWORK_NAME) \
		$(GRAFANA_PORT) \
		grafana/grafana

# Stop Elasticsearch
stop-elastic:
	@echo "Stopping Elasticsearch..."
	- podman stop elasticsearch

# Stop Grafana
stop-grafana:
	@echo "Stopping Grafana..."
	- podman stop grafana

# Remove Elasticsearch container
clean-elastic: stop-elastic
	@echo "Removing Elasticsearch container..."
	- podman rm elasticsearch

# Remove Grafana container
clean-grafana: stop-grafana
	@echo "Removing Grafana container..."
	- podman rm grafana

# Show help for each Make target with descriptions
help:
	@awk 'BEGIN {FS = ":.*## "; printf "\nUsage:\n  make <target>\n\nTargets:\n"} \
		/^[a-zA-Z0-9_-]+:.*##/ {printf "  %-20s %s\n", $$1, $$2}' $(MAKEFILE_LIST)
