import React from 'react'
import PropTypes from 'prop-types'
import SFUCopyrightComplianceNoticeMoreInfo from './SFUCopyrightComplianceNoticeMoreInfo'

class SFUCopyrightComplianceNotice extends React.Component {

  constructor(props) {
    super(props)
    this.state = {
      show_more: props.show_more
    }
    this.handleClick = this.handleClick.bind(this)
  }

  handleClick() {
    this.setState({ show_more: !this.state.show_more })
  }

  showMoreMaybe() {
    if (this.state.show_more) {
      return <SFUCopyrightComplianceNoticeMoreInfo />
    }
    return (
      <p>
        <button onClick={this.handleClick} className="Button Button--mini">Read More&hellip;</button>
      </p>
    )
  }

  render() {
    return (
      <div>
        <p className={this.props.className}>
          I confirm that the use of copyright protected materials in this course
          complies with Canada&apos;s Copyright Act and SFU Policy R30.04 - Copyright
          Compliance and Administration.
        </p>
        {this.showMoreMaybe()}
      </div>
    )
  }
}

SFUCopyrightComplianceNotice.propTypes = {
  show_more: PropTypes.bool,
  className: PropTypes.string
}

SFUCopyrightComplianceNotice.defaultProps = {
  show_more: false,
  className: null
}


export default SFUCopyrightComplianceNotice
