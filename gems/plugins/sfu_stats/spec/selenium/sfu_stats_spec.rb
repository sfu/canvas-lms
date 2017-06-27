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
require File.expand_path(File.dirname(__FILE__) + '../../../../../../spec/selenium/helpers/sfu_common')

describe "SFU Stats Page" do
  include_context "in-process server selenium tests"
  include SFUCommon

  STATS_PAGE = '/sfu/stats'

  before :once do
    create_sfu_terms
    @current_term = current_sfu_term
    @previous_term = prev_sfu_term

    courses = create_courses(
      [
        {
          name: "TEST 100 - Introduction to Testing",
          course_code: "TEST100 D100",
          enrollment_term_id: @current_term.id,
          sis_source_id: "#{@current_term.sis_source_id}-test-100-d100"
        },
        {
          name: "TEST 200 - Intermediate Testing Techniques",
          course_code: "TEST200 D100",
          enrollment_term_id: @current_term.id,
          sis_source_id: "#{@current_term.sis_source_id}-test-200-d100"
        },
        {
          name: "TEST 300 - Advanced Testing",
          course_code: "TEST300 D100",
          enrollment_term_id: @current_term.id,
          sis_source_id: "#{@current_term.sis_source_id}-test-300-d100"
        },
        {
          name: "TEST 400 - Testing Seminar",
          course_code: "TEST400 D100",
          enrollment_term_id: @current_term.id,
          sis_source_id: "#{@current_term.sis_source_id}-test-400-d100"
        },
      ]
    )

    courses.each do |course|
      course = Course.find course
      teacher_in_course({ :course => course })
      ta_in_course({ :course => course })
      n_students_in_course(20, { :course => course })
    end
  end

  before :each do
    user_session(user_with_pseudonym(:name => "Test User", :active_user => true, :username => "testuser@example.com", :account => Account.default))
  end

  context "page load" do
    it "should load the page" do
      get STATS_PAGE
      expect(driver.title).to eq 'Canvas Stats'
    end
  end

  context "quickstats" do
    it "should show enrollment numbers > 0 in the quickstats boxes for the current term" do
      get STATS_PAGE
      wait_for_ajax_requests
      expect(f('#quickstats .stats_enrollment_box:nth-of-type(1) > .enrollment_number').text).to eq('80')
      expect(f('#quickstats .stats_enrollment_box:nth-of-type(2) > .enrollment_number').text).to eq('80')
      expect(f('#quickstats .stats_enrollment_box:nth-of-type(3) > .enrollment_number').text).to eq('4')
      expect(f('#quickstats .stats_enrollment_box:nth-of-type(4) > .enrollment_number').text).to eq('4')
    end

    it "should show 0 enrollments in the quickstats boxes for the previous term" do
      get STATS_PAGE
      wait_for_ajax_requests
      dropdown = f('#quickstats .stats_enrollment_box:nth-of-type(1) > .enrollment_term_switcher > select')
      options = dropdown.find_elements(tag_name: 'option')
      options.each { |option| option.click if option.text == @previous_term.name}
      wait_for_ajax_requests
      expect(f('#quickstats .stats_enrollment_box:nth-of-type(1) > .enrollment_number').text).to eq('0')
    end
  end

  context "course table" do
    it "should show four courses in the table for the current term" do
      get STATS_PAGE
      wait_for_ajax_requests
      expect(f('#DataTables_Table_0_info')).to include_text 'Showing 4 courses'
    end
  end

  it "should filter the course list by search" do
    get STATS_PAGE
    wait_for_ajax_requests
    f('#course_filter_search input').send_keys 'test'
    expect(f('#DataTables_Table_0_info')).to include_text 'Showing 4 courses'
    f('#course_filter_search input').clear
    f('#course_filter_search input').send_keys 'test100'
    sleep 1
    expect(f('#DataTables_Table_0_info')).to include_text 'Showing 1 courses (filtered from 4 courses)'
  end

  it "should filter the course list by term select" do
    get STATS_PAGE
    wait_for_ajax_requests
    dropdown = f('#term_select')
    options = dropdown.find_elements(tag_name: 'option')
    options.each { |option| option.click if option.text == @previous_term.name}
    wait_for_ajax_requests
    expect(f('#course_table tbody>tr>td')).to include_text 'No matching courses found'
  end

end
