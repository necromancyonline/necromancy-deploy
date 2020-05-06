#!/bin/bash
#
# Script Name: updep.sh
#
# Author: Necromancy Team
# Date : 06.05.2020
#
# Description:
#
# Uploads this folder to a remote server.
#
# once uplaoded execute the following commands on the remote server:
# sudo rm -rf deploy && mkdir deploy && tar -xvjf deploy.tar.gz -C deploy && cd ./deploy
# cd deploy
# sudo ./deploy.sh

rm -rf deploy.tar.gz
tar cjf deploy.tar.gz --exclude='./../necromancy-deploy/.idea' -C "./../necromancy-deploy" $(ls "./../necromancy-deploy")
scp deploy.tar.gz root@server.wizardry-online.com:~