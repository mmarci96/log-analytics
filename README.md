# Overview
Logger made with vektor, elasticsearch and grafana.

---

## Requirements
To use the application you need to have docker and podman installed on your
system

---

## Quick start
1. Start the app with default values:
```bash
make start
```

2. Open the browser on```http://localhost:3000``` to configure Grafana. Default login 
    username: admin, password: admin. 

3. On Grafana ui navigate to ```Connections->Add new connection``` on the side panel
   and choose ```Elasticsearch -> Add new data source``` from the avaliable options.

4. Set ```Connection - URL``` to ```http://elasticsearch:9200```. Index name to
   ```vector-*``` and ```Time field name``` to ```timestamp```.

5. If you see ```Elasticsearch data source is healthy.``` either build
   a dashboard or monitor the logs in the ```Explore view```.

---
