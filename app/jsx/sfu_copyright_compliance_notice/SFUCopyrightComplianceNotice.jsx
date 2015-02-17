/** @jsx React.DOM */

define([
  'react'
  ], function (React) {

  var SFUCopyrightComplianceNotice = React.createClass({
    render() {
      return (
        <p className={this.props.className}>
          I confirm that the use of copyright protected materials in this course
          complies with Canada's Copyright Act and SFU Policy R30.04 - Copyright
          Compliance and Administration. Read more.
        </p>
      )
    }
  });

  return SFUCopyrightComplianceNotice;

});