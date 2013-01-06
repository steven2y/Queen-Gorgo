
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

    templateRow: "<tr><td>{{timestamp}}</td><td><input class='message' type='text' value='{{message}}'/></td><td>{{height}}x{{width}} (px)</td></tr>"
    
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

class PhotoList
    constructor: (@ul) ->
        @photos = []
        _.extend @, Backbone.Events
    

    templatePhoto: "<li class='span1'>
                <a class='thumbnail' href='#'> 
                <image src='{{src}}' />
                </a>
                </li>"

    update: (list) ->
        for photo in list
            if jQuery.inArray(photo, @photos) is -1
                @photos.push photo
                @showPhoto photo    


    showPhoto: (photoPath) ->
        src = photoPath
        photo = $  _.template(@templatePhoto, {src: src})

        $(photo).find("a.thumbnail").click( _.bind (e)-> 
           console.log src
           @.trigger "imgClick", src
        ,@)
        @ul.append photo


class PictureControl
    image : ''

    constructor: (@div) ->

    templateImage: "<image src='{{src}}' /> <p>{{height}}x{{width}}(px)</p>"

    loadImage: (@src) ->
        @image = new Image()

        $(@image).load( _.bind -> 
            $(@div).empty()
            newImage = $  _.template(@templateImage, {src: src, height: @image.height, width: @image.width})
            @div.append newImage
        , this)    
        @image.src = src   

    getImageHeight: ->
        @image.height

    getImageWidth: ->
        @image.width
    
$(document).ready ->

    photoList = new PhotoList $('ul#imageList')
    pictureControl = new PictureControl $('div#loadedPicture')

    photoList.bind 'imgClick', (src) ->
        console.log src
        pictureControl.loadImage src


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

    app.updatePhotoList = (message) ->
        _log message
        photoList.update message
    
    app.server.on "connect", ->
        _log "Connected to the server" + arguments

    app.server.emit "controlRegister"

    app.server.on "showDisplayList", app.showDisplay
    
    app.server.on "updatePhotoList", app.updatePhotoList

    app.server.on "message", (data) ->
        _log "Received message: " + data.message

   
    window.app = app
