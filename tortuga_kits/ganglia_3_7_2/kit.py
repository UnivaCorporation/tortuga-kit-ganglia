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

import os
import shutil

from tortuga.kit.installer import KitInstallerBase
from tortuga.kit.manager import KitManager
from tortuga.os_utility import tortugaSubprocess


class GangliaInstaller(KitInstallerBase):
    puppet_modules = ['univa-tortuga_kit_ganglia']

    def action_post_install(self, *args, **kwargs):
        super().action_post_install(*args, **kwargs)
        #
        # Cache Ganglia packages from EPEL
        #
        os.system(os.path.join(self.install_path, 'bin', "dl.sh"))

        kit = KitManager().getKit('ganglia')
        kit_repo_dir = os.path.join(
            self.config_manager.getReposDir(),
            kit.getKitRepoDir()
        )

        cmd = 'rsync -a {}/ {}'.format('/var/cache/tortuga/pkgs/ganglia',
                                       kit_repo_dir)
        tortugaSubprocess.executeCommandAndIgnoreFailure(cmd)

        cmd = 'cd %s; createrepo .'.format(kit_repo_dir)
        tortugaSubprocess.executeCommandAndIgnoreFailure(cmd)

        #
        # Copy default configuration file into place
        #
        dst_path = os.path.join(self.config_manager.getKitConfigBase(),
                                'ganglia')
        if not os.path.exists(dst_path):
            os.makedirs(dst_path)
        shutil.copyfile(
            os.path.join(self.files_path, 'gmond-component.conf'),
            os.path.join(dst_path, 'gmond-component.conf')
        )

    def action_post_uninstall(self, *args, **kwargs):
        tortugaSubprocess.executeCommand(
            'rm -rf /var/cache/tortuga/pkgs/ganglia')
