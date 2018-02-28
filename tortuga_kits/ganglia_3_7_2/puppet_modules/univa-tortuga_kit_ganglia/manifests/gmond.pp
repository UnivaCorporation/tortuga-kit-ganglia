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


class tortuga_kit_ganglia::gmond::packages {
  # Ensure YUM repo entry is created before attempting to install any packages
  require tortuga::packages

  package { 'ganglia-gmond':
    ensure => installed,
  }
}

class tortuga_kit_ganglia::gmond::config {
  require tortuga_kit_ganglia::gmond::packages

  include tortuga::config

  if ($::fqdn == $::primary_installer_hostname) {
    # If the installer is being configured, ensure gmond is put into
    # listener mode.
    file { '/etc/ganglia/gmond.conf':
      content => template('tortuga_kit_ganglia/gmond.conf.listener.erb'),
    }
  } else {
    # "Regular" compute host

    if $::ec2_instance_id {
      $bind_hostname = 'no'
    } else {
      $bind_hostname = 'yes'
    }

    file { '/etc/ganglia/gmond.conf':
      content => template('tortuga_kit_ganglia/gmond.conf.erb'),
    }
  }

  $enable_monitoring = false

  if ($::fqdn == $::primary_installer_hostname and $enable_monitoring) {
    file { '/etc/ganglia/conf.d/installer.conf':
      content => template('tortuga_kit_ganglia/installer.conf.erb'),
    }
  }
}

class tortuga_kit_ganglia::gmond::service {
  require tortuga_kit_ganglia::gmond::config

  service { 'gmond':
    enable     => true,
    ensure     => running,
    hasstatus  => true,
    hasrestart => true,
  }
}

class tortuga_kit_ganglia::gmond {
  contain tortuga_kit_ganglia::gmond::packages
  contain tortuga_kit_ganglia::gmond::config
  contain tortuga_kit_ganglia::gmond::service

  Class['tortuga_kit_ganglia::gmond::config'] ~>
    Class['tortuga_kit_ganglia::gmond::service']
}
