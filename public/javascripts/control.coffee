
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
        @model.on "change", @refreshFromModel, @

    templateRow: "<tr><td><span class='badge badge-info'><i class='icon-resize-vertical'></i></span>{{timestamp}}</td><td><input class='message' type='text' value='{{message}}'/></td><td>{{height}}x{{width}} (px)</td></tr>"
    
    render: ->
        @row = $  _.template(@templateRow, @model.toJSON())
        @inputMessage = @row.find("input.message")
        @inputMessage.on "change", _.bind(@updateMessageModel, @)

        @$el.append @row
        return @

    #events: 
     #   "change input.message" : "updateMessageModel"
  
    updateMessageModel: (e)->
        value = $(e.target).val()
        @model.set 'message': value

    refreshFromModel: ->
        @inputMessage.val @model.get('message')
        console.log 'refresh'

class BinaryCounter
    constructor: (@table, @msInput) ->
        @counter = 0

    start: (ms) ->
        @timer = window.setInterval(_.bind(this.loadBits, @), parseInt @msInput.val())

    stop: ->
        window.clearInterval @timer

    loadBits: ->
        @counter++
        console.log @counter
        binary = @counter.toString 2

        binaryReverse = binary.split("").reverse().join("")

        display = @table.find 'input.message'
 
        @displayBit display[i], bit for bit, i in binaryReverse when display[i]
    
    displayBit: (input, bit)->
        $(input).val bit
        $(input).change()

$(document).ready ->

    _.templateSettings = interpolate: /\{\{(.+?)\}\}/g

    app = {}
    app.models = []
    app.server = io.connect("/")
    console.log "Loading"

    _log = (message) ->
            console.log message
    _s_log = (o) ->
            console.log JSON.stringify o
    
    app.showDisplay = (message) ->
        _log message
        $("table#displayList").empty()
  
       # displayRow = "<tr><td>{{timestamp}}</td><td><input class='message' type='text' value='{{message}}'/></td></tr>"

        $.each message, (key, display) =>
            #row = $ _.template(displayRow, display) 
            #input = row.find ".message"
            #_log input

            model = new Display (display), socket: app.server
            app.models.push model
            new DisplayRowView model: model, el:  $("table#displayList")

    app.server.on "connect", ->
        _log "Connected to the server" + arguments

    app.server.emit "controlRegister"

    app.server.on "showDisplayList", app.showDisplay

    app.server.on "message", (data) ->
        _log "Received message: " + data.message

    $("table#displayList").sortable (items: "tr", handle: "span.badge")

    binaryCounter = new BinaryCounter $("table#displayList"), $("input#speed")

    $('button#startStopBinary').click ->
        value = $('button#startStopBinary').text()
        if value == 'start'
            binaryCounter.start()
            $('button#startStopBinary').text 'stop'
        else
            binaryCounter.stop()
            $('button#startStopBinary').text 'start'
    window.app = app
