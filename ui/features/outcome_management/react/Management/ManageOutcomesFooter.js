/*
 * Copyright (C) 2021 - present Instructure, Inc.
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
import PropTypes from 'prop-types'
import {Flex} from '@instructure/ui-flex'
import {Button} from '@instructure/ui-buttons'
import {IconOutcomesLine, IconTrashLine, IconMoveEndLine} from '@instructure/ui-icons'
import I18n from 'i18n!OutcomeManagement'
import OutcomesPopover from './OutcomesPopover'

const ManageOutcomesFooter = ({selected, onRemoveHandler, onMoveHandler}) => {
  const btnState = selected && selected > 0 ? 'enabled' : 'disabled'
  if (selected == null) return null

  // For this PS, the list of selected outcomes displayed in the OutcomesPopover component
  // will be static. The second PS will contain the necessary update to the component's
  // selected prop that will match the format below. The reason it is necessary to split
  // OUT-4392 in to 2 PS, is because the underlying selected object is also used in other
  // components which will require updates to adhere to the new structure.
  const selectedOutcomes =
    selected && selected > 0
      ? new Array(selected).fill(0).map((_v, i) => ({
          _id: i,
          title: `Outcome ${i + 1}`
        }))
      : []

  return (
    <Flex as="div">
      <Flex.Item as="div" width="34%" />
      <Flex.Item as="div" width="66%">
        {selected >= 0 && (
          <Flex justifyItems="space-between" wrap="wrap">
            <Flex.Item>
              <Flex alignItems="center" padding="0 0 0 x-small">
                <Flex.Item as="div">
                  <div
                    style={{
                      display: 'flex',
                      alignSelf: 'center',
                      fontSize: '0.875rem',
                      paddingLeft: '0.75rem'
                    }}
                  >
                    <IconOutcomesLine size="x-small" />
                  </div>
                </Flex.Item>
                <Flex.Item as="div">
                  <div style={{paddingLeft: '1.1875rem'}}>
                    <OutcomesPopover outcomes={selectedOutcomes} />
                  </div>
                </Flex.Item>
              </Flex>
            </Flex.Item>
            <Flex.Item as="div" padding="0 0 0 small">
              <Button
                margin="x-small"
                interaction={btnState}
                renderIcon={IconTrashLine}
                onClick={onRemoveHandler}
              >
                {I18n.t('Remove')}
              </Button>
              <Button
                margin="x-small"
                interaction={btnState}
                renderIcon={IconMoveEndLine}
                onClick={onMoveHandler}
              >
                {I18n.t('Move')}
              </Button>
            </Flex.Item>
          </Flex>
        )}
      </Flex.Item>
    </Flex>
  )
}

ManageOutcomesFooter.propTypes = {
  selected: PropTypes.number.isRequired,
  onRemoveHandler: PropTypes.func.isRequired,
  onMoveHandler: PropTypes.func.isRequired
}

export default ManageOutcomesFooter
