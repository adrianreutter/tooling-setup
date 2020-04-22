#!/bin/bash
sudo apt update
# install nginx with config
sudo apt install nginx
sudo cp ./nginx/jenkins.tekwerk-engineering.de /etc/nginx/sites-available/jenkins.tekwerk-engineering.de
sudo cp ./nginx/git.tekwerk-engineering.de /etc/nginx/sites-available/git.tekwerk-engineering.de
sudo nginx -t

# to avoid a possible hash bucket memory problem
fixhashbucket=server_names_hash_bucket_size 64; sed -i "/^#$fixhashbucket/ c$fixhashbucket" /etc/nginx/nginx.conf
sudo systemctl restart nginx
docker-compose up
