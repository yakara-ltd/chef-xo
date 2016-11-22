#
# Author:: James Le Cuirot <james.le-cuirot@yakara.com>
# Cookbook Name:: xo
# Recipe:: 10_web
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

# This is used to configure nginx.
node.default['xo']['web']['enabled'] = true

include_recipe 'xo::common'

xo_web = node['xo']['web']

ark 'xo-web' do
  version xo_web['version']
  checksum xo_web['checksum']
  url xo_web['download_url']

  home_dir xo_web['dir']
  prefix_root File.dirname xo_web['dir']
end

install_stamp = "#{xo_web['dir']}/.installed"

nodejs_npm 'xo-web' do
  path xo_web['dir']
  json true
  not_if { File.file?(install_stamp) }
end

file install_stamp
build_stamp = "#{xo_web['dir']}/.built"

execute 'xo-web build' do
  command 'npm run build'
  cwd xo_web['dir']
  not_if { File.file?(build_stamp) }
end

file build_stamp
