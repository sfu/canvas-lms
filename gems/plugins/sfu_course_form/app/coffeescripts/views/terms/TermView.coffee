import $ from 'jquery'
import _ from 'underscore'
import Backbone from '@canvas/backbone'
import SelectableCourseListView from '../courses/SelectableCourseListView.coffee'

export default class TermView extends Backbone.View

  tagName: 'li'

  template: _.template '<span class="term tag"><%= name %></span>'

  render: ->
    courseListView = new SelectableCourseListView({collection: @model.courses})
    this.$el.html @template @model.toJSON()
    this.$el.append courseListView.render().el
    this
