#
# Copyright (C) 2011 - present Instructure, Inc.
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

require 'hey'

module Canvas::Plugins::Validators::YoValidator
  def self.validate(settings, plugin_setting)
    if settings.map(&:last).all?(&:blank?)
      {}
    else
      if settings.map(&:last).any?(&:blank?)
        plugin_setting.errors.add(:base, I18n.t('canvas.plugins.errors.all_fields_required', 'All fields are required'))
        false
      else
        begin
          Hey.api_token = settings[:api_token]
          Hey::Subscriber.count
          settings.permit(:api_token).to_h.with_indifferent_access
        rescue => e
          plugin_setting.errors.add(:base, e.message)
          false
        end
      end
    end
  end
end
