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

# <> Directory at which to store installer files
normal['installers']['dir'] = 'C:\Installers'

# <> Directory at which to store application files
normal['server']['dir'] = 'C:\Server'

# <> Directory in which to perform other work related to chef
normal['work']['dir'] = 'C:\Work'

# <> Directory in which to store certificate related files
normal['certificates']['dir'] = 'C:\Certificates'

# <> Array of admin users as {:username, :password} hashes
default['admin_users'] = []
