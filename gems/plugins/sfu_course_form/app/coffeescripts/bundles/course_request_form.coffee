import $ from 'jquery'
import 'jqueryui/autocomplete'
import _ from 'underscore'
import Backbone from '@canvas/backbone'
import React from 'react'
import ReactDOM from 'react-dom'
import User from '../models/User.coffee'
import Term from '../models/Term.coffee'
import Course from '../models/Course.coffee'
import AmaintTermList from '../collections/AmaintTermList.coffee'
import TermList from '../collections/TermList.coffee'
import TermListView from '../views/terms/TermListView.coffee'
import CourseList from '../collections/CourseList.coffee'
import CourseListView from '../views/courses/CourseListView.coffee'
import SelectableCourseListView from '../views/courses/SelectableCourseListView.coffee'
import SandboxList from '../collections/SandboxList.coffee'
import SandboxListView from '../views/sandboxes/SandboxListView.coffee'
import { SFUCopyrightComplianceNotice } from '@sfu/sfu-copyright-compliance-notice'

user = {}
currentUser = {}
terms = new TermList
suggestedTerms = new TermList
amaintTerms = {}
searchedCourseList = new CourseList()
searchedCourseListView = {}
selectedCourseList = new CourseList()
selectedCourseListView = {}
searchTermSelect = {}

userIdTextbox = {}
enrollMeCheckbox = {}
enrollMeAsSelect = {}
crosslistCheckbox = {}
crosslistTitle = {}

nonCalendarCourseTextbox = {}
nonCalendarTermSelect = {}

sandboxList = {}
sandboxListView = {}

adhocTextbox = {}

timeId = do ->
  now = new Date()
  [now.getMonth() + 1, now.getDate(), now.getYear() - 100, now.getTime().toString().substr(10)].join('')

getUsernameToDisplay = ->
  if user == currentUser then 'yourself' else user.get('sfu_id')

getCourses = ->
  # first, fetch terms in which the user teaches
  amaintTerms = new AmaintTermList(user.get('sfu_id'))
  amaintTerms.fetch
    success: (incomingTerms) ->
      # then, add ones that matches our master "terms" list to a list of suggested terms
      incomingTerms.each (incomingTerm) ->
        matchedTerm = terms.find((term) -> incomingTerm.get('peopleSoftCode') == term.get('sis_source_id'))
        suggestedTerms.add matchedTerm if matchedTerm
      # finally, fetch and display all courses from these suggested terms
      termListView = new TermListView({collection: suggestedTerms})
      $('#courses-suggested').html termListView.render().el
      suggestedTerms.fetchAllCourses(user.get('sfu_id'))
    error: ->
      $('#courses-suggested').html '<p>No suggested courses found</p>'
  suggestedTerms

getSandboxes = ->
  sandboxList = new SandboxList(user.get('sfu_id'))
  sandboxListView = new SandboxListView
    collection: sandboxList
    el: $('#sandboxes')
  sandboxListView.username = getUsernameToDisplay()
  sandboxList.fetch
    error: ->
      sandboxListView.renderEmpty()

initPayload = ->
  payload = username: user.get('sfu_id')
  if enrollMeCheckbox.prop 'checked'
    payload['enroll_me'] = currentUser.get('sfu_id')
    payload['enroll_me_as'] = enrollMeAsSelect.val()
  payload

processSubmitCalendar = ->
  if selectedCourseList.length == 0
    alert 'You must select at least one course to continue.'
    return

  showStep '4'

  payload = initPayload()
  payload['cross_list'] = true if crosslistCheckbox.prop 'checked'

  selectedCourseList.each (course) ->
    payload["selected_course_#{course.cid}_#{course.get('peopleSoftCode')}"] = course.get('key')

  submitRequest payload, '3-calendar'

processSubmitNonCalendar = ->
  if $.trim(nonCalendarCourseTextbox.val()) == ''
    alert 'The Course Name must not be empty'
    return

  showStep '4'
  payload = initPayload()

  termCode = nonCalendarTermSelect.val()

  payload["selected_course_#{timeId}_#{nonCalendarTermSelect.val()}"] = "ncc-#{payload.username}-#{timeId}-#{termCode}-#{nonCalendarCourseTextbox.val()}"

  submitRequest payload, '3-non_calendar'

processSubmitSandbox = ->
  showStep '4'
  payload = initPayload()

  payload["selected_course_sandbox_#{timeId}"] = "sandbox-#{payload.username}-#{timeId}"

  submitRequest payload, '3-sandbox'

processSubmitAdhoc = ->
  # With ad hoc spaces, the user is always create the space for him/herself
  user = currentUser

  if $.trim(adhocTextbox.val()) == ''
    alert 'The Name of Space must not be empty'
    return

  showStep '4'
  payload = initPayload()

  payload["selected_course_adhoc_#{timeId}"] = "adhoc-#{payload.username}-#{timeId}-#{adhocTextbox.val()}"

  # NOTE: The adhoc form fields are in step 1
  submitRequest payload, '1'

submitRequest = (payload, destinationOnFailure) ->
  request = $.post '/sfu/course/create', payload
  request.done (data) ->
    if data.success
      showStep '5'
    else
      $.flashError "Course request failed: #{data.message} Please try again."
      showStep destinationOnFailure
  request.fail ->
    console.log request
    $.flashError 'The course request cannot be processed at this time. Please try again.'
    showStep destinationOnFailure

processFaculty = (action) ->
  userId = userIdTextbox.val()
  validUserId = /^[a-z_0-9]+$/

  if action == 'action-identify-faculty-delegate'
    unless validUserId.test(userId)
      alert 'Instructor Computer ID contains invalid characters. Please correct it before continuing.'
      return
    user = new User(userId)
    user.fetch()
  else
    user = currentUser

  if user.hasLoaded
    showFacultyStep()
  else
    showStep '2-loading'

  $(document).one 'userloaded', -> showFacultyStep()

  $(document).one 'userloaderror', ->
    # deregister the successful event listener to avoid duplicates later
    $(document).off 'userloaded'
    # bring user to a previous step to allow for correction
    if action == 'action-identify-faculty-delegate'
      # user was creating for someone else
      alert 'Instructor Computing ID is invalid. Please double check before continuing.'
      showDelegateStep()
    else
      # user was creating for him/herself; this error is unlikely, but we handle it anyway
      alert 'Your Computing ID is invalid. Please contact Canvas help.'
      showStep '1'

showFacultyStep = ->
  $('.username-display').text(getUsernameToDisplay())
  $('#sandbox-name-display').text("Sandbox - #{user.get('sfu_id')} - #{timeId}")
  getCourses()
  getSandboxes()
  showStep '2-faculty'

showDelegateStep = ->
  showStep '1-delegate'
  userIdTextbox.focus()

showNonCalendarStep = ->
  showStep '3-non_calendar'
  nonCalendarCourseTextbox.focus()

showStep = (name) ->
  # hide all steps, then only show the specified one
  $('section.step').hide()
  $("#step-#{name}").show()

handleActionClick = (event) ->
  event.preventDefault()
  action = $(this).attr('id')
  switch action
    when 'action-identify-student' then showStep '2-student'
    when 'action-identify-faculty-delegate-pending' then showDelegateStep()
    when 'action-identify-faculty-delegate', 'action-identify-faculty' then processFaculty action
    when 'action-course-calendar' then showStep '3-calendar'
    when 'action-course-non_calendar' then showNonCalendarStep()
    when 'action-course-sandbox' then showStep '3-sandbox'
  # submit actions
    when 'action-submit-calendar' then processSubmitCalendar()
    when 'action-submit-non_calendar' then processSubmitNonCalendar()
    when 'action-submit-sandbox' then processSubmitSandbox()
    when 'action-submit-adhoc' then processSubmitAdhoc()
  # back actions
    when 'action-back-faculty-delegate' then showStep '1'
    when 'action-back-calendar', 'action-back-non_calendar', 'action-back-sandbox' then showStep '2-faculty'
  # redirect actions
    when 'action-go-dashboard' then window.location = '/'
    when 'action-go-course_list' then window.location = '/courses'
    when 'action-go-start_over', 'action-go-start_over-sidebar' then window.location.reload()
    when 'action-open-help' then window.open 'https://www.sfu.ca/cee/services/learning-and-teaching-technology.html', '_blank'

# create relevant labels for the calendar course submit button
updateCalendarSubmitButton = ->
  button = $('#action-submit-calendar')
  if crosslistCheckbox.prop 'checked'
    button.text('Create Single Cross-listed Course')
  else
    button.text(if selectedCourseList.length <= 1 then 'Create Course' else 'Create Courses')

handleSelectedCourseListChange = ->
  # update the course list
  selectedCourseListView.render()
  updateCalendarSubmitButton()
  canCrosslist = yes
  # one can only cross-list more than one course
  canCrosslist &= selectedCourseList.length > 1
  # one can only cross-list courses from the same term
  canCrosslist &= selectedCourseList.terms().length == 1
  if canCrosslist
    # only enable cross-list checkbox if cross-listing is possible/logical
    crosslistCheckbox.removeAttr('disabled')
    # when cross-listing, show concatenated course name
    names = selectedCourseList.map (course) ->
      "#{course.get 'name'}#{course.get 'number'} - #{course.get 'section'}"
    crosslistTitle.text "The new course will be called: #{names.join ' / '}"
  else
    crosslistCheckbox.attr('disabled', 'disabled').prop('checked', false).triggerHandler('change')
    crosslistTitle.text 'No cross-list'

$(document).ready ->


  ReactDOM.render(
    React.createElement(
      SFUCopyrightComplianceNotice,
      { className: 'sfu-ic-wizard-box__message-text__copyright_compliance' }
    ),
    document.getElementsByClassName('copyright')[0]
  )

  # attach behavior to action links
  $('button.action').bind 'click', handleActionClick

  # extract master "terms" list from the HTML drop-down menu
  searchTermSelect = $('#sel-search-term')
  searchTermSelect.children('option').each ->
    terms.add new Term
      sis_source_id: $(this).attr('value')
      name: $(this).text()

  # pre-fetch the current user
  userIdTextbox = $('#txt-user_id')
  userIdTextbox.bind 'keydown', (event) ->
    # make RETURN/ENTER key trigger the next step
    processFaculty('action-identify-faculty-delegate') if event.which == 13
  currentUserId = userIdTextbox.data('default')
  currentUser = new User currentUserId
  currentUser.fetch()

  enrollMeCheckbox = $('#chk-enroll_me')
  enrollMeAsSelect = $('#sel-enroll_me_as')

  nonCalendarCourseTextbox = $('#txt-course_name')
  nonCalendarCourseTextbox.bind 'keydown', (event) ->
    # make RETURN/ENTER key trigger the next step
    processSubmitNonCalendar() if event.which == 13
  nonCalendarTermSelect = $('#sel-term')

  adhocTextbox = $('#txt-adhoc_name')
  adhocTextbox.bind 'keydown', (event) ->
    # make RETURN/ENTER key trigger the next step
    processSubmitAdhoc() if event.which == 13

  showStep '1'

  searchedCourseListView = new SelectableCourseListView
    collection: searchedCourseList
    el: $('#courses-searched')

  # hide the list initially because it's empty
  $(searchedCourseListView.el).hide()
  searchedCourseListView.collection.on 'add', ->
    searchedCourseListView.render()
    $(searchedCourseListView.el).show()

  # only show cross-list title if cross-listing courses
  crosslistTitle = $('#crosslist-title')
  crosslistTitle.hide()
  crosslistCheckbox = $('#chk-crosslist')
  crosslistCheckbox.bind 'change', ->
    updateCalendarSubmitButton()
    if $(this).prop 'checked'
      crosslistTitle.show()
    else
      crosslistTitle.hide()

  selectedCourseListView = new CourseListView
    collection: selectedCourseList
    el: $('#courses-selected')

  selectedCourseListView.collection.on 'add', handleSelectedCourseListChange
  selectedCourseListView.collection.on 'remove', handleSelectedCourseListChange
  handleSelectedCourseListChange()

  $(document).bind 'selectablecoursechange', (event, course, isSelected) ->
    if isSelected
      selectedCourseList.add course
    else
      selectedCourseList.remove course

  $('#search').autocomplete
    source: (request, response) ->
      $.ajax
        url: "/sfu/api/v1/course-data/#{searchTermSelect.val()}/#{request.term}"
        dataType: 'json'
        success: (data) ->
          response $.map data.slice(0, 10), (item) ->
            $.extend item, {
              label: item.display,
              value: item.sis_source_id,
            }
        error: (XMLHttpRequest, textStatus, errorThrown) ->
          console.log "Error getting course list: #{errorThrown}"
    minLength: 3
    focus: (event, ui) ->
      # make sure the search field still shows the label (instead of the underlying value)
      $(this).val(ui.item.label)
      false
    select: (event, ui) ->
      # manually create the course using metadata from the selected item
      course = new Course
        key: ui.item.key
        name: ui.item.name
        number: ui.item.number
        peopleSoftCode: ui.item.term
        section: ui.item.section
        sis_source_id: ui.item.sis_source_id
        title: ui.item.title
        sections: []
        sectionCode: '' # NOTE: this field is not available with this API call

      # Check if this course has sections. If it does, update the course
      $.ajax
        url: "/sfu/api/v1/amaint/course/#{ui.item.key}/sections"
        dataType: 'json'
        success: (data) -> course.addSections data.sections

      # Check if this course is already in Canvas. If it is, the call will be successful. Otherwise, we'll get a 404.
      $.ajax
        url: "/sfu/api/v1/course/#{ui.item.sis_source_id}"
        dataType: 'json'
        success: ->
          alert "#{course.displayName()} already exists in Canvas, and cannot be added again."
        error: -> # course doesn't already exist in Canvas (NOTE: we expect a 404 here to indicate such condition)
          # ignore this course if it's already in the search results; we don't want duplicates
          return if searchedCourseList.has course

          # attach the corresponding term to the course
          course.term = _.first(terms.where({sis_source_id: ui.item.term}))

          # again, we don't want duplicates between search results and Suggested Courses
          if course.term.courses.has course
            alert "#{course.displayName()} is already in your Suggested Courses. Please use that instead."
            return

          # now it's sane to add it to the search results
          searchedCourseList.add course

      # empty the search field and cancel the event to prevent value from getting changed
      $(this).val ''
      false
