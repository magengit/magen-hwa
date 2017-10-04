# Magen Asset Repository Service ("Hello World Application")

[![Build Status](https://travis-ci.org/magengit/magen-hwa.svg?branch=master)](https://travis-ci.org/magengit/magen-hwa)
[![codecov](https://codecov.io/gh/magengit/magen-hwa/branch/master/graph/badge.svg)](https://codecov.io/gh/magengit/magen-hwa)
[![Code Health](https://landscape.io/github/magengit/magen-hwa/master/landscape.svg?style=flat)](https://landscape.io/github/magengit/magen-hwa/master)


Magen HWA is a web server app that demonstrates the capabilities and interoperation of the various Magen services. The "onenode" orchestrator included in the distribution can be used to stand up HWA, the four Magen services, and a mongod instance as 6 cooperating containers. The user can first use the HWA web interface to "log in", with the operation handled through the Magen ID Service. The user can then use HWA to ingest files, with the operation handled through the Magen ID Service and with the ingested asset encrypted using a key provided by the Magen Key Service. The user can then use HWA to try to access (view or download) a previously ingested file, with the access attempt evaluated by the Magen Policy Service. Finally, HWA provides detailed documentation through the web interface.

Policies are managed (e.g. created) through the Magen Policy Service ReST API, driven e.g. from Postman using the magen-policy-specific Postman collections included in the distribution. Without creating an appropriate policy, attempts to access ingestion assets will fail.

Current version: ```1.0a2```

For This Service there are available ```make``` commands. Makefile is located under [**hwa/**](hwa)

Make Default Target: ```make default```. Here is the list of available targets

```make
default:
	@echo 'Makefile for Magen HWA'
	@echo
	@echo 'Usage:'
	@echo '	make clean    		:Remove packages from system and pyc files'
	@echo '	make test     		:Run the test suite'
	@echo '	make package  		:Create Python wheel package'
	@echo '	make install  		:Install Python wheel package'
	@echo '	make all      		:clean->package->install'
	@echo '	make list     		:List of All Magen Dependencies'
	@echo '	make build_docker 	:Pull Base Docker Image and Current Image'
	@echo '	make run_docker   	:Build and Run required Docker containers with mounted source'
	@echo '	make runpkg_docker	:Build and Run required Docker containers with created wheel'
	@echo '	make test_docker  	:Build, Start and Run tests inside main Docker container interactively'
	@echo '	make stop_docker  	:Stop and Remove All running Docker containers'
	@echo '	make clean_docker 	:Remove Docker unused images'
	@echo '	make rm_docker    	:Remove All Docker images if no containers running'
	@echo '	make doc		:Generate Sphinx API docs'
	@echo
	@echo
```

## Requirements: MacOS X
0. ```python3 -V```: Python **3.5.2** (>=**3.4**)
0. ```pip3 -V```: pip **9.0.1**
0. ```make -v```: GNU Make **3.81**
1. ```docker -v```: Docker version **17.03.0-ce**, build 60ccb22
2. ```docker-compose -v```: docker-compose version **1.11.2**, build dfed245
3. Make sure you have correct rights to clone Cisco-Magen github organization

## Requirements: AWS EC2 Ubuntu
0. ```python3 -V```: Python **3.5.2**
1. ```pip3 -V```: pip **9.0.1**
2. ```make -v```: GNU Make **4.1**
3. ```docker -v```: Docker version **17.03.0-ce**, build 60ccb22
4. ```docker-compose -v```: docker-compose version **1.11.2**, build dfed245
5. Make sure AWS user and **root** have correct rights to Cisco-Magen github organization

## Targets

1. ```make all```  -> Install *Magen-Core* dependencies, clean, package and install **hwa** package
2. ```make test``` -> run **hwa** tests

## Adopt this Infrastructure

1. get [**helper_scripts**](hwa/helper_scripts) to the repo
2. follow the structure in [**docker_hwa**](hwa/docker_hwa) to create ```docker-compose.yml``` and ```Dockerfile``` files
3. use [**Makefile**](hwa/Makefile) as an example for building make automation
