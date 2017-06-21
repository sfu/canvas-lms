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

require File.expand_path(File.dirname(__FILE__) + '../../../../../../spec/selenium/common')

describe "SFU Course Form" do
  include_context "in-process server selenium tests"

  COURSE_FORM = '/sfu/course/new'

  before do
    # create admin user with oauth token
    @admin = account_admin_user
    pseudonym_model({:user => @admin})
    @admin_access_token = @admin.access_tokens.create!(:purpose => "test").full_token
    allow(SFU::REST).to receive(:canvas_oauth_token).and_return(@admin_access_token)

    # enable SIS imports
    Account.default[:allow_sis_import] = true
    Account.default.save

    # add sfu terms - should be an external helper eventually
    terms_file = File.expand_path("#{File.dirname(__FILE__)}../../../../../../spec/fixtures/sfu_terms.json")
    terms = JSON.parse(File.read(terms_file))
    terms.map! { |t| t['enrollment_term'] }
    terms.delete_if { |t| t['name'] == 'Default Term' }
    terms.each do |t|
      enrollment_term_model({
        :name => t['name'],
        :sis_source_id => t['sis_source_id'],
        :start_at => t['start_at'],
        :end_at => t['end_at'],
        :workflow_state => 'active'
      })

      # stub out SFU::REST#canvas_server
      allow(SFU::REST).to receive(:canvas_server).and_return("http://#{SeleniumDriverSetup.app_host_and_port}")
    end

  end

  context "as an authorized user" do

    before do
      # create user with managed pseudonum (testcnvs)
      @testcnvs = user_with_managed_pseudonym({
        name: 'Canvas Testing',
        username: 'testcnvs',
        unique_id: 'testcnvs@sfu.ca',
        sis_user_id: '000028225'
      })
    end

    before (:each) do
      user_session(@testcnvs)
    end

    it "should load the page" do
      get COURSE_FORM
      expect(f('#breadcrumbs li:nth-of-type(2) > span')).to include_text 'Start a New Course'
    end
  end

end
