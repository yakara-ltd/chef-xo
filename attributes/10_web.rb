#
# Author:: James Le Cuirot <james.le-cuirot@yakara.com>
# Cookbook Name:: xo
# Attributes:: web
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

default['xo']['web']['version'] = 'stable'
default['xo']['web']['checksum'] = nil
default['xo']['web']['download_url'] = "https://github.com/vatesfr/xo-web/archive/#{node['xo']['web']['version']}.tar.gz"

default['xo']['web']['dir'] = '/var/www/xo-web'
default['xo']['web']['enabled'] = false # See recipe.
