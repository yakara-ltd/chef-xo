XO Cookbook
===========
Installs and configures [Xen Orchestra](https://xen-orchestra.com), the web interface for [XenServer](http://xenserver.org).

Requirements
------------
This cookbook has been tested on:

- CentOS 7
- Debian 8
- Chef 12.16

Usage
-----
#### xo::default
Installs xo-web and xo-server, proxied by nginx. See the other recipes below for details. If you wish the use these recipes individually then you should generally call them in the order web, nginx, server.

#### xo::web
* Downloads and extracts xo-web to a versioned directory and updates the symlink.
* Installs dependencies via npm and builds the project.

#### xo::nginx
Installs and configures nginx to proxy xo-server. This nginx instance may reside on the same node as xo-server, in which case a UNIX socket is used. Otherwise a TCP connection is used to the node given in `node['xo']['nginx']['xo_fqdn']`. The rest of the nginx configuration can be highly customised via the attributes. This recipe is optional as xo-server can serve itself.

#### xo::server
* Installs Redis and configures a dedicated instance with a UNIX socket.
* Downloads and extracts xo-server to a versioned directory and updates the symlink.
* Installs dependencies via npm and builds the project.
* Generates a .xo-server.yaml configuration file from attributes.
* Creates systemd units for the socket and service, and starts them both.

#### xo::common
Common code for the web and server recipes. You should not need to use this.

Contributing
------------
You know what to do. ;)

License and Authors
-------------------
- Author:: James Le Cuirot (<james.le-cuirot@yakara.com>)

```text
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
```
