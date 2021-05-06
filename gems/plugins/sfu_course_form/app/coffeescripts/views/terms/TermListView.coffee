import $ from 'jquery'
import _ from 'underscore'
import Backbone from '@canvas/backbone'
import TermView from './TermView.coffee'

export default class TermListView extends Backbone.View

  tagName: 'ul'

  render: ->
    if @collection.length
      @collection.each @renderOne, this
    else
      this.$el.html('<li>No terms</li>')
    this

  renderOne: (term) ->
    termView = new TermView({model: term})
    this.$el.append termView.render().el
