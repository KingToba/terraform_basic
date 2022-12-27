#!/bin/bash
sudo yum install -y httpd
sudo systemctl start httpd
sudo systemctl enabled httpd
echo "<h1> hello world from terraform </h1>" | sudo tee /var/www/html/index.html