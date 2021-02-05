#!/usr/bin/python
# -*- coding: utf-8 -*-

# This is a windows documentation stub.  Actual code lives in the .ps1
# file of the same name.

# Copyright 2020 Informatique CDC. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License

from __future__ import absolute_import, division, print_function
__metaclass__ = type


ANSIBLE_METADATA = {'metadata_version': '1.1',
                    'status': ['preview'],
                    'supported_by': 'community'}

DOCUMENTATION = r'''
---
module: win_indexing_service
short_description: Enable or disable Search Indexing
author:
    - Stéphane Bilqué (@sbilque) Informatique CDC
description:
    - This Ansible module ensures that volume indexing is enabled or not.
options:
    drive_letter:
        description:
            - The drive letter assigned to a volume.
        type: str
        required: yes
    state:
        description:
          - When C(state=present) will ensure the indexing is enabled.
          - When C(state=absent) will ensure the indexing is not running.
        type: str
        choices: [ absent, present ]
        default: present
'''

EXAMPLES = r'''
---
- name: test the win_indexing_service module
  hosts: all
  gather_facts: false

  tasks:

    - name: Ensure the indexing is not running
      win_indexing_service:
        drive_letter: D
        state: absent

    - name: Ensure the indexing is enabled
      win_indexing_service:
        drive_letter: D
        state: present
'''

RETURN = r'''
'''