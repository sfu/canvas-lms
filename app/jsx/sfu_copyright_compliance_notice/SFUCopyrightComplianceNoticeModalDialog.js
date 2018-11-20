import React from 'react'
import PropTypes from 'prop-types'
import ReactModal from 'react-modal'
import SFUCopyrightComplianceNotice from './SFUCopyrightComplianceNotice'

class SFUCopyrightComplianceModalDialog extends React.Component {

  constructor(props) {
    super(props)
    this.state = {
      modalIsOpen: this.props.modalIsOpen
    }
    this.openModal = this.openModal.bind(this)
    this.closeModal = this.closeModal.bind(this)
    this.publishCourse = this.publishCourse.bind(this)
  }

  componentWillReceiveProps(nextProps) {
    this.setState({
      modalIsOpen: nextProps.modalIsOpen
    });
  }

  openModal(e) {
    e.preventDefault();
    this.setState({ modalIsOpen: true });
  }

  closeModal(e) {
    if (e) {
      e.preventDefault();
    }
    this.setState({
      modalIsOpen: false
    });
  }

  publishCourse(e) {
    if (e) {
      e.preventDefault();
    }
    this.setState({
      modalIsOpen: false
    }, () => {
      document.getElementById(this.props.formId).submit();
    });
  }

  render() {
    return (
      <ReactModal
        contentLabel="Copyright Compliance Notice"
        isOpen={this.state.modalIsOpen}
        className="ReactModal__Content--canvas"
        overlayClassName="ReactModal__Overlay--canvas"
      >
        <div className="ReactModal__Layout">

          <div className="ReactModal__InnerSection ReactModal__Header">
            <div className="ReactModal__Header-Title">
              <h4>Copyright Compliance Notice</h4>
            </div>
            <div className="ReactModal__Header-Actions">
              <button className="Button Button--icon-action" type="button" onClick={this.closeModal}>
                <i className="icon-x" />
                <span className="screenreader-only">Close</span>
              </button>
            </div>
          </div>

          <div className="ReactModal__InnerSection ReactModal__Body">
            <SFUCopyrightComplianceNotice />
          </div>

          <div className="ReactModal__InnerSection ReactModal__Footer">
            <div className="ReactModal__Footer-Actions">
              <button type="button" className="btn btn-default" onClick={this.closeModal}>Cancel</button>
              <button type="button" className="btn btn-primary" onClick={this.publishCourse}>Publish</button>
            </div>
          </div>

        </div>
      </ReactModal>
    )
  }
}

SFUCopyrightComplianceModalDialog.propTypes = {
  modalIsOpen: PropTypes.bool.isRequired,
  formId: PropTypes.string.isRequired
}

export default SFUCopyrightComplianceModalDialog
