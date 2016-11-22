#
# Author:: James Le Cuirot <james.le-cuirot@yakara.com>
# Cookbook Name:: xo
# Attributes:: 30_nginx
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

default['xo']['nginx']['directives']['access_log'] = "#{node['nginx']['log_dir']}/xo-server.access.log"
default['xo']['nginx']['directives']['client_max_body_size'] = '4g'
default['xo']['nginx']['directives']['listen'] = '80'
default['xo']['nginx']['directives']['root'] = nil # See recipe.
default['xo']['nginx']['directives']['proxy_http_version'] = '1.1'
default['xo']['nginx']['directives']['proxy_read_timeout'] = 1800
default['xo']['nginx']['directives']['server_name'] = node['fqdn']

default['xo']['nginx']['directives']['proxy_set_header'] = {
  'Host' => '$host',
  'X-Real-IP' => '$remote_addr',
  'X-Forwarded-For' => '$proxy_add_x_forwarded_for',
  'X-Forwarded-Proto' => '$scheme',
  'Connection' => '"upgrade"',
  'Upgrade'=> '$http_upgrade'
}

default['xo']['nginx']['enabled'] = false # See recipe.
default['xo']['nginx']['ordered_directives'] = []
default['xo']['nginx']['ssl_redirect'] = 443
default['xo']['nginx']['xo_fqdn'] = 'localhost'

default['nginx']['default_site_enabled'] = false
