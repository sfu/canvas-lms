require Pathname(File.dirname(__FILE__)) + '../../../sfu_api/app/model/sfu/sfu'

class CopyrightController < ApplicationController
  before_filter :require_user, :except => [:disclaimer]

  def disclaimer
    render :layout => 'bare'
  end

  def query
    # Allow white-listed users only
    current_username = @current_user.pseudonym.unique_id.gsub '@sfu.ca', ''
    unless SFU::User.belongs_to_maillist? current_username, 'canvas-copyright-survey-admins'
      return render_unauthorized_action
    end

    # Start with the term
    term = EnrollmentTerm.find_by_sis_source_id(params[:term])
    unless term
      render :json => { :errors => 'The specified term does not exist.' }, :status => :unprocessable_entity
      return
    end

    # Find all the active courses in the specified term
    courses = term.courses.active.where(account_id: Account.default.id)
    if courses.count == 0
      render :json => { :errors => 'No courses found in the specified term.' }, :status => :unprocessable_entity
      return
    end

    # Randomly select a course and instructor
    course = courses.rand
    teacher = course.teachers.rand

    # Determine the SFU Computing ID and email address of the instructor
    # NOTE: The course could (very rarely) be teacher-less
    if teacher
      computing_id = teacher.pseudonyms.active.first.try(:unique_id)
      email = computing_id ? "#{computing_id}@sfu.ca" : nil
    end

    output = {}
    output[:course] = { id: course.id, name: course.name, term: course.enrollment_term.name }
    output[:teacher] = teacher ? { id: teacher.id, name: teacher.name, computing_id: computing_id, email: email } : nil

    # Only include current files, and filter out OS meta files
    files = course.attachments.active.reject do |file|
      file.folder.full_name.include?('__MACOSX') ||
      file.display_name == '.DS_Store'
    end

    output[:files] = files.map do |attachment|
      {
        'id' => attachment.id,
        'content-type' => attachment.content_type,
        'display_name' => attachment.display_name,
        'filename' => attachment.filename,
        'size' => attachment.size,
        'created_at' => attachment.created_at,
        'updated_at' => attachment.updated_at,
        'folder_name' => attachment.folder.full_name
      }
    end

    render :json => output
  end
end
