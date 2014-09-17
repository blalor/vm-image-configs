#!/usr/bin/env python
# -*- encoding: utf-8 -*-

import yaml
import json
import sys

json.dump(yaml.load(sys.stdin), sys.stdout, indent=4)
