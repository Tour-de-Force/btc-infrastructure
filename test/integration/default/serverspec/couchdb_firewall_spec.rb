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

require 'serverspec'

set :backend, :cmd
set :os, family: 'windows'

def fwregex(key, val)
  /#{key}:\s*#{val}/
end

describe 'Database Server Firewall' do
  describe command("netsh advfirewall firewall show rule 'Apache CouchDB'") do
    its(:exit_status) { should eq 0 }
    its(:stdout) { should match fwregex('Enabled',    'Yes') }
    its(:stdout) { should match fwregex('Direction',  'In') }
    its(:stdout) { should match fwregex('LocalIP',    'Any') }
    its(:stdout) { should match fwregex('RemoteIP',   'Any') }
    its(:stdout) { should match fwregex('RemoteIP',   'Any') }
    its(:stdout) { should match fwregex('Protocol',   'TCP') }
    its(:stdout) { should match fwregex('LocalPort',  '5984') }
    its(:stdout) { should match fwregex('RemotePort', 'Any') }
    its(:stdout) { should match fwregex('Action',     'Allow') }
  end
end
