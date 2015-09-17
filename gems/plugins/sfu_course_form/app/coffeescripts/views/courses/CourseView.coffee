define [
  'jquery'
  'underscore'
  'Backbone'
], ($, _, Backbone) ->

  class CourseView extends Backbone.View

    initialize: ->
      @model.on 'change', ( -> @render() ), this
      super

    tagName: 'li'

    template: _.template '<div><span class="term tag"><%= term %></span> <%= displayName %><% if (sections.length) { %></div><div class="tutorial_sections">&mdash; includes these sections: <%= sections.join(", ") %></div><% } %>'

    render: ->
      this.$el.html @template @model.toJSON()
      this
