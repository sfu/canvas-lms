class StatsController < ApplicationController
  before_filter :require_user
  def index
    @enrollments = enrollment_counts
    @terms = Account.find(2).enrollment_terms.find(:all, :conditions => "workflow_state = 'active'", :order => 'sis_source_id DESC')
    @current_term = current_term
    @courses_for_term = courses_for_term(@current_term.id)
  end

  def courses

    respond_to do |format|

      format.html do
        @courses_for_term = courses_for_term(params[:term_id])
        render :partial => 'courses_table', :content_type => 'text/html'
      end

      format.json do
        aaData = courses_for_term(params[:term_id], "id, sis_source_id, name, course_code, workflow_state")
        aaData.map! do |course|
          [
            course.id,
            course.sis_source_id,
            course.name,
            course.course_code,
            course.workflow_state
          ]
        end
        render :json => { :aaData => aaData }
      end

    end
  end

  def enrollments
    respond_to do |format|
      format.json do
        render :json => {
          "total_enrollments_for_term" => enrollments_for_term(params[:term_id], params[:enrollment_type]),
          "unique_enrollments_for_term" => enrollments_for_term(params[:term_id], params[:enrollment_type], true)
        }
      end
    end
  end


  private
  def current_term
    EnrollmentTerm.find(:all, :conditions => ["workflow_state = 'active' AND (:date BETWEEN start_at AND end_at)", {:date => DateTime.now}]).first
  end

  def courses_for_term(term_id, fields='*')
    if term_id == 'current'
      term_id = current_term
    end
    workflow_state_translation = {
      "available" => "published",
      "claimed" => "unpublished",
      "completed" => "concluded"
    }
    courses = EnrollmentTerm.find(term_id).courses.find(:all, :select => fields, :conditions => ["workflow_state != 'deleted'"])
    courses.each { |course| course[:workflow_state] = workflow_state_translation[course[:workflow_state]] }
  end


end