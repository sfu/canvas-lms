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
require_relative '../helpers/google_drive_common'

describe "SFU Privacy Notice" do
  include_context "in-process server selenium tests"
  include SFUCommon
  include CollaborationsCommon
  include GoogleDriveCommon

  before :once do
    set_up_account_with_sfu_brand
  end

  context "on course collaborations page" do
    before :each do
      course_with_teacher_logged_in
      setup_google_drive
      PluginSetting.create!(:name => 'etherpad', :settings => {})
      create_collaboration!('google_docs', 'Google Docs')
    end

    it "should show the PIA notice for Google Docs collabs" do
      get "/courses/#{@course.id}/collaborations"
      # make_full_screen
      f('.add_collaboration_link').click
      select_collaboration_type('Google Docs')
      expect(f('#sfu-google-docs-pia-notice > .SFUPrivacyNotice')).to be_displayed
      expect(f('#sfu-google-docs-pia-notice h1')).to include_text 'Is your Google Docs usage privacy compliant?'
    end

    it "should not show the PIA notice for EtherPad collabs" do
      get "/courses/#{@course.id}/collaborations"
      # make_full_screen
      f('.add_collaboration_link').click
      select_collaboration_type('EtherPad')
      expect(f('#sfu-google-docs-pia-notice > .SFUPrivacyNotice')).not_to be_displayed
    end
  end

  context "on course LTI page" do
    before :each do
      course_with_teacher_logged_in
    end

    it "should show the PIA notice when adding an LTI to a course" do
      get "/courses/#{@course.id}/settings"
      # make_full_screen
      wait_for_ajaximations
      scroll_into_view('#tab-tools-link')
      f("#tab-tools-link").click
      wait_for_ajaximations
      scroll_into_view('.ExternalAppsRoot')
      expect(f('.SFUPrivacyNotice')).to be_displayed
      expect(f('.SFUPrivacyNotice h1')).to include_text 'Is your app privacy compliant?'
    end
  end
end
