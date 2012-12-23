
Display = Backbone.Model.extend 
	initialize: (id, options) ->
        @socket = options.socket
        @bind "change", (model)->
            console.log "change"
            console.log  model.toJSON()
            @socket.emit "controlShowDisplay", model.toJSON()
    #sync: (method, model, options) ->
      #switch method
        #when "create", "read", "update", "delete"
          #@io.emit "controlShowDisplay", model.toJSON()

DisplayRowView = Backbone.View.extend

    initialize: ->
        @render()

    templateRow: "<tr><td>{{timestamp}}</td><td><input class='message' type='text' value='{{message}}'/></td></tr>"
    
    render: ->
        row = $  _.template(@templateRow, @model.toJSON())
        row.find(".message").on("change", _.bind(@updateMessageModel, this))

        @$el.append row
        return @

    #events: 
     #   "change input.message" : "updateMessageModel"
  
    updateMessageModel: (e)->
        value = $(e.target).val()
        @model.set 'message': value


eventManager =
  linkDisplayInputToModel: (model, input)->
    $(input).change (e)->
        value = $(e.target).val()
        model.set 'message': value


$(document).ready ->

    _.templateSettings = interpolate: /\{\{(.+?)\}\}/g

    app = {}
    app.server = io.connect("/")
    console.log "Loading"

    _log = (message) ->
            console.log message
    _s_log = (o) ->
            console.log JSON.stringify o
    
    app.showDisplay = (message) ->
        _log message
        $("table#displayList").empty()
  
        displayRow = "<tr><td>{{timestamp}}</td><td><input class='message' type='text' value='{{message}}'/></td></tr>"

        $.each message, (key, display) =>
            row = $ _.template(displayRow, display) 
            input = row.find ".message"
            _log input

            model = new Display (display), socket: app.server
            new DisplayRowView model: model, el:  $("table#displayList")

    app.server.on "connect", ->
        _log "Connected to the server" + arguments

    app.server.emit "controlRegister"

    app.server.on "showDisplayList", app.showDisplay
    app.server.on "message", (data) ->
        _log "Received message: " + data.message


    window.app = app
