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


class tortuga_kit_ganglia::gmetad::packages {
  # Ensure YUM repo entry is created before attempting to install any packages
  require tortuga::packages

  $pkgs = [
    'ganglia-gmetad',
    'ganglia-web',
  ]

  ensure_resource('package', $pkgs, {'ensure' => 'installed'})
}

class tortuga_kit_ganglia::gmetad::config {
  require tortuga_kit_ganglia::gmetad::packages

  file { '/var/www/html/ganglia':
    ensure => 'link',
    target => '/usr/share/ganglia',
  }

  file { '/var/lib/ganglia/rrds':
    owner => 'nobody',
    group => 'nobody',
  }
}

class tortuga_kit_ganglia::gmetad::service {
  require tortuga_kit_ganglia::gmetad::config

  include tortuga_kit_ganglia::config

  $nodelist = get_nodes_with_component(
    $tortuga_kit_ganglia::config::kitname,
    $tortuga_kit_ganglia::config::kitver,
    $tortuga_kit_ganglia::config::kititer,
    'gmond')

  if $nodelist {
    $nodes = shellquote($nodelist)

    $action = 'running'
    $enable = true
  } else {
    $nodes = 'UNDEFINED'

    $action = 'stopped'
    $enable = false
  }

  file { '/etc/ganglia/gmetad.conf':
    source => 'puppet:///modules/tortuga_kit_ganglia/gmetad.conf',
  }

  service { 'gmetad':
    ensure     => $action,
    enable     => $enable,
    hasstatus  => true,
    hasrestart => true,
    require    => File['/etc/ganglia/gmetad.conf'],
  }

  File['/etc/ganglia/gmetad.conf'] ~> Service['gmetad']
}

class tortuga_kit_ganglia::gmetad {
  contain tortuga_kit_ganglia::gmetad::packages
  contain tortuga_kit_ganglia::gmetad::config
  contain tortuga_kit_ganglia::gmetad::service

  Class['tortuga_kit_ganglia::gmetad::config'] ~>
    Class['tortuga_kit_ganglia::gmetad::service'] ~>
    Class['tortuga::installer::apache::server']
}
