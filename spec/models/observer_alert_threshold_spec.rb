#
# Copyright (C) 2018 - present Instructure, Inc.
#
# This file is part of Canvas.
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

require_relative '../spec_helper'

describe ObserverAlertThreshold do
  before :once do
    @student = user_model
    @observer = user_model
    UserObservationLink.create(student: @student, observer: @observer)
  end

  it 'can link to an user_observation_link' do
    threshold = ObserverAlertThreshold.create(student: @student, observer: @observer, alert_type: 'assignment_missing')

    expect(threshold.valid?).to eq true
    expect(threshold.user_id).not_to be_nil
    expect(threshold.observer_id).not_to be_nil
  end

  it 'wont allow random alert_type' do
    threshold = ObserverAlertThreshold.create(student: @student, observer: @observer, alert_type: 'jigglypuff')

    expect(threshold.valid?).to eq false
  end

  it 'observer must be linked to student' do
    threshold = ObserverAlertThreshold.create(student: user_model, observer: @observer, alert_type: 'assignment_missing')

    expect(threshold.valid?).to eq false
  end
end
