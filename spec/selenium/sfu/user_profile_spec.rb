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

describe 'user profile' do
  include_context "in-process server selenium tests"
  include SFUCommon

  before :once do
    set_up_account_with_sfu_brand
    user_with_pseudonym(:name => "Test User", :active_user => true, :username => "testuser@example.com", :account => Account.default)
  end

  before :each do
    user_session(@user)
  end

  context "for a user" do
    it "should see modified short_name help text" do
      get "/profile/settings"
      expect(f('#hints_short_name')).to include_text 'Changing this will only affect your display name within Canvas, and not in other systems'
    end

    it "should only be able to edit their display name" do
      get "/profile/settings"
      scroll_into_view('.edit_settings_link')
      f('.edit_settings_link').click
      expect(f('input#user_name')).not_to be_displayed
      expect(f('input#user_sortable_name')).not_to be_displayed
      expect(f('input#user_short_name')).to be_displayed
    end

    it "should not show the email subscription checkbox" do
      get "/profile/settings"
      scroll_into_view('.edit_settings_link')
      f('.edit_settings_link').click
      expect(f('#user_subscribe_to_emails')).not_to be_displayed
    end
  end
end
