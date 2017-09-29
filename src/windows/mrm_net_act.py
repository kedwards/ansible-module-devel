#!/usr/bin/python
# -*- coding: utf-8 -*-

# this is a windows documentation stub.  actual code lives in the .ps1
# file of the same name

ANSIBLE_METADATA = {'metadata_version': '1.0',
                    'status': ['stableinterface'],
                    'supported_by': 'MRM Team'}


DOCUMENTATION = r'''
---
module: mrm_net_act
version_added: "1.0.0"
short_description: Report on Openlink connections.
description:
  - Checks and reports Openlink connections
author: "Kevin Edwards (@kedwards)"
'''

EXAMPLES = r'''
# Report Openlink Connections
# ansible winserver -m mrm_net_act

# Example from an Ansible Playbook
- mrm_net_act:
'''

