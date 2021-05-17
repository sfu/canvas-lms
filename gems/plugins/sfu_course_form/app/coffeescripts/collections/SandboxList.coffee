import $ from 'jquery'
import _ from 'underscore'
import Backbone from '@canvas/backbone'

export default class SandboxList extends Backbone.Collection
  initialize: (@userId) -> super

  url: -> "/sfu/api/v1/user/#{@userId}/sandbox"
