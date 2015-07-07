#!/bin/bash

if [ ! -d ".modman" ]; then
  modman init
fi

if [ ! -d "bin/vagrant-up.sh" ]; then
  modman clone git@github.com:jacekelgda/symfony-bootstrap-vagrant-docker
fi

args=("$@")
project=${args[0]}
if [ -z "$project" ]; then
    sh bin/core-vagrant-up.sh
else
    sh bin/core-vagrant-up.sh project
fi