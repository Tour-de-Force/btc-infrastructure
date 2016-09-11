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

installers = node['installers']['dir']

node_url = node['nodejs']['url']
node_msi = node['nodejs']['msi']

remote_file "#{installers}/#{node_msi}" do
  source "#{node_url}/#{node_msi}"
  checksum node['nodejs']['checksum']
  action :create
end

# Install Node.js to Program Files
windows_package node['nodejs']['display_name'] do
  source "#{installers}/#{node_msi}"
  action :install
end

# Add Node's home directory to the Windows path, and to Ruby's ENV
windows_path node['nodejs']['home'] do
  action [:remove, :add]
end

# Add Npm's home directory to the Windows path, and to Ruby's ENV
windows_path node['nodejs']['npm']['home'] do
  action [:remove, :add]
end
