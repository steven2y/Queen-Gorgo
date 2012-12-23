
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


eventManager =
  linkDisplayInputToModel: (model, input)->
    $(input).change (e)->
        value = $(e.target).val()
        model.set 'value': value


$(document).ready ->

  #_.templateSettings = interpolate: /\{\{(.+?)\}\}/g

    app = {}
    app.server = io.connect("/")
    console.log "Loading"

    _log = (message) ->
            console.log message
    _s_log = (o) ->
            console.log JSON.stringify o
            welcome: "<h1>#{message}</h1>"
            user: "<div #user>{{userName}}</div>"

    app.showDisplay = (message) ->
        _log message
        $("ul").empty()
   
        $.each message, (key, val) =>
            input = $("<input type='text'></text>")
            model = new Display (id:key), socket: app.server
            eventManager.linkDisplayInputToModel model,input 
            li = $("<li>" + val + "</li>").append input 
            $("ul").append li
            

    app.server.on "connect", ->
        _log "Connected to the server" + arguments

    app.server.emit "controlRegister"

    app.server.on "showDisplayList", app.showDisplay
    app.server.on "message", (data) ->
        _log "Received message: " + data.message


    window.app = app
