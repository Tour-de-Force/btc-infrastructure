#
# Cookbook Name:: btc-infrastructure
# Recipe:: couchdb
#
# Author:: Steven Kroh (<sk.kroh@gmail.com>)
#
# Copyright 2016, Adventure Cycling Association

installers = node['installers']['dir']

url = node['couchdb']['url']
exe = node['couchdb']['exe']

# Download the inno setup executable for CouchDB
remote_file "#{installers}/#{exe}" do
  source "#{url}/#{exe}"
  checksum node['couchdb']['checksum']
  action :create
end

home = node['couchdb']['home']

# Run the inno setup executable, ensuring the service task is not run.
# We want to create the service with `erlsrv` ourselves!
powershell_script 'install_couchdb' do
  code <<-EOH
    #{installers}/#{exe} `
        /SP /SILENT /NORESTART /DIR='#{home}' /TASKS=''
  EOH
  not_if "Test-Path #{home}"
  action :run
end

# Copy over our CouchDB config.
# TODO: Transition to couchdb-bootstrap, an npm package
template "#{home}/etc/couchdb/local.ini" do
  source 'local.ini.erb'
end

# Allow incoming HTTP on Couch's default port
netsh_firewall_rule 'Apache CouchDB' do
  description 'Allow HTTP connections to CouchDB on TCP port 5984'
  dir :in
  localport '5984'
  protocol :tcp
  action :allow
end

# Add the windows service for CouchDB using `erlsrv`. Note the `-i` option:
# if we don't supply that, `erlsrv` creates a randomized service name, meaning
# we would not be able to declaratively access the service with chef.
#
# The specific command to run will change with CouchDB releases. Look at our
# documentation on GitHub for instructions.
powershell_script 'install_couchdb_service' do
  code <<-EOH
    #{home}/erts-5.10.3/bin/erlsrv.exe add "Apache CouchDB" `
        -workdir "#{home}/bin"                              `
        -onfail restart_always                              `
        -args "-sasl errlog_type error -s couch +A 4 +W w"  `
        -comment "Apache CouchDB 1.6.1"                     `
        -i "Apache CouchDB"
  EOH
  not_if "@(Get-Service 'Apache CouchDB').count -ge 1"
  action :run
end

# Enable and start the service
windows_service 'Apache CouchDB' do
  action :enable
end

windows_service 'Apache CouchDB' do
  action :start
end