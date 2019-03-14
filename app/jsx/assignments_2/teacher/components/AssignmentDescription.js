/*
 * Copyright (C) 2018 - present Instructure, Inc.
 *
 * This file is part of Canvas.
 *
 * Canvas is free software: you can redistribute it and/or modify it under
 * the terms of the GNU Affero General Public License as published by the Free
 * Software Foundation, version 3 of the License.
 *
 * Canvas is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
 * A PARTICULAR PURPOSE. See the GNU Affero General Public License for more
 * details.
 *
 * You should have received a copy of the GNU Affero General Public License along
 * with this program. If not, see <http://www.gnu.org/licenses/>.
 */

import React from 'react'
import {bool, string} from 'prop-types'
import I18n from 'i18n!assignments_2'
import EditableRichText from './Editables/EditableRichText'
import View from '@instructure/ui-layout/lib/components/View'

export default class AssignmentDescription extends React.Component {
  static propTypes = {
    text: string.isRequired,
    readOnly: bool
  }

  static defaultPropTypes = {
    readOnly: true
  }

  constructor(props) {
    super(props)

    this.state = {
      mode: 'view',
      text: props.text
    }
  }

  handleChange = text => {
    this.setState({text})
  }

  handleChangeMode = mode => {
    this.setState({mode})
  }

  render() {
    return (
      <View as="div" margin="small 0" data-testid="AssignmentDescription">
        <EditableRichText
          mode={this.state.mode}
          value={this.state.text}
          onChange={this.handleChange}
          onChangeMode={this.handleChangeMode}
          label={I18n.t('Description')}
          readOnly={this.props.readOnly}
        />
      </View>
    )
  }
}
