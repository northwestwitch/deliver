#!/usr/bin/env python
# -*- coding: utf-8 -*-
import io
import os
from setuptools import setup, find_packages
from setuptools.command.test import test as TestCommand
import sys

# This is a plug-in for setuptools that will invoke py.test
# when you run python setup.py test
class PyTest(TestCommand):

    """Set up the py.test test runner."""

    def finalize_options(self):
        """Set options for the command line."""
        TestCommand.finalize_options(self)
        self.test_args = []
        self.test_suite = True

    def run_tests(self):
        """Execute the test runner command."""
        # Import here, because outside the required eggs aren't loaded yet
        import pytest
        sys.exit(pytest.main(self.test_args))

# Get the long description from the relevant file
here = os.path.abspath(os.path.dirname(__file__))
with io.open(os.path.join(here, 'README.md'), encoding='utf-8') as f:
    long_description = f.read()

with open('requirements.txt') as f:
    required = f.read().splitlines()

setup(
    name='deliver',

    # Versions should comply with PEP440. For a discussion on
    # single-sourcing the version across setup.py and the project code,
    # see http://packaging.python.org/en/latest/tutorial.html#version
    version='1.33.1',

    description='Create links and rename sample names',
    long_description=long_description,
    # What does your project relate to? Separate with spaces.
    keywords='sequencing clinical exome genome data delivery',
    author='Kenny Billiau',
    author_email='kenny.billiau@scilifelab.se',
    license='MIT',

    packages=find_packages(exclude=('tests*', 'docs', 'examples')),

    # If there are data files included in your packages that need to be
    # installed, specify them here.
    include_package_data=True,
    zip_safe=False,

    install_requires=required,
    cmdclass=dict(test=PyTest),

    # To provide executable scripts, use entry points in preference to the
    # "scripts" keyword. Entry points provide cross-platform support and
    # allow pip to create the appropriate form of executable for the
    # target platform.
    entry_points={
        'console_scripts': [
            'deliver = deliver.cli:link',
        ],
        'createlinks.subcommands.3': [
            'bam = deliver.cli:bam',
            'cust = deliver.cli:cust',
            'demux = deliver.cli:demux',
            'ext = deliver.cli:ext',
            'microbial = deliver.cli.microbial',
        ]
    },

    # See: http://pypi.python.org/pypi?%3Aaction=list_classifiers
    classifiers=[
        # How mature is this project? Common values are:
        #   3 - Alpha
        #   4 - Beta
        #   5 - Production/Stable
        'Development Status :: 3 - Alpha',

        # Indicate who your project is intended for
        'Intended Audience :: Science/Research',
        'Topic :: Software Development',
        'Topic :: Scientific/Engineering :: Bio-Informatics',

        # Pick your license as you wish (should match "license" above)
        'License :: OSI Approved :: MIT License',

        # Specify the Python versions you support here. In particular, ensure
        # that you indicate whether you support Python 2, Python 3 or both.
        'Programming Language :: Python :: 2',
        'Programming Language :: Python :: 2.7',
        'Programming Language :: Python :: 3',
        'Programming Language :: Python :: 3.3',
        'Programming Language :: Python :: 3.4',

        'Environment :: Console',
    ],
)
