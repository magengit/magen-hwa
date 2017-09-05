PACKAGE_TAG = hwa
PACKAGE_NAME = magen_$(PACKAGE_TAG)_service
WHEEL := $(PACKAGE_NAME)-1.0a2-py3-none-any.whl
DOCKER_IMAGE=magen-hwa
DOCKER_SRC_TAG=magen_hwa:v1.0
DOCKER_DIR=docker_$(PACKAGE_TAG)
PYTHON=python3
MAKE=make
PYTEST=pytest
COVERAGE=coverage run -m
SERVER_PID=
OS := $(shell uname)
PIP := pip3
SERVER_NAME=

MAGEN_HELPER=../lib/magen_helper

include $(MAGEN_HELPER)/make_common/docker_common.mk
include $(MAGEN_HELPER)/make_common/package_common.mk
include $(MAGEN_HELPER)/make_common/doc_common.mk

default: common_default

clean_docker: common_clean_docker

stop_docker: common_stop_docker

rm_docker: common_rm_docker

all: common_all

clean: common_clean

package: common_package

install: common_install

upload: common_upload

update: common_update

uninstall: common_uninstall

list: common_list

coverage_report: common_coverage_report

pre_test: common_pre_test

run_unit_test: common_run_unit_test

test: common_test

test_travis: common_test_travis

check: common_check

build_docker: common_build_docker

test_docker_travis: common_test_docker

test_docker: test_docker_travis

run_docker: common_run_docker

runpkg_docker: common_runpkg_docker

.PHONY:  pre_test coverage_report all build_docker
