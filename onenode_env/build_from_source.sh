#!/usr/bin/env bash

# This script will check out github repos from official magengit
# the user can specify tag for all repos

CORE_IMAGE_NAME=magen_base:17.02

source globals.sh  # souring variables of required paths

this=`basename $0`

checkout_git ${this}

source_dirs=(. policy id ks ingestion hwa)

replace_in_dockerfile(){
service=$1

if [ -d "docker_$service" ]; then
    cd docker_${service}
    sed -i '' '/FROM/ c\
    FROM magen_base:17.02
    ' Dockerfile;
fi
cat Dockerfile
cd ..
}

for((i=0; i<${NUM_OF_SERVICES}; i++)); do
    cd ${MAGEN_SOURCE}/${REPOS[i]}/${source_dirs[i]}
    echo
    beautiful_echo ${yellow} ${this} "Updating Git Submodules"
    git submodule -q update --init --recursive
done


cd ${MAGEN_SOURCE}/${REPOS[0]}
echo
beautiful_echo ${red} ${this} "Building CORE image"
make build_base_docker
#loader $!

for ((i=1; i<${NUM_OF_SERVICES}; i++)); do
    echo
    beautiful_echo ${yellow} ${this} "Building: ${source_dirs[i]} from source"
    cd ${MAGEN_SOURCE}/${REPOS[i]}/${source_dirs[i]}
    replace_in_dockerfile ${source_dirs[i]}
    make build_docker
#    make all > /dev/null &
#    loader $!
done
