#!/bin/bash

virtualenv ~/aws_env_py
. ~/aws_env_py/bin/activate
pip install awscli --upgrade
