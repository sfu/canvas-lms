require_relative '../spec_helper'

describe AmaintController do

  # def account_with_admin_logged_in(opts = {})
  #   account_with_admin(opts)
  #   user_session(@admin)
  # end
  #
  # def account_with_admin(opts = {})
  #   @account = opts[:account] || Account.default
  #   account_admin_user(account: @account)
  # end

  describe 'GET #course_info' do
    before :each do
      course_with_teacher_logged_in
      @course.update_attribute(:sis_source_id, '9999-test-100')
    end

    it 'should be successful' do
      get :course_info, :sis_id => '9999-test-100-d100', :format => :json
      expect(response).to have_http_status(:success)
    end

    it 'should be a course with sis_source_id 9999-test-100-d100' do
      get :course_info, :sis_id => '9999-test-100-d100', :format => :json
      expect(json_parse['sis_source_id']).to eq('9999-test-100-d100')
    end

    it 'should return sectionTutorials for a course' do
      get :course_info, :sis_id => '9999-test-100-d100', :property => 'sectionTutorials', :format => :json
      expect(json_parse['sectionTutorials']).to include('D101', 'D102', 'D103', 'D104', 'D105', 'D106', 'D107', 'D108', 'D109')
    end

    it 'should return sections for a course' do
      get :course_info, :sis_id => '9999-test-100-d100', :property => 'sections', :format => :json
      expect(json_parse['sections']).to include('D101', 'D102', 'D103', 'D104', 'D105', 'D106', 'D107', 'D108', 'D109', 'D100')
    end

    it 'should return the course title' do
      get :course_info, :sis_id => '9999-test-100-d100', :property => 'title', :format => :json
      expect(json_parse['title']).to eq('Test Course')
    end
  end

  describe 'GET #user_info' do
    before :each do
      account_with_admin_logged_in
    end
    it 'should be successful' do
      get :user_info, :sfu_id => 'kipling', :format => :json
      expect(response).to have_http_status(:success)
    end

    it 'should return sfu_id and roles when no property param passed' do
      get :user_info, :sfu_id => 'kipling', :format => :json
      expect(json_parse.keys).to include('sfu_id', 'roles')
    end

    it 'should return roles when asked' do
      get :user_info, :sfu_id => 'kipling', :property => 'roles', :format => :json
      expect(json_parse).to include('staff','undergrad','alumnus','grad','faculty','other')
    end

    context 'teaching terms' do
      it 'should return teaching terms for user when asked' do
        get :user_info, :sfu_id => 'kipling', :property => 'term', :format => :json
        expect(json_parse.first['peopleSoftCode']).to eq('1157')
      end

      it 'should return 404 for a non-teaching user' do
        get :user_info, :sfu_id => 'inactive', :property => 'term', :format => :json
        expect(response.code).to eq('404')
      end

      it 'should return 404 for a non-enrolled user' do
        get :user_info, :sfu_id => 'none', :property => 'term', :format => :json
        expect(response.code).to eq('404')
      end
    end

    it 'should return two courses for user when asked' do
      get :user_info, :sfu_id => 'kipling', :property => 'term', :filter => '1157', :format => :json
      expect(json_parse.size).to eq(2)
    end

    it 'should return key with name, number, and section in all lower case' do
      get :user_info, :sfu_id => 'kipling', :property => 'term', :filter => '1157', :format => :json
      expect(json_parse.first['key']).to start_with('1157:::test:::100w:::d100:::')
    end

    it 'should return sis_source_id in all lower case' do
      get :user_info, :sfu_id => 'kipling', :property => 'term', :filter => '1157', :format => :json
      expect(json_parse.first['sis_source_id']).to eq('1157-test-100w-d100')
    end
  end
end
