//
// Copyright (C) 2013 - present Instructure, Inc.
//
// This file is part of Canvas.
//
// Canvas is free software: you can redistribute it and/or modify it under
// the terms of the GNU Affero General Public License as published by the Free
// Software Foundation, version 3 of the License.
//
// Canvas is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
// A PARTICULAR PURPOSE. See the GNU Affero General Public License for more
// details.
//
// You should have received a copy of the GNU Affero General Public License along
// with this program. If not, see <http://www.gnu.org/licenses/>.

import Backbone from 'Backbone'
import _ from 'underscore'
import I18n from 'i18n!publishable'

export default class Publishable extends Backbone.Model {
  constructor(...args) {
    super(...args)
    this.publish = this.publish.bind(this)
    this.unpublish = this.unpublish.bind(this)
  }

  initialize(attributes, options) {
    this._root = options.root
    return this.set('unpublishable', true)
  }

  publish() {
    this.set('published', true)
    return this.save()
  }

  unpublish() {
    this.set('published', false)
    return this.save()
  }

  disabledMessage() {
    return I18n.t('cant_unpublish', "Can't unpublish")
  }

  toJSON() {
    const json = {}
    json[this._root] = _.clone(this.attributes)
    return json
  }
}
