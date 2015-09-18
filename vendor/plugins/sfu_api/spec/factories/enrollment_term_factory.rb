def enrollment_term_model(opts={})
  do_save = opts.has_key?(:save) ? opts.delete(:save) : true
  @enrollment_term = factory_with_protected_attributes(EnrollmentTerm, valid_enrollment_term_attributes.merge(opts), do_save)
end

def valid_enrollment_term_attributes
  {
    :name => 'value for name',
    :sis_source_id => 'value for sis id',
    :root_account_id => Account.default.id,
    :start_at => DateTime.now,
    :end_at => DateTime.now + 60.days,
    :workflow_state => 'active'
  }
end
