#!/bin/bash
sudo apt update

step=1
echo ""
echo "[Step $step] install nginx"
let "step += 1"

sudo apt install -y nginx
sudo cp ./nginx/jenkins.tekwerk-engineering.de /etc/nginx/sites-available/jenkins.tekwerk-engineering.de
sudo cp ./nginx/git.tekwerk-engineering.de /etc/nginx/sites-available/git.tekwerk-engineering.de
ln -s /etc/nginx/sites-available/jenkins.tekwerk-engineering.de /etc/nginx/sites-enabled/jenkins.tekwerk-engineering.de
ln -s /etc/nginx/sites-available/git.tekwerk-engineering.de /etc/nginx/sites-enabled/git.tekwerk-engineering.de
sudo nginx -t

echo ""
echo "[Step $step] fix hashbucket memory problem"
let "step += 1"
# to avoid a possible hash bucket memory problem
fixhashbucket=server_names_hash_bucket_size; sed -i "s/# $fixhashbucket/$fixhashbucket/g" /etc/nginx/nginx.conf
sudo systemctl restart nginx
mkdir -p /tekwerk/volumes/jenkins

# fix issue 177 https://github.com/jenkinsci/docker/issues/177
sudo chown 1000 /tekwerk/volumes/jenkins

echo -e ""
echo -e "[Step $step] build tekwerk jenkins docker image"
let "step += 1"
docker build -f Dockerfile.jenkins -t tekwerk/jenkins:latest .

echo -e ""
echo -e "[Step $step] start docker-compose"
let "step += 1"
curl -L "https://github.com/docker/compose/releases/download/1.25.5/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
docker-compose --version
docker-compose up -d

echo -e ""
echo -e "[Step $step] ssl configuration"
let "step += 1"

sudo apt-get install software-properties-common
sudo add-apt-repository universe
sudo add-apt-repository ppa:certbot/certbot
sudo apt-get update
sudo apt-get install certbot python-certbot-nginx
sudo certbot --nginx

echo -e ""
echo -e "\e[1m[Done]\e[21m all has been setup\n"