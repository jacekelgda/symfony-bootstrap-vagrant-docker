#!/bin/bash
# Set PS3 prompt

modman clone git@github.com:Sysla/ubuntu1410-docker.git
modman update-all
modman deploy-all

git submodule update --init --recursive

IP=192.168.36.10
PORT=8080
VM_HOSTNAME=template.lh

PS3="Pick project to setup : "

args=("$@")

hostname=${args[0]}

if [ -z "${args[0]}" ]; then
    select hostname in template
    do
        break
    done
fi
case $hostname in
  template)
    IP=192.168.37.10
    PORT=8080
    VM_HOSTNAME=template.lh
    break
    ;;
  *)
    echo "Error: Please try again"
    ;;
esac

sed "s/<IP_ADDRESS>/$IP/;s/<PORT>/$PORT/" < proxy/config.yaml.TEMPLATE > proxy/config.yaml
sed "s/<HOSTNAME>/$VM_HOSTNAME/" < proxy/Vagrantfile.proxy.TEMPLATE > proxy/Vagrantfile.proxy

if [ -z "${args[0]}" ]; then
  vi proxy/config.yaml
fi

# docker config
if [ -f ".dockercfg.TEMPLATE" ]; then
  if [ ! -f ".dockercfg" ]; then
    echo "Creating dockerhub credentials"

    DOCKER_USER_EMAIL=$(cat credentials.yml | grep DOCKER_USER_EMAIL | sed "s/.*://")
    if [ ! "$DOCKER_USER_EMAIL" ]; then
      read -p "Enter dockerhub email:" DOCKER_USER_EMAIL
    fi

    DOCKER_USER_AUTH=$(cat credentials.yml | grep DOCKER_USER_AUTH | sed "s/.*://")
    if [ ! "$DOCKER_USER_AUTH" ]; then
      read -p "Enter dockerhub auth:" DOCKER_USER_AUTH
    fi

    sed "s/<EMAIL>/$DOCKER_USER_EMAIL/;s/<AUTH>/$DOCKER_USER_AUTH/" < .dockercfg.TEMPLATE > .dockercfg
  fi
fi

vagrant up --provider=docker --no-parallel

location=$(pwd)
default_container=$(vagrant global-status | grep $location/proxy | awk -F "^| default" '{print $1}')
vagrant ssh $default_container