#
# Copyright (C) 2013 Instructure, Inc.
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
#

module Api::V1::GradeChangeEvent
  include Api
  include Api::V1::User
  include Api::V1::Course
  include Api::V1::Assignment
  include Api::V1::Submission
  include Api::V1::PageView

  def grade_change_event_json(event, user, session)
    links = {
      :assignment => Shard.relative_id_for(event.assignment_id),
      :course => Shard.relative_id_for(event.course_id),
      :student => Shard.relative_id_for(event.student_id),
      :grader => Shard.relative_id_for(event.grader_id),
      :page_view => event.page_view.nil? ? nil : event.request_id
    }

    {
      :id => event.id,
      :created_at => event.created_at.in_time_zone,
      :event_type => event.event_type,
      :grade_before => event.grade_before,
      :grade_after => event.grade_after,
      :version_number => event.version_number,
      :request_id => event.request_id,
      :links => links
    }
  end

  def grade_change_events_json(events, user, session)
    events.map{ |event| grade_change_event_json(event, user, session) }
  end

  def grade_change_events_compound_json(events, user, session)
    course_ids = events.map{ |event| event.course_id }
    courses = Course.find_all_by_id(course_ids) if course_ids.length > 0
    courses ||= []

    assignment_ids = events.map{ |event| event.assignment_id }
    assignments = Assignment.find_all_by_id(assignment_ids) if assignment_ids.length > 0
    assignments ||= []

    user_ids = events.map{ |event| event.grader_id }
    user_ids.concat(events.map{ |event| event.student_id })
    users = User.find_all_by_id(user_ids) if user_ids.length > 0
    users ||= []

    page_view_ids = events.map{ |event| event.request_id }
    page_views = PageView.find_all_by_id(page_view_ids) if page_view_ids.length > 0
    page_views ||= []

    {
      meta: { primaryCollection: 'events' },
      events: grade_change_events_json(events, user, session),
      page_views: page_views_json(page_views, user, session),
      assignments: assignments_json(assignments, user, session),
      courses: courses_json(courses, user, session, [], []),
      users: users_json(users, user, session, [], @domain_root_account)
    }
  end
end
