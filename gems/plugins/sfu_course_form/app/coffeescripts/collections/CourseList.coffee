import $ from 'jquery'
import _ from 'underscore'
import Backbone from '@canvas/backbone'
import Course from '../models/Course.coffee'

export default class CourseList extends Backbone.Collection

  initialize: (@term) ->
    @on 'sync', ->
      @each ( (course) -> course.term = @term ), this
    super

  model: Course

  url: -> "/sfu/api/v1/amaint/user/#{@userId}/term/#{@term.get 'sis_source_id'}"

  comparator: (course) -> course.get 'sis_source_id'

  has: (course) ->
    @any (existingCourse) ->
      existingCourse.get('sis_source_id') == course.get('sis_source_id')

  terms: -> _.uniq @map (course) -> course.term
