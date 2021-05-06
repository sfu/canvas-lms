import $ from 'jquery'
import _ from 'underscore'
import Backbone from '@canvas/backbone'

export default class User extends Backbone.Model

  initialize: (@userId) ->
    @hasLoaded = false
    @on 'change', ->
      @hasLoaded = true
      $(document).trigger 'userloaded'
    @on 'error', ->
      @hasLoaded = false
      $(document).trigger 'userloaderror'
    super

  url: ->
    "/sfu/api/v1/amaint/user/#{@userId}"
