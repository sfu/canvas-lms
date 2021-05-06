import $ from 'jquery'
import _ from 'underscore'
import Backbone from '@canvas/backbone'
import CourseList from '../collections/CourseList.coffee'

export default class Term extends Backbone.Model

  initialize: ->
    @courses = new CourseList()
    super

  fetchCourses: (userId) ->
    @courses.userId = userId
    @courses.term = this
    @courses.fetch()
