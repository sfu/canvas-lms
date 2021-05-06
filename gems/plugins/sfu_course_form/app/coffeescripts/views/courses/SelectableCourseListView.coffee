import $ from 'jquery'
import _ from 'underscore'
import Backbone from '@canvas/backbone'
import CourseListView from './CourseListView.coffee'

export default class SelectableCourseListView extends CourseListView

  renderOne: (course) ->
    courseView = new SelectableCourseView({model: course})
    this.$el.append courseView.render().el
