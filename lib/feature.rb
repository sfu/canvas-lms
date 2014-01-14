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

class Feature
  ATTRS = [:feature, :display_name, :description, :applies_to, :state, :root_opt_in, :enable_at, :beta, :development, :release_notes_url]
  attr_reader *ATTRS

  def initialize(opts = {})
    @state = 'allowed'
    opts.each do |key, val|
      next unless ATTRS.include?(key)
      next if key == :state && !%w(hidden off allowed on).include?(val)
      instance_variable_set "@#{key}", val
    end
  end

  def default?
    true
  end

  def locked?(query_context, current_user = nil)
    query_context.blank? || !allowed? && !hidden?
  end

  def enabled?
    @state == 'on'
  end

  def allowed?
    @state == 'allowed'
  end

  def hidden?
    @state == 'hidden'
  end

  # Register one or more features.  Must be done during application initialization.
  # The feature_hash is as follows:
=begin
  automatic_essay_grading: {
    display_name: lambda { I18n.t('features.automatic_essay_grading', 'Automatic Essay Grading') },
    description: lambda { I18n.t('features.automatic_essay_grading_description, 'Popup text describing the feature goes here') },
    applies_to: 'Course', # or 'RootAccount' or 'Account' or 'User'
    state: 'allowed',     # or 'off' or 'on' or 'hidden'
    root_opt_in: false,   # if true, 'allowed' features in source or site admin
                          # will be inherited in "off" state by root accounts
    enable_at: Date.new(2014, 1, 1),  # estimated release date shown in UI
    beta: false,          # 'beta' tag shown in UI
    development: false    # 'development' tag shown in UI
    release_notes_url: 'http://example.com/'
  }
=end

  def self.register(feature_hash)
    @features ||= {}
    feature_hash.each do |k, v|
      feature = k.to_s
      @features[feature] = Feature.new({feature: feature}.merge(v))
    end
  end

  # TODO: register built-in features here
  # (plugins may register additional features during application initialization)
  register(
   'draft_state' =>
    {
      display_name: lambda { I18n.t('features.draft_state', 'Draft State') },
      description: lambda { I18n.t('draft_state_description', <<DRAFT) },
Draft state is a *beta* feature that allows course content to be published and unpublished.
Unpublished content won't be visible to students and won't affect grades.
It also includes a redesign of some course areas to make them more consistent in look and functionality.

Unpublished content may not be available if Draft State is disabled.
DRAFT
      applies_to: 'Course',
      state: 'hidden',
      root_opt_in: true,
      development: true
    },
    'google_docs_domain_restriction' =>
    {
      display_name: -> { I18n.t('features.google_docs_domain_restriction', 'Google Docs Domain Restriction') },
      description: -> { I18n.t('google_docs_domain_restriction_description', <<END) },
Google Docs Domain Restriction allows Google Docs submissions and collaborations
to be restricted to a single domain. Students attempting to submit assignments or
join collaborations on an unapproved domain will receive an error message notifying them
that they will need to update their Google Docs integration.
END
      applies_to: 'RootAccount',
      state: 'hidden',
      root_opt_in: true
    }
  )

  def self.definitions
    @features ||= {}
    @features.freeze unless @features.frozen?
    @features
  end

  def applies_to_object(object)
    case @applies_to
      when 'RootAccount'
        object.is_a?(Account) && object.root_account?
      when 'Account'
        object.is_a?(Account)
      when 'Course'
        object.is_a?(Course) || object.is_a?(Account)
      when 'User'
        object.is_a?(User) || object.is_a?(Account) && object.site_admin?
      else
        false
    end
  end

  def self.feature_applies_to_object(feature, object)
    feature_def = definitions[feature.to_s]
    return false unless feature_def
    feature_def.applies_to_object(object)
  end

  def self.applicable_features(object)
    applicable_types = []
    if object.is_a?(Account)
      applicable_types << 'Account'
      applicable_types << 'Course'
      applicable_types << 'RootAccount' if object.root_account?
      applicable_types << 'User' if object.site_admin?
    elsif object.is_a?(Course)
      applicable_types << 'Course'
    elsif object.is_a?(User)
      applicable_types << 'User'
    end
    definitions.values.select{ |fd| applicable_types.include?(fd.applies_to) }
  end

end
