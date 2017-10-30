#!/usr/bin/env bash

MAGEN_DOCKERHUB=magendocker

MAGEN_ROOT=~/magen_onenode
magen_root_printable="~/magen_onenode"
MAGEN_DATA=${MAGEN_ROOT}/magen_data
MAGEN_SOURCE=${MAGEN_ROOT}/magen_source
onenode_scripts=${MAGEN_ROOT}/onenode_scripts
MAGENGIT=https://github.com/magengit  # magengit user address

REPOS=(magen-core magen-ps magen-id magen-ks magen-in magen-hwa)
NUM_OF_SERVICES=6
ONENODE_GIT_TAG=v1.0

export MAGEN_DOCKERHUB
export MAGEN_ROOT
export MAGEN_DATA
export MAGEN_SOURCE
export MAGENGIT
export REPOS
export NUM_OF_SERVICES

blue="033[36m"
red="\033[31m"
green="\033[32m"
yellow="\033[1;33m"

beautiful_echo(){
color=$1
caller_name=$2
txt=$3
echo -en ${color}"${caller_name}: "
echo -en "\033[0m"  ## reset color
echo -e "${txt}"
}

loader(){
    pid=$1 # Process Id of the running command  (\r)

    spin='-\|/'

    i=0
    while kill -0 ${pid} 2>/dev/null
    do
      i=$(( (i+1) %4 ))
      echo -en "\r${spin:$i:1}"
      sleep .1
    done
}

checkout_git(){
caller_name=$1
rm -rf mkdir ${MAGEN_SOURCE}
mkdir ${MAGEN_SOURCE}
for module in "${REPOS[@]}"; do
    echo
    beautiful_echo ${yellow} ${caller_name} "Checking out ${MAGENGIT}/${module}"
    git clone -q ${MAGENGIT}/${module} ${MAGEN_SOURCE}/${module} &
    loader $!
done
}
