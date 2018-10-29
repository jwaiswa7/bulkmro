# Installing Elasticsearch on Ubuntu
sudo apt install openjdk-11-jre-headless

# Instructions
#### Ubuntu
https://www.elastic.co/guide/en/elasticsearch/reference/current/deb.html

#### Windows
https://www.java.com/en/download/
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


-----

# Features
## Margins
- Margins are low
- More than 10%, manual intervention for Devang
- Less than 10% margin, only Devang can approve
- Explanation for low margin, adding to order will require a comment

## Payments
- Template file for uploading bank
- Payment checklist (not working)
- Even assumed freight is fine
- Some checklist-esque report in Sprint for payments

## Payment requests
- How are payments requested
