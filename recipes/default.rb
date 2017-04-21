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

log 'creating installer directory'

directory node['installers']['dir'] do
  action :create
end

log 'copying ssl certificate and key'

# The app name we're expecting to configure
app_name = node['server']['name']
app = search('aws_opsworks_app', "name:#{app_name}").first

# Only configure SSL if the incoming app name matches our expected app name
# and it wants SSL
if app && app['enable_ssl'] == true
	directory node['certificates']['dir'] do
  		action :create
	end

	# save the certificate
	cert_path = File.join(node['certificates']['dir'], 'server.cert')
	file cert_path do
		content app['ssl_configuration']['certificate']
		sensitive true
	end

	env 'SERVER_CERTIFICATE_FILE' do
		value cert_path
		action :create
	end

	#save the private key
	key_path = File.join(node['certificates']['dir'], 'server.key')
	file key_path do
		content app['ssl_configuration']['private_key']
		sensitive true
	end

	env 'SERVER_KEY_FILE' do
		value key_path
		action :create
	end
end
