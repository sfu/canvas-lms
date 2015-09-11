require_relative '../spec_helper'

describe TermController do
  before :once do
    enrollment_term_model(:name => 'Previous Term', :sis_source_id => '123', :start_at => DateTime.now - 61.days, :end_at => DateTime.now - 1.day)
    enrollment_term_model(:name => 'Current Term', :sis_source_id => '234')
    enrollment_term_model(:name => 'Next Term', :sis_source_id => '345', :start_at => DateTime.now + 61.day, :end_at => DateTime.now + 121.days)
  end

  describe 'GET #all_terms' do
    before :each do
      @response = get :all_terms, :format => :json
      @body = JSON.parse(@response.body)
    end

    it 'should be successful' do
      expect(@response).to have_http_status(:success)
    end

    it 'should have four terms' do
      expect(@body.size).to eq(4)
    end

    it 'should contain the Default Term' do
      names = @body.map { |t| t['enrollment_term']['name'] }
      expect(names).to include('Default Term')
    end
  end

  describe 'GET #term_by_sis_id' do
    it 'should return Current Term for sis_id 234' do
      get :term_by_sis_id, :sis_id => '234', :format => :json
      term = JSON.parse(response.body)
      expect(term.first['enrollment_term']['name']).to eq('Current Term')
    end

    it 'should return an empty array for an invalid sis_id' do
      get :term_by_sis_id, :sis_id => 'invalid', :format => :json
      expect(JSON.parse(response.body).size).to eq(0)
    end
  end

  describe 'GET #current_term' do
    it 'should return Current Term' do
      get :current_term, :format => :json
      expect(JSON.parse(response.body)['enrollment_term']['name']).to eq('Current Term')
    end
  end

  describe 'GET #next_terms' do
    it 'should return Next Term' do
      get :next_terms, :format => :json
      expect(JSON.parse(response.body).first['enrollment_term']['name']).to eq('Next Term')
    end
  end

  describe 'GET #prev_terms' do
    it 'should return Previous Term' do
      get :prev_terms, :format => :json
      expect(JSON.parse(response.body).first['enrollment_term']['name']).to eq('Previous Term')
    end
  end
end
