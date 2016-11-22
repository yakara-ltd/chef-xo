#
# Author:: James Le Cuirot <james.le-cuirot@yakara.com>
# Cookbook Name:: xo
# Attributes:: 20_server
#
# Copyright (C) 2016 Yakara Ltd
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
# limitations under the License.
#

default['xo']['server']['version'] = 'stable'
default['xo']['server']['checksum'] = nil
default['xo']['server']['download_url'] = "https://github.com/vatesfr/xo-server/archive/#{node['xo']['server']['version']}.tar.gz"

default['xo']['server']['dir'] = '/srv/xo-server'
default['xo']['server']['data_root'] = '/var/lib/xo-server'

# Overridden by recipe when nginx is on the same node.
default['xo']['server']['socket_stream'] = '0.0.0.0:80'
default['xo']['server']['socket_group'] = nil

default['xo']['server']['config'] = {
  'user' => 'xo',
  'group' => 'xo',
  'http' => {
    'listen' => [
      {
        'fd' => 3,
        'cert' => nil,
        'key' => nil
      }
    ],
    'mounts' => {
      '/' => "#{node['xo']['web']['dir']}/dist"
    },
    'proxies' => {}
  },
  'httpProxy' => nil,
  'redis' => {
    'uri' => "#{node['redisio']['base_piddir']}/xo-server/redis.sock"
  },
  'datadir' => "#{node['xo']['server']['data_root']}/data"
}

default['xo']['server']['config']['http']['redirectToHttps'] =
  node['xo']['server']['config']['http']['listen'].any? { |listen| listen['cert'] }

# https://github.com/redguide/nodejs/issues/137
if platform_family?('debian') and node['nodejs']['engine'] == 'node'
  default['nodejs']['repo'] = 'https://deb.nodesource.com/node_6.x'
end
