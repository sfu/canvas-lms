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

module Factories
  def enrollment_term_model(opts={})
    @enrollment_term = factory_with_protected_attributes(EnrollmentTerm, valid_enrollment_term_attributes.merge(opts))
  end

  def valid_enrollment_term_attributes
    {
      :name => 'value for name',
      :sis_source_id => 'value for sis id',
      :root_account_id => Account.default.id,
      :start_at => DateTime.now,
      :end_at => DateTime.now + 60.days,
      :workflow_state => 'active'
    }
  end
end
