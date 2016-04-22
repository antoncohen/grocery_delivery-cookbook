name 'grocery_delivery'
maintainer 'Anton Cohen'
maintainer_email 'anton+chef@antoncohen.com'
license 'apache2'
description 'Installs and configures Grocery Delivery'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '0.1.0'

depends 'build-essential'
depends 'cron'
depends 'git'

supports 'redhat'
supports 'centos'
supports 'ubuntu'

github_repo = 'https://github.com/antoncohen/grocery_delivery-cookbook'
source_url github_repo if respond_to?(:source_url)
issues_url "#{github_repo}/issues" if respond_to?(:issues_url)
