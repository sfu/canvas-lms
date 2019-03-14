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
import {bool, string, func, oneOf} from 'prop-types'
import apiUserContent from 'compiled/str/apiUserContent'

import InPlaceEdit from '@instructure/ui-editable/lib/components/InPlaceEdit'
import Button from '@instructure/ui-buttons/lib/components/Button'
import ScreenReaderContent from '@instructure/ui-a11y/lib/components/ScreenReaderContent'
import View from '@instructure/ui-layout/lib/components/View'
import ArrowDown from '@instructure/ui-icons/lib/Line/IconArrowOpenDown'
import {omitProps} from '@instructure/ui-utils/lib/react/passthroughProps'

import RichContentEditor from 'jsx/shared/rce/RichContentEditor'

RichContentEditor.preloadRemoteModule()

export default class EditableRichText extends React.Component {
  static propTypes = {
    mode: oneOf(['view', 'edit']).isRequired,
    label: string.isRequired, // label for the rce when in edit mode
    value: string.isRequired, // the current text
    onChange: func.isRequired, // when flips from edit to view, notify consumer of the new value
    onChangeMode: func.isRequired, // when mode changes
    placeholder: string, // the string to display when the text value is empty
    readOnly: bool,
    required: bool,
    requiredMessage: string
  }

  static defaultProps = {
    placeholder: '',
    readOnly: false,
    required: false
  }

  constructor(props) {
    super(props)

    this.state = {
      value: props.value,
      initialValue: props.value,
      htmlValue: apiUserContent.convert(props.value)
    }
  }

  static getDerivedStateFromProps(props, state) {
    if (state.initialValue !== props.value) {
      const newState = {...state}
      newState.value = props.value
      newState.initialValue = props.value
      newState.htmlValue = apiUserContent.convert(props.value)
      return newState
    }
    return null
  }

  componentDidMount() {
    if (this.props.mode === 'edit') {
      this.loadRCE()
    }
  }

  componentDidUpdate(prevProps) {
    if (prevProps.mode === 'view' && this.props.mode === 'edit') {
      this.loadRCE()
    }
  }

  componentWillUnmount() {
    if (this.props.mode === 'edit') {
      this.unloadRCE()
    }
  }

  renderView = () => {
    const html = this.state.htmlValue
    return (
      <View as="div" margin="small 0">
        {html ? (
          <div dangerouslySetInnerHTML={{__html: html}} />
        ) : (
          <div>{this.props.placeholder}</div>
        )}
      </View>
    )
  }

  // Note: I believe there's a bug in tinymce, that
  // if you set focus:true to give the editor focus on init,
  // then the internal bookkeeping doesn't know it has focus
  // and it does not handle the focusout event correctly.
  // Start w/o focus, then give it focus after initialization
  // in this.handleRCEInit
  loadRCE() {
    RichContentEditor.loadNewEditor(this._textareaRef, {
      focus: false,
      manageParent: false,
      tinyOptions: {
        init_instance_callback: this.handleRCEInit
      }
    })
  }

  unloadRCE() {
    const editorIframe = document
      .getElementById('assignments_2')
      .querySelector('[id^="random_editor"]')
    if (editorIframe) {
      editorIframe.removeEventListener('focus', this.handleEditorIframeFocus)
    }
    if (this._textareaRef) {
      RichContentEditor.destroyRCE(this._textareaRef)
    }
    this._textareaRef = null
  }

  handleRCEInit = tinyeditor => {
    this._tinyeditor = tinyeditor

    this._tinyeditor.on('blur', this.handleEditorBlur)
    this._tinyeditor.on('focus', this.handleEditorFocus)
    this._tinyeditor.on('keydown', this.handleKey)
    document
      .getElementById('assignments_2')
      .querySelector('[id^="random_editor"]')
      .addEventListener('focus', this.handleEditorIframeFocus)
    this._tinyeditor.focus()
  }

  handleEditorBlur = event => {
    // HACK: if the user clicked on a toolbar button that opened a dialog,
    // the activeElement will be a child of the body, and not the our page
    if (document.getElementById('assignments_2').contains(document.activeElement)) {
      if (this._textareaRef) {
        const txt = RichContentEditor.callOnRCE(this._textareaRef, 'get_code')
        this.setState({value: txt})
      }
      this._onBlurEditor(event)
    }
  }

  handleEditorIframeFocus = _event => {
    this._tinyeditor.focus()
  }

  handleEditorFocus = _event => {
    // these two lines put the caret at the end of the text when focused
    this._tinyeditor.selection.select(this._tinyeditor.getBody(), true)
    this._tinyeditor.selection.collapse(false)
  }

  handleKey = event => {
    if (this.props.mode === 'edit' && event.key === 'Escape') {
      event.preventDefault()
      event.stopPropagation()
      this.handleModeChange('view')
    }
  }

  textareaRef = el => {
    this._textareaRef = el
  }

  renderEditor = ({onBlur, editorRef}) => {
    this._onBlurEditor = onBlur
    this._editorRef = editorRef
    editorRef(this)
    return (
      <textarea
        style={{display: 'block', minHeight: '300px'}}
        defaultValue={this.state.value}
        ref={this.textareaRef}
      />
    )
  }

  // the Editable component thinks I'm the editor
  focus = () => {
    if (this._tinyeditor) {
      this._tinyeditor.focus(true)
    }
  }

  // mostly a copy of InPlaceEdit.renderDefaultEditButton,
  // replacing the icon and making always visible in view mode
  renderEditButton = buttonProps => {
    if (!buttonProps.readOnly && this.props.mode === 'view') {
      const props = omitProps(buttonProps, {}, ['isVisible', 'label'])
      return (
        <Button size="small" variant="icon" icon={ArrowDown} {...props}>
          <ScreenReaderContent>{this.props.label}</ScreenReaderContent>
        </Button>
      )
    }
    return null
  }

  handleChange = event => {
    this.setState(
      {
        value: event.target.value,
        htmlValue: apiUserContent.convert(event.target.value)
      },
      () => {
        this.props.onChange(this.state.value)
      }
    )
  }

  handleModeChange = mode => {
    if (!this.props.readOnly) {
      if (this.props.mode === 'edit') {
        this.unloadRCE()
      } else if (this._editorRef) {
        this._editorRef(null)
      }
      this.props.onChangeMode(mode)
    }
  }

  getRef = el => (this._elemRef = el)

  render() {
    return (
      <InPlaceEdit
        mode={this.props.mode}
        onChangeMode={this.handleModeChange}
        renderViewer={this.renderView}
        renderEditor={this.renderEditor}
        renderEditButton={this.renderEditButton}
        value={this.state.value}
        onChange={this.props.onChange}
        editButtonPlacement="start"
        readOnly={this.props.readOnly}
        inline={false}
      />
    )
  }
}
