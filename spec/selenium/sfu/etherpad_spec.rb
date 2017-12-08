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
require_relative '../helpers/collaborations_common'

describe 'SFU Etherpad' do
  include_context 'in-process server selenium tests'
  include SFUCommon
  include CollaborationsCommon

  before :once do
    set_up_account_with_sfu_brand
  end

  context 'on course collaborations page' do
    before :each do
      course_with_teacher_logged_in
      PluginSetting.create!(:name => 'etherpad', :settings => {})
    end

    it 'should not show the deletion policy warning for EtherPad collabs' do
      get "/courses/#{@course.id}/collaborations"
      select_collaboration_type('EtherPad')
      expect(f('#etherpad_description td')).not_to include_text "EtherPad's deletion policy"
    end
  end
end
