#!/bin/bash
sudo apt update
# install nginx with config
echo "[Step 1] install nginx\n"
sudo apt install nginx
sudo cp ./nginx/jenkins.tekwerk-engineering.de /etc/nginx/sites-available/jenkins.tekwerk-engineering.de
sudo cp ./nginx/git.tekwerk-engineering.de /etc/nginx/sites-available/git.tekwerk-engineering.de
ln -s /etc/nginx/sites-available/jenkins.tekwerk-engineering.de /etc/nginx/sites-enabled/jenkins.tekwerk-engineering.de
ln -s /etc/nginx/sites-available/git.tekwerk-engineering.de /etc/nginx/sites-enabled/git.tekwerk-engineering.de
sudo nginx -t

# to avoid a possible hash bucket memory problem
fixhashbucket=server_names_hash_bucket_size; sed -i "s/# $fixhashbucket/$fixhashbucket/g" /etc/nginx/nginx.conf
sudo systemctl restart nginx
mkdir /var/jenkins

echo "[Step 2] start docker-compose\n"
docker-compose up -d
