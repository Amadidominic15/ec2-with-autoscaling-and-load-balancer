#!/bin/bash
yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd
echo "<h1>This message from my ec2 webserver : $(hostname -i)</h1>" > /var/www/html/index.html