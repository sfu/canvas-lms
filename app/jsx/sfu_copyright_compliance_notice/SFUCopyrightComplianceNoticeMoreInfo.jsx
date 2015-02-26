/** @jsx React.DOM */

define([
  'react'
  ], function (React) {

  var SFUCopyrightComplianceNoticeMoreInfo = React.createClass({
    render() {
      var div_style = {
        padding: '24px',
        border: '1px solid #ccc',
        borderRadius: '3px',
        background: 'white',
        textAlign: 'left'
      };

      return (
        <div style={div_style}>
          <p>
            I confirm that any copyright protected materials made available in Canvas for this course which required the
            permission of the copyright holder for such use have been (will be) cleared by the copyright holder. I confirm that
            any copyright protected materials not requiring the permission of the copyright holder are made available pursuant to
            one or more of the following:
          </p>
          <ol>
            <li><a href="http://www.lib.sfu.ca/file-newest/11695/copyright_graphic.pdf" target="_blank">Fair Dealing</a>;</li>
            <li>Other exemption in the Copyright Act;</li>
            <li>Creative Commons License;</li>
            <li>Public Domain;</li>
            <li>Open Access;</li>
            <li>Allowed by an existing library license;</li>
            <li>Allowed as part of purchased course materials (e.g. online resources associated with a textbook);</li>
            <li>I hold copyright in the work.</li>
          </ol>
          <p>
            For more information see <a href="http://www.lib.sfu.ca/faqs/copyright-fair-dealing" target="_blank">What is Fair Dealing</a>,
            <a href="http://www.lib.sfu.ca/file-newest/11695/copyright_graphic.pdf" target="_blank">Copyright Information Graphic For Teaching Purposes</a>,
            <a href="http://copyright.sfu.ca" target="_blank">http://copyright.sfu.ca</a> or contact the SFU Copyright Office at <a href="mailto:copy@sfu.ca">copy@sfu.ca</a>.
          </p>
        </div>
      )
    }

  });

  return SFUCopyrightComplianceNoticeMoreInfo;

});