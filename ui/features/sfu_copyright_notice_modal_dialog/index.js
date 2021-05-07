/* eslint-disable notice/notice */
import $ from 'jquery'
import React from 'react'
import ReactDOM from 'react-dom'
import {SFUCopyrightComplianceModalDialog} from '@sfu/sfu-copyright-compliance-notice'

const formId = 'course_status_form'

const render = function () {
  ReactDOM.render(
    React.createElement(SFUCopyrightComplianceModalDialog, {
      modalIsOpen: true,
      formId
    }),
    document.getElementById('wizard_box')
  )
}

const attachClickHandler = function () {
  const $button = $('#course_status_form button.btn-publish')
  $button.on('click', function (ev) {
    ev.preventDefault()
    render(formId)
  })
  $button.attr('disabled', false)
}

attachClickHandler()
