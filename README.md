# Installing Elasticsearch on Ubuntu
sudo apt install openjdk-11-jre-headless

# Instructions
https://www.elastic.co/guide/en/elasticsearch/reference/current/deb.html

# To configure Elasticsearch to start automatically when the system boots up, run the following commands:
sudo /bin/systemctl daemon-reload
sudo /bin/systemctl enable elasticsearch.service

# Elasticsearch can be started and stopped as follows:
sudo systemctl start elasticsearch.service
sudo systemctl stop elasticsearch.service

# To browse Elasticsearch (OPTIONAL)
sudo snap install docker
docker run -p 1358:1358 -d appbaseio/dejavu
open http://localhost:1358/

#Run Chewy
overseers/dashboard/chewy