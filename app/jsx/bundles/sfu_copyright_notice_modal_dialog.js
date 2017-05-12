import $ from 'jquery'
import React from 'react'
import ReactDOM from 'react-dom'
import SFUCopyrightComplianceModalDialog from 'jsx/sfu_copyright_compliance_notice/SFUCopyrightComplianceNoticeModalDialog'

const formId = 'course_status_form'

const render = function () {
  ReactDOM.render(
    React.createElement(
      SFUCopyrightComplianceModalDialog,
      {
        modalIsOpen: true,
        formId
      }
    ),
    document.getElementById('wizard_box')
  )
};

const attachClickHandler = function () {
  var $button = $('#course_status_form button.btn-publish')
  $button.on('click', function (ev) {
    ev.preventDefault()
    render(formId)
  })
  $button.attr('disabled', false)
}

attachClickHandler()
