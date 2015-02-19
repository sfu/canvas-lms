/** @jsx React.DOM */

define([
  'react'
], function(React) {

  var SFUPrivacyNoticeExternalApps = React.createClass({
    render () {
      var iconStyle = {
        verticalAlign: 'middle',

      }
      return (
        <div className="SFUPrivacyNoticeExternalApps alert alert-error">
          <h1><i className="external-apps-icon-warning icon-warning"></i> Is your app privacy compliant?</h1>
          <p>
            There are <strong> personal legal consequences</strong> if you use an app that discloses and stores students&rsquo; personal information elsewhere inside or outside Canada without their consent. Unauthorized disclosure is a privacy protection offense under BC law. Employees and SFU are liable to investigation and possible fines.
          </p>
          <p>
            <strong>Before using any app</strong>, carefully review the complete <a href="http://www.sfu.ca/canvasprivacynotice" target="_blank"> Canvas Privacy Protection Notice</a> to <strong>understand your legal responsibilities</strong> and please contact <a href="mailto:learntech@sfu.ca">learntech@sfu.ca</a>. The Learning Technology Specialists in the Teaching and Learning Centre will help you complete an app privacy assessment and, if needed, advise you how to obtain students&rsquo; consent in the manner prescribed by law.
          </p>
          <p>
            By using apps in your course and the App Centre in Canvas, you acknowledge that you have <strong>read the <a href="http://www.sfu.ca/canvasprivacynotice" target="_blank">Canvas Privacy Protection Notice</a></strong> and will <strong>follow the described protection of privacy requirements and procedure</strong>.
          </p>
        </div>
      );
    }
  })

  return SFUPrivacyNoticeExternalApps;
});