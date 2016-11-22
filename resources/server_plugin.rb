#
# Author:: James Le Cuirot <james.le-cuirot@yakara.com>
# Cookbook Name:: xo
# Resource:: server_plugin
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

property :package, String, name_property: true
property :version, String

action :install do
  nodejs_npm name do
    path node['xo']['server']['dir']
    version new_resource.version
    not_if { plugin_installed? }
    notifies :restart, 'service[xo-server]'
  end
end

action :uninstall do
  execute "npm uninstall #{name}" do
    cwd node['xo']['server']['dir']
    only_if { plugin_installed? }
    notifies :restart, 'service[xo-server]'
  end
end

def plugin_installed?
  dir = node['xo']['server']['dir']
  ::File.directory?("#{dir}/node_modules/#{name}")
end
