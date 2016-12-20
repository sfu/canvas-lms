define([
  'jquery',
  'react',
  'react-dom',
  '../jsx/sfu_copyright_compliance_notice/SFUCopyrightComplianceNoticeModalDialog'
], function($, React, ReactDOM, SFUCopyrightComplianceModalDialog) {

    var render = function(formId) {
        ReactDOM.render(
          React.createElement(
            SFUCopyrightComplianceModalDialog,
            {
                modalIsOpen: true,
                formId: formId
            }
          ),
          document.getElementById('wizard_box')
        );
    };

    var attachClickHandler = function(formId) {
        var $button = $('#' + formId + ' button.btn-publish');
        $button.on('click', function(ev) {
            ev.preventDefault();
            render(formId);
        });
        $button.attr('disabled', false);
    };

    return {
        attachClickHandlerTo: attachClickHandler
    };
});
