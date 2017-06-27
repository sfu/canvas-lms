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


=begin

  * create terms
  * create a bunch of teachers
  * create a bunch of students
  * create a bunch of credit courses
  * add students and teachers to courses
  * add courses to terms
  * check the quickstats boxes
  * check the table

=end


require File.expand_path(File.dirname(__FILE__) + '../../../../../../spec/selenium/common')
require File.expand_path(File.dirname(__FILE__) + '../../../../../../spec/selenium/helpers/sfu_common')

describe "SFU Stats Page" do
  include_context "in-process server selenium tests"
  include SFUCommon

  STATS_PAGE = '/sfu/stats'

  before :once do
    create_sfu_terms
  end

  it "should load the page" do
    user_session(user_with_pseudonym(:name => "Test User", :active_user => true, :username => "testuser@example.com", :account => Account.default))
    get STATS_PAGE
    expect(driver.title).to eq 'Canvas Stats'
  end


end
