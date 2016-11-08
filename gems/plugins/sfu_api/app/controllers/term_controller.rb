class TermController < ApplicationController

  # get all terms
  def all_terms
    t = EnrollmentTerm.active.select(select_fields).where(root_account: Account.default)
    respond_to do |format|
      format.json {render :json => t}
    end
  end

  # get specific term by sis id
  def term_by_sis_id
    t = EnrollmentTerm.active.select(select_fields).where(root_account: Account.default, sis_source_id: params[:sis_id])
    respond_to do |format|
      format.json {render :json => t}
    end
  end

  # get current term
  def current_term
    t = EnrollmentTerm.active.select(select_fields).where(root_account: Account.default).where(':date BETWEEN start_at AND end_at', {:date => DateTime.now}).where.not(sis_source_id: nil).first
    respond_to do |format|
      format.json {render :json => t}
    end
  end

  # get next n term(s)
  def next_terms
    t = EnrollmentTerm.active.select(select_fields).where('start_at > :date', {:date => DateTime.now}).where.not(sis_source_id: nil).order(:sis_source_id).limit(params[:num_terms])
    respond_to do |format|
      format.json {render :json => t}
    end
  end

  # get prev n term(s)
  def prev_terms(num_terms=1)
    t = EnrollmentTerm.active.select(select_fields).where('end_at < :date', {:date => DateTime.now}).where.not(sis_source_id: nil).order(sis_source_id: :desc).limit(params[:num_terms])
    respond_to do |format|
      format.json {render :json => t}
    end
  end

  private
  def select_fields
    %i(id name sis_source_id start_at end_at)
  end

end
