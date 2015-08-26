define [
  'jquery'
  'underscore'
  'Backbone'
], ($, _, Backbone) ->

  class Course extends Backbone.Model

    initialize: (@term) ->
      @selected = false # TODO: find a cleaner way to keep track of this runtime flag
      super

    # make useful custom attributes available to callers of toJSON()
    toJSON: ->
      $.extend Backbone.Model.prototype.toJSON.call(this),
        term: @term.get('name')
        selected: @selected
        displayName: @displayName()

    addSections: (newSections) ->
      # NOTE: does not currently check if course already has sections
      if newSections.length > 0
        @set
          sections: newSections
          key: "#{@get('key')}:::#{newSections.join(',').toLowerCase()}"
      this

    displayName: -> "#{@get('name')}#{@get('number')} - #{@get('section')} #{@get('title')}"
