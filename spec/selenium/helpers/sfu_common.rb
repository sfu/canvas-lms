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
end
