#!/usr/bin/env python

# Copyright 2008-2018 Univa Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import socket

from tortuga.kit.installer import ComponentInstallerBase
from tortuga.os_utility import tortugaSubprocess


class ComponentInstaller(ComponentInstallerBase):
    name = 'gmetad'
    version = '3.7.2'
    os_list = [
        {'family': 'rhel', 'version': '6', 'arch': 'x86_64'},
        {'family': 'rhel', 'version': '7', 'arch': 'x86_64'},
    ]

    def _schedule_update(self):
        hostname = socket.gethostname().split('.')[0]
        cmd = 'mco puppet --json --no-progress runonce -I {}'.format(hostname)
        tortugaSubprocess.executeCommandAndIgnoreFailure(cmd)

    def action_add_host(self, hardware_profile_name, software_profile_name,
                        nodes, *args, **kargs):
        self._schedule_update()

    def action_delete_host(self, hardware_profile_name, software_profile_name,
                           nodes, *args, **kargs):
        self._schedule_update()
