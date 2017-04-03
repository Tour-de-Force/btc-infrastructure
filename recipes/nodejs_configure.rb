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

log 'configuring an application layer instance'

stack = search('aws_opsworks_stack').first
stack_name = stack['name']

log "stack name: #{stack_name}"

database_layer = search('aws_opsworks_layer', 'shortname:database').first
id = database_layer['layer_id']

log "database layer id: #{id}"

# Start by assuming there is not databsase server instance to connect to
domain = false

# The development stack only supports a single database server instance.
# In this case, connect to it via its private ip. The database server will
# permit connections by security group rule.
if stack_name.include? 'dev'
  instance = search('aws_opsworks_instance', "layer_ids:#{id}").first
  domain = instance['private_ip'] if instance
end

# If there is a database server, set SERVER_COUCH_DOMAIN.
if domain
  log "database server domain: #{domain}"

  env 'SERVER_COUCH_DOMAIN' do
    value domain
    action :create
  end
end

# Restart the service to pull in the modified environment variable
windows_service node['server']['name'] do
  action :restart
end
