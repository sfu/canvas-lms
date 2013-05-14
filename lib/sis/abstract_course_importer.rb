#
# Copyright (C) 2011 Instructure, Inc.
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

module SIS
  class AbstractCourseImporter < BaseImporter

    def process
      start = Time.now
      importer = Work.new(@batch_id, @root_account, @logger)
      AbstractCourse.process_as_sis(@sis_options) do
        yield importer
      end
      AbstractCourse.where(:id => importer.abstract_courses_to_update_sis_batch_id).update_all(:sis_batch_id => @batch_id) if @batch_id && !importer.abstract_courses_to_update_sis_batch_id.empty?
      @logger.debug("AbstractCourses took #{Time.now - start} seconds")
      return importer.success_count
    end

  private
    class Work
      attr_accessor :success_count, :abstract_courses_to_update_sis_batch_id

      def initialize(batch_id, root_account, logger)
        @batch_id = batch_id
        @root_account = root_account
        @abstract_courses_to_update_sis_batch_id = []
        @logger = logger
        @success_count = 0
      end

      def add_abstract_course(abstract_course_id, short_name, long_name, status, term_id=nil, account_id=nil, fallback_account_id=nil)
        @logger.debug("Processing AbstractCourse #{[abstract_course_id, short_name, long_name, status, term_id, account_id, fallback_account_id].inspect}")

        raise ImportError, "No abstract_course_id given for an abstract course" if abstract_course_id.blank?
        raise ImportError, "No short_name given for abstract course #{abstract_course_id}" if short_name.blank?
        raise ImportError, "No long_name given for abstract course #{abstract_course_id}" if long_name.blank?
        raise ImportError, "Improper status \"#{status}\" for abstract course #{abstract_course_id}" unless status =~ /\Aactive|\Adeleted/i

        course = AbstractCourse.find_by_root_account_id_and_sis_source_id(@root_account.id, abstract_course_id)
        course ||= AbstractCourse.new
        term = course.stuck_sis_fields.include?(:enrollment_term_id) ? nil : @root_account.enrollment_terms.find_by_sis_source_id(term_id)
        course.enrollment_term = term if term
        course.root_account = @root_account

        account = nil
        account = Account.find_by_root_account_id_and_sis_source_id(@root_account.id, account_id) if account_id.present?
        account ||= Account.find_by_root_account_id_and_sis_source_id(@root_account.id, fallback_account_id) if fallback_account_id.present?
        course.account = account if account
        course.account ||= @root_account

        # only update the name/short_name on new records, and ones that haven't been changed
        # since the last sis import
        course.name = long_name if long_name.present? && (course.new_record? || (!course.stuck_sis_fields.include?(:name)))
        course.short_name = short_name if short_name.present? && (course.new_record? || (!course.stuck_sis_fields.include?(:short_name)))

        course.sis_source_id = abstract_course_id
        if status =~ /active/i
          course.workflow_state = 'active'
        elsif status =~ /deleted/i
          course.workflow_state = 'deleted'
        end

        if course.changed?
          course.sis_batch_id = @batch_id if @batch_id
          course.save!
        elsif @batch_id
          @abstract_courses_to_update_sis_batch_id << course.id
        end
        @success_count += 1
      end

    end

  end
end
