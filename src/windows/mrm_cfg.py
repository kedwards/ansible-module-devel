#!/usr/bin/python
# -*- coding: utf-8 -*-

# this is a windows documentation stub.  actual code lives in the .ps1
# file of the same name

ANSIBLE_METADATA = {'metadata_version': '1.0',
                    'status': ['stableinterface'],
                    'supported_by': 'MRM Team'}

DOCUMENTATION = r'''
---
module: mrm_cfg
version_added: "2.4.0"
short_description: Report on Openlink configuration.
description:
  - Checks and reports Openlink configurations
options:
  src:
    description:
      - Alternate path to search for Openlink configuration files
    default: 'D:\\Openlink\\Endur'
  service:
    description:
      - Openlink Service to report on
    default: 'ALL'
author: "Kevin Edwards (@kedwards)"
'''

EXAMPLES = r'''
# Report Openlink Configuration
# ansible winserver -m mrm_cfg

# Example from an Ansible Playbook
- mrm_cfg:

# Check configurations in an alternate folder
- mrm_cfg:
    src: D:\\Openlink\\Endur\\AlternatePath

# Check configurations for a specific service
- mrm_cfg:
    svc: DailyDev

# Check configurations for a specific service stored in an alternate folder
- mrm_cfg:
    src: D:\\Openlink\\Endur\\AlternatePath
	svc: DailyDev
'''
