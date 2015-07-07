#!/bin/bash

location=$(pwd)
default_container=$(vagrant global-status | grep $location/proxy | awk -F "^| default" '{print $1}')
vagrant destroy -f && vagrant destroy -f $default_container

if [ -f "proxy/config.yaml" ]; then
  rm proxy/config.yaml
fi

if [ -f ".dockercfg" ]; then
  rm .dockercfg
fi