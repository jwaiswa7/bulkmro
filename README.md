# Installing Elasticsearch on Ubuntu
sudo apt install openjdk-11-jre-headless

# Instructions
#### Ubuntu
https://www.elastic.co/guide/en/elasticsearch/reference/current/deb.html

#### Windows
https://www.elastic.co/guide/en/elasticsearch/reference/current/windows.html

# To configure Elasticsearch to start automatically when the system boots up, run the following commands:
#### Ubuntu
sudo /bin/systemctl daemon-reload
sudo /bin/systemctl enable elasticsearch.service

#### Windows
Install it as a service; will auto-start when Windows boots up.

# Elasticsearch can be started and stopped as follows:
#### Ubuntu
sudo systemctl start elasticsearch.service
sudo systemctl stop elasticsearch.service

#### Windows
Restart service using the service manager.

# To browse Elasticsearch (OPTIONAL)
sudo snap install docker
docker run -p 1358:1358 -d appbaseio/dejavu
open http://localhost:1358/