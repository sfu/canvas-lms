import $ from 'jquery'
import _ from 'underscore'
import Backbone from '@canvas/backbone'
import CourseView from './CourseView.coffee'

export default class CourseListView extends Backbone.View

  initialize: ->
    @collection.on 'request', ( -> this.$el.html '<li>Loading&hellip;</li>' ), this
    @collection.on 'sync', ( -> @render() ), this
    @collection.on 'error', ( -> this.$el.html '<li>No available courses</li>' ), this
    super

  tagName: 'ul'

  render: ->
    if @collection.length
      this.$el.empty()
      @collection.each @renderOne, this
    else
      @.$el.html('<li>No courses</li>')
    this

  renderOne: (course) ->
    courseView = new CourseView({model: course})
    this.$el.append courseView.render().el
