import $ from 'jquery'
import _ from 'underscore'
import Backbone from '@canvas/backbone'

export default class AmaintTermList extends Backbone.Collection

  initialize: (@userId) -> super

  url: -> "/sfu/api/v1/amaint/user/#{@userId}/term"
