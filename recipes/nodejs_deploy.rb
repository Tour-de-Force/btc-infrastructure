=begin
btc_infrastructure -- Cookbook for the Bicycle Touring Companion infrastructure
Copyright © 2016 Adventure Cycling Association

This file is part of btc_infrastructure.

btc_infrastructure is free software: you can redistribute it and/or modify
it under the terms of the Affero GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

btc_infrastructure is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
Affero GNU General Public License for more details.

You should have received a copy of the Affero GNU General Public License
along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
=end

# The app name we're expecting to deploy
app_name = node['server']['name']

app = search('aws_opsworks_app', "name:#{app_name}").first

# Only deploy if the incoming app name matches our expected app name
if app && app['deploy'] == true
  # Install nssm, so we can wrap the app server in a Windows service
  include_recipe 'nssm'

  # Allow incoming HTTP on Couch's default port
  netsh_firewall_rule 'Node.js App Server' do
    description 'Allow HTTP connections to the App Server on TCP port 80'
    dir :in
    localport '80'
    protocol :tcp
    action :allow
  end

  # Set all environment variables incoming from the app. These include, but
  # are not limited to:
  #  - NODE_ENV
  #  - SERVER_SECRET
  #  - SERVER_JWT_EXP
  #  - SERVER_COUCH_USERNAME
  #  - SERVER_COUCH_PASSWORD
  app['environment'].each do |key, val|
    env key do
      value val
    end
  end

  # The app servers' directory in the global node_modules
  app_dir = File.join(node['nodejs']['npm']['home'], 'node_modules', app_name)

  # We re-purpose the AWS OpsWorks App "document root" field to mean the
  # javascript file within the npm package to run, usualy `path/to/index.js`
  script = app['attributes']['document_root']

  # Pay attention! The next few resources are out of logical order. We execute
  # them in the right order by chaining notifications.

  # First, install the service with nssm.cc, even though the javascript file
  # referenced by the `script` variable MAY NOT EXIST yet. We need the
  # Windows service to exist so we can use the :stop action regardless if
  # this is the first or a subsequent chef run.
  nssm app_name do
    program node['nodejs']['node.exe']
    args File.join(app_dir, script)
    params(
      AppDirectory: app_dir,
      AppStdout: File.join(app_dir, 'service.log'),
      AppStderr: File.join(app_dir, 'error.log'),
      AppRotateFiles: 1
    )
    start false
    action :install
  end

  remote_file File.join(Chef::Config[:file_cache_path], "#{app_name}.tgz") do
    source app['app_source']['url']
    action :create
  end

  service 'Stop before update' do
    service_name app_name
    action :stop
  end

  # powershell_script[install_app] depends on Git. We need to ensure Git
  # is in Ruby's ENV['Path']
  unless ENV['Path'].include? 'Git'
    ENV['Path'] += ';' + File.join(node['git']['home'], 'bin')
  end

  # powershell_script[install_app] depends on Npm. We need to ensure Npm
  # is in Ruby's ENV['Path'] (via Node.js install dir)
  unless ENV['Path'].include? 'npm'
    ENV['Path'] += ';' + (node['nodejs']['home'])
  end

  # Define the powershell script to install our app server tarball. However,
  # do nothing! If the tarball changes (below), it will notify us to install
  # the changes. In addition, when the install completes, run the service.
  powershell_script 'install_app' do
    code "npm install -g --loglevel error #{app_name}.tgz"
    cwd Chef::Config[:file_cache_path]
    action :run
  end

  # Ensure the service is enabled, so that it will start on boot
  service 'Start and enable' do
    service_name app_name
    action [:enable, :start]
  end
end
