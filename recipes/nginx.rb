#
# Author:: James Le Cuirot <james.le-cuirot@yakara.com>
# Cookbook Name:: xo
# Recipe:: nginx
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

# This is used to configure xo-server.
node.default['xo']['nginx']['enabled'] = true

include_recipe 'nginx'

xo_fqdn = node['xo']['nginx']['xo_fqdn']

if xo_fqdn == 'localhost'
  xo_node = node
else
  xo_node = search(:node, "fqdn:#{xo_fqdn}").first

  if xo_node.nil?
    fail "Xen Orchestra node #{xo_fqdn} not found"
  elsif not xo_node.dig('xo', 'server')
    fail "Xen Orchestra node #{xo_fqdn} lacks ['xo']['server'] attributes"
  end
end

template "#{node['nginx']['dir']}/sites-available/xo-server" do
  source 'nginx-site.conf.erb'
  helpers Chef::XO::Helpers
  notifies :reload, 'service[nginx]'

  owner 'root'
  group 'root'
  mode '0644'

  variables lazy {
    node['xo']['nginx'].to_hash.tap do |config|
      xo_server = xo_node['xo']['server']

      if xo_server['socket_stream'][0] == '/'
        config['proxy_pass'] ||= "http://unix:#{xo_server['socket_stream']}:"
      else
        port = xo_server['socket_stream'].scan(/\d+/).last

        if xo_server['config']['http']['listen'][0]['cert']
          protocol = 'https'
          port = nil if port == '443'
        else
          protocol = 'http'
          port = nil if port == '80'
        end

        port.insert 0, ':' if port
        config['proxy_pass'] ||= "#{protocol}://#{xo_fqdn}#{port}"
      end

      if node['xo']['web']['enabled']
        config['directives']['root'] ||= "#{node['xo']['web']['dir']}/dist"
        config['directives']['try_files'] ||= '$uri @xo-server'
      end

      listen = config['directives']['listen']

      # Find listen prefix for SSL redirects. Unneeded for sockets.
      if listen !~ /\Aunix:/ and listen =~ /\A(?<prefix>([^ ]+:)?)\d+\b/
        config['listen_prefix'] = $~[:prefix]
      else
        config.delete('listen_prefix')
      end

      # Disable redirects if we're not using SSL.
      config.delete('ssl_redirect') if listen !~ /\bssl\b/
    end
  }
end

nginx_site 'xo-server'
