#
# Copyright (C) 2015 - present Instructure, Inc.
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

define [
  'jquery'
  'jquery.ajaxJSON'
], ($) ->
  toggle: (button) ->
    data = $(button).data.bind($(button))
    $.ajaxJSON(
      (data 'url'),
      if data 'isChecked' then 'DELETE' else 'PUT',
      {},
      ->
        data 'isChecked', !(data 'isChecked')
        $(button).toggleClass 'btn-success'
        $('i', button).toggleClass 'icon-empty icon-complete'
        $('.mark-done-labels span', button).toggleClass 'visible'
    )
