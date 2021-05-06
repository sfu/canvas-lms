import $ from 'jquery'
import _ from 'underscore'
import Backbone from '@canvas/backbone'
import Term from '../models/Term.coffee'

export default class TermList extends Backbone.Collection

  model: Term

  fetchAllCourses: (@userId) -> @each @fetchCoursesForTerm, this

  fetchCoursesForTerm: (term) -> term.fetchCourses @userId
