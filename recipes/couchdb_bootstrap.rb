# btc_infrastructure -- Cookbook for the Bicycle Touring Companion
# Copyright (C) 2016 Adventure Cycling Association
#
# This file is part of btc_infrastructure.
#
# btc_infrastructure is free software: you can redistribute it and/or modify
# it under the terms of the Affero GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# btc_infrastructure is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# Affero GNU General Public License for more details.
#
# You should have received a copy of the Affero GNU General Public License
# along with btc_infrastructure.  If not, see <http://www.gnu.org/licenses/>.

# We need nodejs to run couchdb-bootstrap: it's an npm module
include_recipe 'btc_infrastructure::nodejs'

work = node['work']['dir']

# Create a work directory to extract our CouchDB config structure to
directory work

remote_directory "#{work}/couchdb" do
  source 'couchdb'
  action :create
end

# Install the couchdb-bootstrap npm module globally
# TODO: Figure out better npm path solution.
# The not_if should really just be `Get-Command couchdb-bootstrap`
powershell_script 'install_couchdb_bootstrap' do
  # See nodejs_deploy.rb for a longer explanation of this insanity.
  code "$env:USERPROFILE = \"#{node['nodejs']['sysprof']}\";" \
  "$env:NPM_CONFIG_PREFIX = \"#{node['nodejs']['npm']['home']}\";" \
  "$env:NPM_CONFIG_CACHE = \"#{node['nodejs']['npm']['cache']}\";" \
  "npm install -g --loglevel error couchdb-bootstrap;"
  cwd "#{work}/couchdb"
  action :run
  not_if 'Get-Command couchdb-bootstrap'
end

admin = node['admin_users'][0]
username = admin['username']
password = admin['password']

port = node['couchdb']['port']

# Run couchdb-bootstrap on our folder structure.
# TODO: Figure out better npm path solution
powershell_script 'bootstrap' do
  code "couchdb-bootstrap http://#{username}:#{password}@localhost:#{port}"
  cwd "#{work}/couchdb"
  action :run
end
