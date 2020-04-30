#!/bin/bash
sudo apt update

step=1
echo -e ""
echo -e "\e[1m[Step $step]\e[21m install nginx"
let "step += 1"

sudo apt install -y nginx
sudo cp ./nginx/jenkins.tekwerk-engineering.de /etc/nginx/sites-available/jenkins.tekwerk-engineering.de
sudo cp ./nginx/git.tekwerk-engineering.de /etc/nginx/sites-available/git.tekwerk-engineering.de
ln -s /etc/nginx/sites-available/jenkins.tekwerk-engineering.de /etc/nginx/sites-enabled/jenkins.tekwerk-engineering.de
ln -s /etc/nginx/sites-available/git.tekwerk-engineering.de /etc/nginx/sites-enabled/git.tekwerk-engineering.de
sudo nginx -t

echo -e ""
echo -e "\e[1m[Step $step]\e[21m fix hashbucket memory problem"
let "step += 1"
# to avoid a possible hash bucket memory problem
fixhashbucket=server_names_hash_bucket_size; sed -i "s/# $fixhashbucket/$fixhashbucket/g" /etc/nginx/nginx.conf
sudo systemctl restart nginx
mkdir -p /tekwerk/volumes/jenkins

# fix issue 177 https://github.com/jenkinsci/docker/issues/177
sudo chown 1000 /tekwerk/volumes/jenkins

echo -e ""
echo -e "\e[1m[Step $step]\e[21m build tekwerk jenkins docker image"
let "step += 1"
docker build -f Dockerfile.jenkins -t tekwerk/jenkins:latest .

echo -e ""
echo -e "\e[1m[Step $step]\e[21m start docker-compose"
let "step += 1"
docker-compose up -d

echo -e ""
echo -e "\e[1m[Step $step]\e[21m ssl configuration"
let "step += 1"
ssl=false
while true; do
    read -p "Do you wish to setup certbot?" yn
    case $yn in
        [Yy]* ) let "ssl=true"; break;;
        [Nn]* ) let "ssl=false"; break;;
        * ) echo "Please answer yes or no.";;
    esac
done

if ssl;
  then
    sudo apt-get install software-properties-common
    sudo add-apt-repository universe
    sudo add-apt-repository ppa:certbot/certbot
    sudo apt-get update
    sudo apt-get install certbot python-certbot-nginx
    sudo certbot --nginx
fi

echo -e ""
echo -e "\e[1m[Done]\e[21m all has been setup\n"