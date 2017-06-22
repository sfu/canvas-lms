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

describe "SIS ID Column in Gradebook" do
  include_context "in-process server selenium tests"

  context "as a teacher" do
    before(:each) do
      RoleOverride.create!(:context => Account.default, :permission => 'read_sis', :role => teacher_role, :enabled => true)

      course_with_teacher_logged_in

      @course.enroll_student(
        user_with_managed_pseudonym({
          name: 'Bar Bar',
          username: 'barbar',
          sis_user_id: '987654321',
          active_all: true,
          account: Account.default
        }),
        { :enrollment_state => 'active' }
      )

      @course.enroll_student(
        user_with_managed_pseudonym({
          name: 'Foo Foo',
          username: 'foofoo',
          sis_user_id: '123456789',
          active_all: true,
          account: Account.default
        }),
        { :enrollment_state => 'active' }
      )

      2.times do |i|
        @course.assignments.create!(
          title: "Assignment #{i}",
          grading_type: 'points',
          points_possible: 10,
          submission_types: 'online_text_entry',
          due_at: 2.days.ago,
          assignment_group: @course.assignment_groups.first
        )
      end

      driver.manage.window.maximize
    end

    it "should have a SIS ID column in the gradebook" do
      get "/courses/#{@course.id}/gradebook"
      wait_for_ajaximations
      expect(f('.slick-header-columns div:nth-of-type(3)')).to include_text 'SIS ID'
      expect(f('.slick-row:nth-of-type(1)>div:nth-child(2).secondary_identifier_cell')).to include_text 'barbar'
      expect(f('.slick-row:nth-of-type(1)>div:nth-child(3).secondary_identifier_cell')).to include_text '987654321'
    end

    it "should sort the gradebook by SIS ID when clicked" do
      get "/courses/#{@course.id}/gradebook"
      wait_for_ajaximations
      f('div[id$=sis_id]').click
      expect(f('.slick-row:nth-of-type(1)>div:nth-child(2).secondary_identifier_cell')).to include_text 'foofoo'
      expect(f('.slick-row:nth-of-type(1)>div:nth-child(3).secondary_identifier_cell')).to include_text '123456789'
    end

    it "should search the gradebook by SIS ID" do
      get "/courses/#{@course.id}/gradebook"
      wait_for_ajaximations
      f('.gradebook_filter input').send_keys '123456789'
      sleep 1 #InputFilter has a delay
      expect(f('.slick-row:nth-of-type(1)>div:nth-child(2).secondary_identifier_cell')).to include_text 'foofoo'
      expect(f('.slick-row:nth-of-type(1)>div:nth-child(3).secondary_identifier_cell')).to include_text '123456789'
    end

    it "should move the Total column to the immediate right of the SIS ID column" do
      get "/courses/#{@course.id}/gradebook"
      wait_for_ajaximations
      f('#total_dropdown').click
      f('.move_column').click
      sleep 1
      expect(f('.slick-header-columns div:nth-of-type(3)')).to include_text 'SIS ID'
      expect(f('.slick-header-columns div:nth-of-type(4)')).to include_text 'Total'
    end
  end
end
