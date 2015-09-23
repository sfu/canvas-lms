require_relative '../spec_helper'

describe ApiController do
  before :each do
    account_with_admin_logged_in
    user_with_pseudonym({
       :name => 'Rudyard Kipling',
       :short_name => 'Rudy',
       :unique_id => 'kipling@sfu.ca',
       :username => 'kipling'
    })
    group_with_user({
      :user => @user,
      :name => 'Test Group'
    })
    term = enrollment_term_model(:name => 'Current Term', :sis_source_id => '9999')

    @enrollment1 = course_with_student({ :user => @user, :enrollment_term => term, :active_all => true })
    @course1 = @enrollment1.course
    @course1.update_attribute(:sis_source_id, '9999-test-100')
    @course1.update_attribute(:enrollment_term_id, term.id)
    @section1 = @course1.course_sections.create!(:name => 'D101')
    @section2 = @course1.course_sections.create!(:name => 'D102')
    @enrollment1.update_attribute(:course_section_id, @section1.id)

    @enrollment2 = course_with_teacher({ :user => @user, :enrollment_term => term, :active_all => true })
    @course2 = @enrollment2.course
    @course2.update_attribute(:sis_source_id, '9999-test-200')
    @course2.update_attribute(:enrollment_term_id, term.id)

    @sandbox = course_with_teacher({ :user => @user, :active_all => true })
    @sandbox.course.update_attribute(:sis_source_id, 'sandbox 12345' )
  end

  describe 'GET #user' do
    it 'should be successful' do
      get :user, :sfu_id => :kipling, :format => :json
      expect(response).to have_http_status(:success)
    end

    it 'should return exists:true with no properties passed' do
      get :user, :sfu_id => :kipling, :format => :json
      expect(json_parse['exists']).to eq('true')
    end

    it 'should return the right fields for profile' do
      get :user, :sfu_id => :kipling, :property => 'profile', :format => :json
      expect(json_parse.keys).to contain_exactly('id', 'uuid', 'name', 'message_user_path')
    end

    it 'should return the user profile' do
      get :user, :sfu_id => :kipling, :property => 'profile', :format => :json
      expect(json_parse['name']).to eq('Rudyard Kipling')
    end

    it 'should return the groups for the user' do
      get :user, :sfu_id => :kipling, :property => 'groups', :format => :json
      expect(json_parse.first['name']).to eq('Test Group')
    end

    it 'should return the right fields for mysfu data' do
      get :user, :sfu_id => :kipling, :property => 'mysfu', :format => :json
      expect(json_parse.keys).to contain_exactly('enrolled', 'teaching')
    end

    it 'should return the right fields for a course' do
      get :user, :sfu_id => :kipling, :property => 'mysfu', :format => :json
      expect(json_parse['enrolled'].first.keys).to contain_exactly('term', 'course_sis_source_id', 'course_id', 'status')
    end

    it 'should return an enrolled course in mysfu data for the user' do
      get :user, :sfu_id => :kipling, :property => 'mysfu', :format => :json
      expect(json_parse['enrolled'].first['course_sis_source_id']).to eq('9999-test-100')
    end

    it 'should return a teaching course in mysfu data for the user' do
      get :user, :sfu_id => :kipling, :property => 'mysfu', :format => :json
      expect(json_parse['teaching'].first['course_sis_source_id']).to eq('9999-test-200')
    end

    it 'should return a sandbox course' do
      get :user, :sfu_id => :kipling, :property => 'sandbox', :format => :json
      expect(json_parse.first['sis_source_id']).to eq('sandbox 12345')
    end
  end

  describe 'GET #course' do
    it 'should be successful' do
      get :course, :sis_id => :'9999-test-100', :format => :json
      expect(response).to have_http_status(:success)
    end

    it 'should return the right fields' do
      get :course, :sis_id => :'9999-test-100', :format => :json
      expect(json_parse.keys).to include('id', 'name', 'course_code')
    end

    it 'should only return the id when asked to do so' do
      get :course, :sis_id => :'9999-test-100', :property => 'id', :format => :json
      expect(@response.body.sub(%r{^while\(1\);}, '')).to eq(@course1.id.to_s)
    end
  end

  describe 'POST #course_enrollment' do
    it 'should respond with "Invalid POST parameters" when no params passed' do
      post :course_enrollment, :format => :json
      expect(json_parse['result']).to eq('Invalid POST parameters')
    end

    it 'update the course enrollment section' do
      post :course_enrollment, :enrollment_id => @enrollment1.id, :new_section_id => @section2.id, :format => :json
      expect(json_parse['result']).to eq('Success')
    end
  end

  describe 'PUT #undelete_group_membership' do
    before :each do
      @membership = @group.membership_for_user @user
      @membership.destroy
    end

    it 'should restore the group membership' do
      put :undelete_group_membership, :id => @membership.id, :format => :json
      expect(response).to have_http_status(:success)
    end
  end
end
