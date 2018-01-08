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

describe 'External users' do
  include_context 'in-process server selenium tests'
  include SFUCommon

  before :once do
    set_up_account_with_sfu_brand
    @user = user_with_communication_channel(:user_state => 'creation_pending')
  end

  context 'registration page' do
    # This ensures those settings affect the links on the registration page, but not whether it's being done.
    it 'should link to correct URLs if customized in Setting' do
      terms_of_use_url = 'http://www.sfu.ca/contact/terms-conditions.html'
      privacy_policy_url = 'http://www.sfu.ca/contact/terms-conditions/privacy.html'
      Setting.set('terms_of_use_url', terms_of_use_url)
      Setting.set('privacy_policy_url', privacy_policy_url)

      get "/register/#{@user.communication_channel.confirmation_code}"
      expect(f('label[for="user_terms_of_use"] a:nth-of-type(1)')).to have_attribute('href', terms_of_use_url)
      expect(f('label[for="user_terms_of_use"] a:nth-of-type(2)')).to have_attribute('href', privacy_policy_url)
    end

    it 'should not show the email subscription checkbox' do
      get "/register/#{@user.communication_channel.confirmation_code}"
      expect(f('label[for="user_subscribe_to_emails"]')).not_to be_displayed
    end
  end
end
