#! /usr/bin/python3
import base64
import hashlib
import json
import unittest

# noinspection PyUnresolvedReferences
import time
import uuid
from http import HTTPStatus
from unittest.mock import Mock, patch
import io

from datetime import datetime
from flask import Flask

from magen_rest_apis.rest_client_apis import RestClientApis
from pathlib import Path

from hwa.tests.magen_env import *
from hwa.tests.hwa_test_messages import *

from hwa.hwa_server.hwa_server import hwa_url_bp
from hwa.hwa_server.hwa_urls import HwaUrls

__author__ = "Reinaldo Penno"
__copyright__ = "Copyright(c) 2017, Cisco Systems, Inc."
__license__ = "New-style BSD"
__version__ = "0.1"
__email__ = "rapenno@gmail.com"


class TestRestApi(unittest.TestCase):

    @classmethod
    def setUpClass(cls):

        docker_env = Path("/.dockerenv")

        cls.magen = Flask(__name__)
        cls.magen.config['TESTING'] = True
        cls.magen.register_blueprint(hwa_url_bp)
        cls.app = cls.magen.test_client()

    def delete_hwa_configuration(self):
        return True

    def setUp(self):
        """
        This function prepares the system for running tests
        """
        self.assertIs(self.delete_hwa_configuration(), True)

    def tearDown(self):
        self.assertIs(self.delete_hwa_configuration(), True)

    def test_Check(self):
        hwa_urls = HwaUrls()        
        check_url = hwa_urls.hwa_external_url_base + "/check/"
        get_resp_obj = self.app.get(check_url)
        self.assertEqual(get_resp_obj.status_code, HTTPStatus.OK)

    def test_SetLoggingLevel(self):
        """
        Sets logging level with PUT
        """
        print("+++++++++Sets Logging Level +++++++++")
        hwa_urls = HwaUrls()        
        resource_url = hwa_urls.hwa_external_url_base + "/logging_level/"
        resp_obj = type(self).app.put(
            resource_url, data=HWA_LOGGING_LEVEL_VALID_LVL,
            headers=RestClientApis.put_json_headers)
        self.assertEqual(resp_obj.status_code, HTTPStatus.OK)

    def test_SetLoggingLevelFail(self):
        """
        Sets logging level with PUT
        """
        print("+++++++++Sets Logging Level Fail +++++++++")
        hwa_urls = HwaUrls()        
        resource_url = hwa_urls.hwa_external_url_base + "/logging_level/"
        resp_obj = type(self).app.put(
            resource_url, data=HWA_LOGGING_LEVEL_INVALID_LVL,
            headers=RestClientApis.put_json_headers)
        self.assertEqual(resp_obj.status_code, HTTPStatus.INTERNAL_SERVER_ERROR)
