# Installing required softwares like Ruby, Rails and PostgreSQL 
Follow the below instructions and commands for basic setup to get the sprint running in development environment. Along with that sign up on bit Bucket and Heroku with official credentials.

#### stable RVM 
curl -sSL https://rvm.io/pkuczynski.asc | gpg2 --import -

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
