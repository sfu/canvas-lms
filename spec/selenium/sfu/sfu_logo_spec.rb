#
# Copyright (C) 2017 - present Simon Fraser University.
#
# This file is part of Simon Fraser University's fork of Canvas.
#
# Canvas is free software: you can redistribute it and/or modify it under
# the terms of the GNU Affero General Public License as published by the Free
# Software Foundation, version 3 of the License.
#
# Canvas is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE. See the GNU Affero General Public License for more
# details.
#
# You should have received a copy of the GNU Affero General Public License along
# with this program. If not, see <http://www.gnu.org/licenses/>.

require_relative '../common'
require_relative '../helpers/sfu_common'

describe 'sfu logo' do
  include_context "in-process server selenium tests"
  include SFUCommon

  before :once do
    set_up_account_with_sfu_brand
    user_with_pseudonym(:name => "Test User", :active_user => true, :username => "testuser@example.com", :account => Account.default)
  end

  before :each do
    user_session(@user)
  end

  it "should use SFU logo on the dashboard page" do
    get '/'
    # sfu.js sets src=/sfu/images/sfu-logo.png, but we can't check for an exact match
    # because selenium gets the src attribute as the full url to the image
    # (http://#{IP_ADDRESS}:#{PORT}/sfu/images/sfu-logo.png)
    expect(f('footer>a>img').attribute('src')).to include '/sfu/images/sfu-logo.png'
  end
end
