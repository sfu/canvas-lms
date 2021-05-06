import React from 'react'

const divStyle = {
  padding: '24px',
  border: '1px solid #ccc',
  borderRadius: '3px',
  background: 'white',
  textAlign: 'left'
}

const SFUCopyrightComplianceNoticeMoreInfo = () => (
  <div style={divStyle}>
    <p>
        I confirm that any copyright protected materials made available in Canvas for this course which required the
        permission of the copyright holder for such use have been (will be) cleared by the copyright holder. I confirm that
        any copyright protected materials not requiring the permission of the copyright holder are made available pursuant to
        one or more of the following:
      </p>
    <ol>
      <li>Fair Dealing;</li>
      <li>Another exception in the Copyright Act (e.g., educational exceptions);</li>
      <li>Creative Commons license;</li>
      <li>Copyright has expired (public domain);</li>
      <li>Open Access source;</li>
      <li>Allowed by an existing library license;</li>
      <li>Allowed as part of purchased course materials (e.g., online resources associated with a textbook);</li>
      <li>Permission granted directly by the copyright holder, or licensed the material directly;</li>
      <li>I hold copyright in the work.</li>
    </ol>
    <p>
        For more information visit {}
        <a
          href="https://www.lib.sfu.ca/help/academic-integrity/copyright"
          target="_blank"
          rel="noreferrer noopener"
        >copyright.sfu.ca</a>, and see in particular the FAQ {}
        <a
          href="https://www.lib.sfu.ca/help/academic-integrity/copyright/fair-dealing"
          target="_blank"
          rel="noreferrer noopener"
        >What is fair dealing?</a> and the {}
        <a
          href="https://www.lib.sfu.ca/system/files/26749/copyright_graphic.pdf"
          target="_blank"
          rel="noreferrer noopener"
        >Using Copyright Protected Materials for Teaching Purposes at SFU</a> infographic, or contact the SFU Copyright
        Office at <a href="mailto:copy@sfu.ca">copy@sfu.ca</a>.
    </p>
  </div>
  )

export default SFUCopyrightComplianceNoticeMoreInfo
