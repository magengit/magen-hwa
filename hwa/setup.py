# coding=utf-8
"""Set up wheel for Magen Hello World App"""
from setuptools import setup
import sys
import os
import pip

with open(os.path.join(os.path.dirname(__file__), '__init__.py')) as version_file:
    exec(version_file.read())

if sys.version_info < (3, 5, 2):
    sys.exit("Sorry, you need Python 3.5.2+")

pip_version = int(pip.__version__.replace(".", ""))
if pip_version < 901:
        sys.exit("Sorry, you need pip 9.0.1+")

setup(
    name='magen_hwa_service',
    version=__version__,
    install_requires=[
        'aniso8601>=1.2.1',
        'bs4>=0.0.1',
        'coverage>=4.4.1',
        'flake8>=3.3.0',
        'Flask>=0.12.2',
        'Flask-Cors>=3.0.3',
        'pycrypto>=2.6.1',
        'pymongo>=3.4.0',
        'pytest>=3.1.3',
        'requests>=2.13.0',
        'responses>=0.5.1',
        'Sphinx>=1.6.3',
        'wheel>=0.30.0a0',
        'magen_id_client==2.1a0',
        'magen_logger>=1.0a1',
        'magen_utils>=1.2a2',
        'magen_test_utils==1.0a1',
        'magen_mongo>=1.0a1',
        'magen_rest_service>=1.2a2',
        'magen_statistics_service>=1.1a1'
      ],
    scripts=['hwa_server/hwa_server.py',
             '../lib/magen_helper/helper_scripts/magen_svc_cfgfile_gen.sh'],
    package_dir={'': '..'},
    packages={'hwa', 'hwa.hwa_server', 'hwa.data.template',
              'hwa.data.template.helpers', 'hwa.data.template.doc' },
    include_package_data=True,
    package_data={
        # any package *.txt, *.rst, or *.html files should be installed
        '': ['*.txt', '*.rst', '*.html']
    },
    test_suite='tests',
    url='',
    license='Proprietary License',
    author='Reinaldo Penno',
    author_email='repenno@cisco.com',
    description='Magen Hello-World WebApp MicroService Package',
    classifiers=[
        # How mature is this project? Common values are
        #   3 - Alpha
        #   4 - Beta
        #   5 - Production/Stable
        'Development Status :: 2 - Pre-Alpha',

        # Indicate who your project is intended for
        'Intended Audience :: Education',
        'Intended Audience :: Financial and Insurance Industry',
        'Intended Audience :: Healthcare Industry',
        'Intended Audience :: Legal Industry',
        'Topic :: Security',

        # Pick your license as you wish (should match "license" above)
        'License :: Other/Proprietary License',

        # Specify the Python versions you support here. In particular, ensure
        # that you indicate whether you support Python 2, Python 3 or both.
        'Programming Language :: Python :: 3.5',
    ],
)
