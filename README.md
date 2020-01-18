# Installing required softwares like Ruby, Rails and PostgreSQL 
Follow the below instructions and commands for basic setup to get the sprint running in development environment. Along with that sign up on bit Bucket and Heroku with official credentials.

#### stable RVM 
curl -sSL https://get.rvm.io | bash -s stable
#### ruby (for version 2.5.3)
rvm install 2.5.3
rvm use 2.5.3

#### ruby gem
sudo gem update

#### ruby bundler
sudo gem install bundler

#### rails (for version => 5)
sudo gem install rails -v 5.2.1

#### yarn
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt-get update && sudo apt-get install yarn
yarn install

#### postgres and pgAdmin
sudo apt install postgresql-10 pgadmin4

Start the service with sudo service postgresql restart
#### Heroku CLI 
sudo snap install --classic heroku

# Installing Elasticsearch on Ubuntu
sudo apt install openjdk-11-jre-headless

# Instructions
#### Ubuntu
https://www.elastic.co/guide/en/elasticsearch/reference/current/deb.html

#### Windows
https://www.java.com/en/download/
https://www.elastic.co/guide/en/elasticsearch/reference/current/windows.html

# To configure Elastic Search to start automatically when the system boots up, run the following commands
#### Ubuntu
sudo /bin/systemctl daemon-reload
sudo /bin/systemctl enable elasticsearch.service

#### Windows
Install it as a service; will auto-start when Windows boots up.

# Elastic Search can be started and stopped as follows
#### Ubuntu
sudo systemctl start elasticsearch.service
sudo systemctl stop elasticsearch.service

#### Windows
Restart service using the service manager.

# To browse Elastic Search (OPTIONAL)
sudo snap install docker
docker run -p 1358:1358 -d appbaseio/dejavu
open http://localhost:1358/

# Run Chewy
overseers/dashboard/chewy

# yarn file inside bin
#!/usr/bin/env ruby
APP_ROOT = File.expand_path('..', __dir__)
Dir.chdir(APP_ROOT) do
  begin
    exec "yarnpkg", *ARGV
  rescue Errno::ENOENT
    $stderr.puts "Yarn executable was not detected in the system."
    $stderr.puts "Download Yarn at https://yarnpkg.com/en/docs/install"
    exit 1
  end
end

- Disable auto-increment index
- Perform migration
- Run calculations in clock process


# Restoring PG Admin database
## Windows
"<PATH TO POSTGRESQL's BIN FOLDER>\pg_restore" --verbose --clean --no-acl --no-owner -h localhost -U rails -d sprint_dev "<PATH TO DUMP>"
  
  ---------------------------------------------------------------------------
  Apache
sudo apt-get install apache2
sudo service apache2 status
sudo service apache2 restart
PIP
sudo sudo apt-get update
sudo apt-get -y install python3-pip
pip3 --version
Python
sudo apt-get install python3.6
python3 --version
sudo pip3 install django
sudo pip3 install django
sudo apt-get update
Postgres
   sudo apt install postgresql postgresql-contrib 
   sudo apt-get update
   sudo -i -u postgres
MemcacheD
   sudo apt-get install memcached
   sudo apt-get install libmemcached-tools  
   sudo apt-get update
   sudo apt-get update -y
Elastic Search
   sudo add-apt-repository ppa:webupd8team/java
   sudo apt-get update
   sudo apt-get install oracle-java8-installer -y
   sudo apt-get install oracle-java8-installer
   sudo apt install openjdk-8-jdk
   java -version
   wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
   sudo sh -c 'echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" > /etc/apt/sources.list.d/elastic-7.x.list'
   sudo apt update
   sudo apt install elasticsearch
   sudo systemctl enable elasticsearch.service
   sudo systemctl start elasticsearch.service
   curl -X GET "localhost:9200/"
   sudo journalctl -u elasticsearch



Install Librarier
sudo pip3 install xhtml2pdf
sudo pip3 install xlwt
ModuleNotFoundError: No module named 'psycopg2'
sudo pip3 install drf-generators
sudo pip3 install djangorestframework
sudo apt-get install postgresql
sudo apt-get install postgresql-client libpq5 libpq-dev
sudo pip3 install pandas
sudo pip3 install xhtml2pdf
sudo pip3 install pdfkit
install django version 2.2.6

python3 manage.py runserver 0.0.0.0:8000
sudo apt-get install python3-pip apache2 libapache2-mod-wsgi-py3

