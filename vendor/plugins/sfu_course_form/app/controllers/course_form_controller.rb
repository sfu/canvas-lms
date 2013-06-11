require Pathname(File.dirname(__FILE__)) + "../../../sfu_api/app/model/sfu/sfu"

class CourseFormController < ApplicationController

  def new
    @user = User.find(@current_user.id)
    @sfuid = @user.pseudonym.unique_id
    @sfuid.slice! "@sfu.ca"
    @course_list = Array.new
    @terms = current_term.concat future_terms
    @current_term = current_term
    if SFU::User.student_only? @sfuid
      flash[:error] = "You don't have permission to access that page"
      redirect_to dashboard_url
    end
  end

  def create
    selected_courses = []
    account_id = Account.find_by_name("Simon Fraser University").id
    teacher_username = params[:username]
    teacher2_username = params[:enroll_me]
    teacher_sis_user_id = sis_user_id(teacher_username, account_id)
    teacher2_sis_user_id = sis_user_id(teacher2_username, account_id) unless teacher2_username.nil?
    cross_list = params[:cross_list]

    params.each do |key, value|
      if key.to_s.starts_with? "selected_course"
        selected_courses.push value
      end
    end

    course_array = ["\"course_id\",\"short_name\",\"long_name\",\"account_id\",\"term_id\",\"status\""]
    section_array = ["\"section_id\",\"course_id\",\"name\",\"status\",\"start_date\",\"end_date\""]
    enrollment_array = ["\"course_id\",\"user_id\",\"role\",\"section_id\",\"status\""]

    unless cross_list

      selected_courses.compact.uniq.each do |course|
        unless course.starts_with? "sandbox"
          logger.info "[SFU Course Form] Creating single course container : #{course}"
          course_info = course_info(course, account_id, teacher_sis_user_id, teacher2_sis_user_id)

          # create course csv
          course_array.push course_info["course_csv"]

          # create section csv
          course_info["sections"].compact.uniq.each do  |section|
            section_info = section.split(":_:")
            section_array.push "#{section_info[0]},#{course_info["course_id"]},#{section_info[1]},active,,,"
          end

          enrollment_array.push course_info["enrollment_csv_1"]
          enrollment_array.push course_info["enrollment_csv_2"] unless teacher2_username.nil?

        else
          logger.info "[SFU Course Form] Creating sandbox for #{teacher_username}"
          sandbox = sandbox_info(course, teacher_username, teacher_sis_user_id, teacher2_sis_user_id)

          course_array.push sandbox["csv"]
          enrollment_array.push sandbox["enrollment_csv_1"]
          enrollment_array.push sandbox["enrollment_csv_2"] unless teacher2_sis_user_id.nil?
        end
      end

    else

      logger.info "[SFU Course Form] Creating cross-list container : #{selected_courses.inspect}"
      course_id = ""
      short_name = ""
      long_name = ""
      term = ""
      sections = []

      selected_courses.each do |course|
        course_info = course_info(course, account_id, teacher_sis_user_id, teacher2_sis_user_id)

        course_id.concat "#{course_info["course_id"]}:"
        short_name.concat "#{course_info["short_name"]} / "
        long_name.concat  "#{course_info["long_name"]} / "
        term = course_info["term"]

        sections.push course_info["sections"]
      end

      # create course csv
      course_id.concat "::course"
      course_array.push "\"#{course_id}\",\"#{short_name[0..-4]}\",\"#{long_name[0..-4]}\",\"#{account_id}\",\"#{term}\",\"active\""

      # create section csv
      sections.compact.uniq.each do  |section|
        section_info = section.first.split(":_:")
        section_array.push "\"#{section_info[0]}\",\"#{course_id}\",\"#{section_info[1]}\",\"active\",\"\",\"\","
      end

      # create enrollment csv to default section
      enrollment_array.push "\"#{course_id}\",\"#{teacher_sis_user_id}\",\"teacher\",\"\",\"active\"\n"
      enrollment_array.push "\"#{course_id}\",\"#{teacher2_sis_user_id}\",\"teacher\",\"\",\"active\"\n" unless teacher2_sis_user_id.nil?

    end

    unless teacher_sis_user_id.nil?
      # Send POST to import
      course_csv = course_array.join("\n")
      section_csv = section_array.join("\n")
      enrollment_csv = enrollment_array.join("\n")

      logger.info "[SFU Course Form] course_csv: #{course_csv.inspect}"
      SFU::Canvas.sis_import course_csv

      logger.info "[SFU Course Form] section_csv: #{section_csv.inspect}"
      SFU::Canvas.sis_import section_csv

      logger.info "[SFU Course Form] enrollment_csv: #{enrollment_csv.inspect}"
      SFU::Canvas.sis_import enrollment_csv

      # give some time for the delayed_jobs to process the import
      sleep 5
      flash[:notice] = "Course request submitted successfully"
    else
      flash[:error] = "Course request failed. Please try agin."
      redirect_to "/sfu/course/new"
    end

  end

  def course_info(course_line, account_id, teacher1, teacher2 = nil)
    # Example; course_line = 1131:::ensc:::351:::d100:::Real Time and Embedded Systems
    course = {}
    sections = []
    course_arr = course_line.split(":::")
    course["term"] = course_arr[0]
    course["name"] = course_arr[1].to_s
    course["number"] = course_arr[2]
    course["section_name"] = course_arr[3].to_s
    course["title"] = course_arr[4].to_s
    course["section_tutorials"] = course_arr[5]

    course["course_id"] = "#{course["term"]}-#{course["name"]}-#{course["number"]}-#{course["section_name"]}"
    course["section_id"] = "#{course["term"]}-#{course["name"]}-#{course["number"]}-#{course["section_name"]}:::#{time_stamp}"
    course["short_name"] = "#{course["name"].upcase}#{course["number"]} #{course["section_name"].upcase}"
    course["long_name"] =  "#{course["short_name"]} #{course["title"]}"
    # Default Section set D100, D200, E300, G800 or if only 1 section (i.e. no section tutorials)
    course["default_section_id"] = course["section_id"] if course["section_name"].end_with? "00" || course["section_tutorials"].nil?

    course["course_csv"] = "\"#{course["course_id"]}\",\"#{course["short_name"]}\",\"#{course["long_name"]}\",\"#{account_id}\",\"#{course["term"]}\",\"active\""
    course["enrollment_csv_1"] = "\"#{course["course_id"]}\",\"#{teacher1}\",\"teacher\",\"#{course["default_section_id"]}\",\"active\""
    course["enrollment_csv_2"] = "\"#{course["course_id"]}\",\"#{teacher2}\",\"teacher\",\"#{course["default_section_id"]}\",\"active\"" unless teacher2.nil?

    sections.push "#{course["section_id"]}:_:#{course["name"].upcase}#{course["number"]} #{course["section_name"].upcase}"

    # add section tutorials csv
    unless course["section_tutorials"].nil?
      course["section_tutorials"].split(",").compact.uniq.each do |tutorial_name|
        section_id = "#{course["term"]}-#{course["name"]}-#{course["number"]}-#{tutorial_name.downcase}:::#{time_stamp}"
        sections.push "#{section_id}:_:#{course["name"].upcase}#{course["number"]} #{tutorial_name.upcase}"
      end
    end

    course["sections"] = sections

    course
  end

  def sandbox_info(course_line, username, teacher1, teacher2 = nil)
    account_sis_id = "sfu:::sandbox:::instructors"
    course_arr = course_line.split("-")
    sandbox = {}
    sandbox["course_id"] = course_line
    sandbox["short_long_name"] = "Sandbox - #{username} - #{course_arr.last}"
    sandbox["default_section_id"] = ""

    sandbox["csv"] = "\"#{sandbox["course_id"]}\",\"#{sandbox["short_long_name"]}\",\"#{sandbox["short_long_name"]}\",\"#{account_sis_id}\",\"\",\"active\""
    sandbox["enrollment_csv_1"] = "\"#{sandbox["course_id"]}\",\"#{teacher1}\",\"teacher\",\"#{sandbox["default_section_id"]}\",\"active\""
    sandbox["enrollment_csv_1"] = "\"#{sandbox["course_id"]}\",\"#{teacher2}\",\"teacher\",\"#{sandbox["default_section_id"]}\",\"active\"" unless teacher2.nil?
    sandbox
  end

  def sis_user_id(username, account_id)
    user = Pseudonym.find_by_unique_id_and_account_id(username, account_id)
    user.sis_user_id unless user.nil?
  end

  def current_term
    EnrollmentTerm.find(:all, :conditions => ["workflow_state = 'active' AND (:date BETWEEN start_at AND end_at)", {:date => Date.today}])
  end

  def future_terms
    EnrollmentTerm.find(:all, :conditions => ["workflow_state = 'active' AND (:date <= start_at)", {:date => Date.today}], :order => 'sis_source_id')
  end

  def time_stamp
    t = Time.new
    "#{t.day}#{t.month}#{t.year}#{t.min}#{t.sec}"
  end

end
