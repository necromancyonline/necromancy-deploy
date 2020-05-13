#!/bin/bash
#
# Script Name: deploy.sh
#
# Author: Necromancy Team
# Date : 06.05.2020
#
# Description: The following script deploys the complete stack to a fresh ubuntu installation.

server_git="https://github.com/necromancyonline/necromancy-server.git"

domain_name="server.wizardry-online.com"
ssl_expire_mail="sebastian.heinz.gt@googlemail.com"
php_version="php7.2"

php_dir="/etc/php/"
nginx_dir="/etc/nginx/"
server_dir="/var/necromancy/server"
www_dir="/var/www/server.wizardry-online.com"
sendmail_dir="/etc/mail/"
webhook_dir="/var/necromancy/webhook"

work_dir="$PWD"
tmp_dir="$work_dir/tmp"

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

## Install
# If packet resolution doesn't work due to ipv6
# echo 'Acquire::ForceIPv4 "true";' | tee /etc/apt/apt.conf.d/99force-ipv4


if ! which webhook > /dev/null 2>&1; then    
echo "Installing webhook"
    apt-get install -y webhook
fi

if ! which certbot > /dev/null 2>&1; then
    echo "Installing lets encrypt certbot"
    apt-get install -y software-properties-common
    add-apt-repository -y ppa:certbot/certbot
    apt-get update
    apt-get install -y python-certbot-nginx
fi

if ! which git > /dev/null 2>&1; then
    echo "Installing git"
    apt-get update
    apt-get install -y git
fi

if ! which nginx > /dev/null 2>&1; then
    echo "Installing nginx"
    apt-get update
    apt-get install -y nginx
fi

if ! which opendkim > /dev/null 2>&1; then
    echo "Installing opendkm"
    apt-get update
    apt-get install -y opendkim
fi

if ! which sendmail > /dev/null 2>&1; then
    echo "Installing sendmail"

    IP="127.0.0.1"
    HOST="localhost localhost.localdomain $domain_name"
    sed -i "/$IP/ s/.*/$IP\t$HOST/g" /etc/hosts
    systemctl restart networking
    apt-get update
    apt-get install -y sendmail
fi

if ! which dotnet > /dev/null 2>&1; then
    echo "Installing dotnet"
    wget -q https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
    dpkg -i packages-microsoft-prod.deb
    add-apt-repository universe
    apt-get install -y apt-transport-https
    apt-get update
    apt-get install -y dotnet-sdk-3.1
fi

systemctl stop sendmail
systemctl stop opendkim
systemctl stop necromancy-server
systemctl stop nginx

## ensure directories
mkdir -p "$www_dir/html"
mkdir -p "$www_dir/log"
mkdir -p "$server_dir"
mkdir -p /etc/opendkim
mkdir -p "$webhook_dir"

## copy files
cp -R "$work_dir/html/." "$www_dir/html"
cp -R "$work_dir/nginx/." "$nginx_dir"
cp -R "$work_dir/sendmail/." "$sendmail_dir"
cp "$work_dir/opendkim/opendkim.conf" /etc/opendkim.conf
cp "$work_dir/opendkim/opendkim" /etc/default/opendkim
# TODO get private key
#cp "$work_dir/opendkim/server.wizardry-online.com.priv" /etc/opendkim

## configure sendmail
m4 /etc/mail/sendmail.mc > /etc/mail/sendmail.cf
m4 /etc/mail/submit.mc > /etc/mail/submit.cf

## configure opendkim
chown -R opendkim:opendkim "/etc/opendkim"
chmod -R 700 /etc/opendkim/server.wizardry-online.com.priv

## configure nginx
ln -s "$nginx_dir"sites-available/"$domain_name" "$nginx_dir"sites-enabled/

## delete temp files
echo "Cleaning /tmp Files"
rm -rf "$tmp_dir"

## setup necromancy server
echo "Installing Necromancy Server"
tmp_server_dir="$tmp_dir/server"
git clone --single-branch -b live "$server_git" "$tmp_server_dir"
dotnet publish "$tmp_server_dir/Necromancy.Cli/Necromancy.Cli.csproj" /p:Version=1 /p:FromMSBuild=true --runtime linux-x64 --configuration Release --output $tmp_server_dir/publish
cp -r "$tmp_server_dir/publish/." "$server_dir/."
cp "$work_dir/setting/server_setting.json" "$server_dir/server_setting.json"

echo "Creating Necromancy Server Service"
adduser --disabled-password --gecos "" necromancy_server
chown -R necromancy_server:necromancy_server "$server_dir"
rm /lib/systemd/system/necromancy-server.service
cat << EOF >> /lib/systemd/system/necromancy-server.service
[Unit]
After=network.target

[Service]
Environment="DB_TYPE=sqlite"
Environment="DB_USER="
Environment="DB_PASS="
Type=simple
User=necromancy_server
ExecStart=$server_dir/Necromancy.Cli server start --service --max-packet-size=64 --b-list=3:0x2E64,0xFFFC,0xFFFD,0xFFFE,0xFFFF,3:0x6A72,3:0xE4AE,3:0x8D92,3:0x6B6A,0x8BB4,0x2470
WorkingDirectory=$server_dir
Restart=on-failure
RestartSec=600

[Install]
WantedBy=multi-user.target
EOF


##setup webhook
cp "$work_dir/webhook/hooks.json" "$webhook_dir/hooks.json"

chown -R root:root "$webhook_dir"
rm /lib/systemd/system/webhook.service
cat << EOF >> /lib/systemd/system/webhook.service
[Unit]
After=network.target

[Service]
User=root
Group=root
ExecStart=/usr/bin/webhook -hooks $webhook_dir/hooks.json -verbose
WorkingDirectory=$webhook_dir
Restart=on-failure
RestartSec=600

[Install]
WantedBy=multi-user.target
EOF


## update services
echo "Enabeling services"
systemctl daemon-reload

systemctl enable nginx
systemctl restart nginx

systemctl enable sendmail
systemctl restart sendmail

systemctl enable opendkim
systemctl restart opendkim

systemctl enable necromancy-server
systemctl restart necromancy-server

systemctl enable webhook
systemctl restart webhook

#certbot certonly --standalone --email "$ssl_expire_mail" --agree-tos --no-eff-email --domain "$domain_name" --domain "www.$domain_name" --rsa-key-size 2048
echo "run certbot manually:"
echo certbot certonly --standalone --email "$ssl_expire_mail" --agree-tos --no-eff-email --domain "$domain_name" --domain "www.$domain_name" --rsa-key-size 2048

echo "Setup Completed"
