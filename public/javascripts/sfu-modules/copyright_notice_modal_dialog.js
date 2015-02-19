define([
  'jquery',
  '../jsx/sfu_copyright_compliance_notice/SFUCopyrightComplianceNoticeModalDialog'
], function($, SFUCopyrightComplianceModalDialog) {

    var render = function(formId) {
        var mountElement = document.createElement('div');
        mountElement.id='sfu_copyright_compliance_notice_modal_veil';
        React.renderComponent(SFUCopyrightComplianceModalDialog({
            modalIsOpen: true,
            formId: formId
        }), mountElement);
    };


    var attachClickHandler = function(formId) {
        var $button = $('#' + formId + ' button.btn-publish');
        $button.on('click', function(ev) {
            ev.preventDefault();
            render(formId);
        });
    };

    return {
        attachClickHandlerTo: attachClickHandler
    };
});