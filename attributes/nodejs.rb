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

nodejs_version = '4.2.1'

# <> Version of Node.js to install
normal['nodejs']['version'] = nodejs_version

# <> Filename of the Node.js MSI
normal['nodejs']['msi'] = "node-v#{nodejs_version}-x64.msi"

# <> Base URL at which to find the Node.js MSI
normal['nodejs']['url'] = "https://nodejs.org/dist/v#{nodejs_version}"

hash = 'e460a71ea9aa4d743387a20319042de203de837cb613be0737b6ca368480302d'

# <> sha256 checksum of the MSI
normal['nodejs']['checksum'] = hash

# Node.js (and npm.cmd) home directory
normal['nodejs']['home'] = 'C:\\Program Files\\nodejs'

# Node.js executable
normal['nodejs']['node.exe'] = 'C:\\Program Files\\nodejs\\node.exe'

# Node.js executable display name (as in the Uninstall registry key)
normal['nodejs']['display_name'] = 'Node.js'

# Npm (global modules) home directory
normal['nodejs']['npm']['home'] = 'C:\\npm'

# Npm (global modules) cache directory
normal['nodejs']['npm']['cache'] = 'C:\\npm-cache'

# Somewhere outside System32 for the Workgroup\System user profile
# We set this as an environment variable before running npm.
# Being inside System32 makes node-gyp's .node-gyp folder unusable by itself.
# This whole situation is bizzare, but that's how it is.
normal['nodejs']['sysprof'] = 'C:\\sysprof'
