#
# Author:: James Le Cuirot <james.le-cuirot@yakara.com>
# Cookbook Name:: xo
# Recipe:: server
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

require 'shellwords'

extend SELinuxPolicy::Helpers
use_selinux = self.use_selinux
include_recipe 'selinux_policy::install' if use_selinux

# Don't mount web when nginx is on this node.
node.default['xo']['server']['mount_web'] =
  node['xo']['web']['enabled'] && !node['xo']['nginx']['enabled']

# Configure xo-server accordingly.
if node['xo']['server']['mount_web']
  node.default['xo']['server']['config']['http']['mounts']['/'] =
    "#{node['xo']['web']['dir']}/dist"
end

# Use UNIX socket when nginx is on this node.
if node['xo']['nginx']['enabled']
  node.default['xo']['server']['socket_stream'] = '/var/run/xo-server.sock'
  node.default['xo']['server']['socket_group'] = node['nginx']['group']
end

include_recipe 'xo::common'
include_recipe 'redisio::install'

xo_server = node['xo']['server']
xo_config = xo_server['config']

group xo_config['group']

user xo_config['user'] do
  gid xo_config['group']
  comment 'Xen Orchestra'
  home '/dev/null'
  shell '/usr/sbin/nologin'
  system true
end

directory xo_server['data_root'] do
  owner 'root'
  group xo_config['group']
  mode '0750'
  recursive true
end

directory xo_config['datadir'] do
  owner xo_config['user']
  group xo_config['group']
  mode '0750'
  recursive true
end

redisio_configure 'xo-server' do
  default_settings node['redisio']['default_settings']
  base_piddir node['redisio']['base_piddir']

  servers [
    {
      'name' => 'xo-server',
      'user' => xo_config['user'],
      'group' => xo_config['group'],
      'datadir' => "#{xo_server['data_root']}/redis",
      'unixsocket' => xo_config['redis']['uri'],
      'unixsocketperm' => '750',
      'port' => '0'
    }
  ]
end

ark 'xo-server' do
  version xo_server['version']
  checksum xo_server['checksum']
  url xo_server['download_url']

  home_dir xo_server['dir']
  prefix_root File.dirname xo_server['dir']
end

install_stamp = "#{xo_server['dir']}/.installed"

nodejs_npm 'xo-server' do
  path xo_server['dir']
  json true
  not_if { File.file?(install_stamp) }
end

file install_stamp
build_stamp = "#{xo_server['dir']}/.built"

execute 'xo-server build' do
  command 'npm run build'
  cwd xo_server['dir']
  not_if { File.file?(build_stamp) }
end

file build_stamp

file "#{xo_server['dir']}/.xo-server.yaml" do
  content xo_config.to_hash.to_yaml
  owner 'root'
  group xo_config['group']
  mode '0640'
  notifies :restart, 'service[xo-server]'
end

unix_socket = xo_server['socket_stream'][0] == '/'

if unix_socket
  selinux_policy_fcontext xo_server['socket_stream'] do
    secontext 'httpd_var_run_t'
  end
end

systemd_socket 'xo-server' do
  description 'Xen Orchestra socket'
  notifies :restart, 'service[xo-server.socket]'

  socket do
    listen_stream xo_server['socket_stream']
    socket_user xo_config['user']
    socket_group xo_server['socket_group']
    socket_mode '0660'

    if unix_socket and use_selinux
      # https://bugzilla.redhat.com/1197886
      exec_start_post "-/sbin/restorecon #{Shellwords.escape xo_server['socket_stream']}"
    end
  end

  install do
    wanted_by 'sockets.target'
  end
end

systemd_service 'xo-server' do
  description 'Xen Orchestra daemon'
  requires 'xo-server.socket'
  notifies :restart, 'service[xo-server]'

  service do
    user xo_config['user']
    group xo_config['group']
    syslog_identifier 'xo-server'
    working_directory xo_server['dir']
    exec_start '/usr/bin/env node bin/xo-server'
  end

  install do
    wanted_by 'multi-user.target'
  end
end

%w( redis@xo-server xo-server.socket xo-server ).each do |name|
  service name do
    action [:enable, :start]
  end
end
