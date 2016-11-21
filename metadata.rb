name             'xo'
maintainer       'James Le Cuirot'
maintainer_email 'james.le-cuirot@yakara.com'
license          'Apache 2.0'
description      'Installs and configures Xen Orchestra'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

depends 'build-essential'
depends 'nginx', '~> 2.7'
depends 'nodejs'
depends 'redisio'
depends 'selinux_policy'
depends 'systemd'

supports 'centos'
supports 'debian'
