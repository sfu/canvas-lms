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

describe 'Class roster' do
  include_context 'in-process server selenium tests'

  context 'as a teacher' do
    before(:each) do
      RoleOverride.create!(:context => Account.default, :permission => 'read_sis', :role => teacher_role, :enabled => true)

      course_with_teacher_logged_in

      @course.enroll_student(
        user_with_managed_pseudonym({
          name: 'Bar Baz Bah',
          short_name: 'Bar Bah',
          username: 'barbah',
          sis_user_id: '123456789',
          active_all: true,
          account: Account.default
        }),
        { :enrollment_state => 'active' }
      )

      @course.enroll_student(
        user_with_managed_pseudonym({
          name: 'Foo Fu',
          username: 'foofu',
          sis_user_id: '987654321',
          active_all: true,
          account: Account.default
        }),
        { :enrollment_state => 'active' }
      )
    end

    it 'should contain both full and display names' do
      get "/courses/#{@course.id}/users"
      wait_for_ajaximations
      element = f('tr.rosterUser:nth-of-type(1) > td:nth-child(2) > a.roster_user_name')
      expect(element).to include_text 'Bar Baz Bah'
      expect(element).to include_text '(Bar Bah)'
    end

    it 'should contain full names only for students without display names' do
      get "/courses/#{@course.id}/users"
      wait_for_ajaximations
      element = f('tr.rosterUser:nth-of-type(2) > td:nth-child(2) > a.roster_user_name')
      expect(element).to include_text 'Foo Fu'
      expect(element).not_to include_text '('
    end
  end
end
