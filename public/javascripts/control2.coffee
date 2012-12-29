
Display = Backbone.Model.extend 
        initialize: (io) ->
                @io = io

        sync: (method, model, options) ->
        #entry point for method
        switch method
    when "create","read","update", "delete"
                @io.emit "controlShowDisplay", model.toJSON()
                console.log model.toJSON()
        

eventManager =
  setUpDisplay: (model, input)->
    console.log ""


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
                $.each(message, (key, val) =>
                        $("ul").append($("<li>" + val + "</li>")))
        new Display app.server


        app.server.on "connect", ->
                _log "Connected to the server" + arguments

        app.server.emit "controlRegister"

        app.server.on "showDisplayList", app.showDisplay
        app.server.on "message", (data) ->
                _log "Received message: " + data.message


        window.app = app
