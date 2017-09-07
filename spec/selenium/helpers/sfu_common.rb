#
# Copyright (C) 2017 - present Simon Fraser University.
#
# This file is part of Simon Fraser University's fork of Canvas.
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

require_relative '../common'

module SFUCommon
  def set_up_account_with_sfu_brand
    @account = Account.default
    @account.settings= {global_includes: true, sub_account_includes: true}
    @bc_config = BrandConfig.for(
      variables: nil,
      js_overrides: "/sfu/js/sfu.js",
      css_overrides: "/sfu/css/sfu.css",
      mobile_js_overrides: nil,
      mobile_css_overrides: nil,
      parent_md5: nil
    )
    @bc_config.save!
    @account.brand_config_md5 = @bc_config.md5
    @account.save!
  end

  def create_sfu_terms
    terms_file = File.expand_path("#{File.dirname(__FILE__)}../../../fixtures/sfu_terms.json")
    terms = JSON.parse(File.read(terms_file))
    terms.map! { |t| t['enrollment_term'] }
    terms.delete_if { |t| t['name'] == 'Default Term' }
    terms.each do |t|
      enrollment_term_model({
        :name => t['name'],
        :sis_source_id => t['sis_source_id'],
        :start_at => t['start_at'],
        :end_at => t['end_at'],
        :workflow_state => 'active'
      })
    end
  end

  def current_sfu_term
    EnrollmentTerm.active.select(select_fields).where(root_account: Account.default).where(':date BETWEEN start_at AND end_at', {:date => DateTime.now}).where.not(sis_source_id: nil).first
  end

  def next_sfu_term
    EnrollmentTerm.active.select(select_fields).where('start_at > :date', {:date => DateTime.now}).where.not(sis_source_id: nil).order(:sis_source_id).limit(1).first
  end

  def prev_sfu_term
    EnrollmentTerm.active.select(select_fields).where('end_at < :date', {:date => DateTime.now}).where.not(sis_source_id: nil).order(sis_source_id: :desc).limit(1).first
  end

  private
  def select_fields
    %i(id name sis_source_id start_at end_at)
  end

end
