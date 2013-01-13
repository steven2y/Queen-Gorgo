
Display = Backbone.Model.extend 
	initialize: (id, options) ->
        @socket = options.socket
        @bind "change", (model)->
            console.log "change"
            console.log  model.toJSON()
            @socket.emit "controlShowDisplay", model.toJSON()

DisplayRowView = Backbone.View.extend

    initialize: ->
        @render()
        @model.on "change", @refreshFromModel, @

    templateRow: "<tr><td>{{timestamp}}</td><td><input class='message' type='text' value='{{message}}'/></td><td>{{width}}x{{height}} (px)</td></tr>"
    
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

        $(photo).find("a.thumbnail").click (e) => 
          @.trigger "imgClick", src
        
        @ul.append photo


class PictureControl
    image : ''

    constructor: (@div) ->
        @displayFrames = []
        @tnSize = {height:0, width:0}

    templateImage: "<image src='{{src}}' />"
    templateDim:"<p class='dimensions'>{{height}}x{{width}}(px)</p>"

    loadImage: (@src) ->
        @image = new Image()

        $(@image).load( _.bind => 
            @tnImage.remove() if @tnImage
            @tnDim.remove() if @tnDim

            @tnImage = $  _.template(@templateImage, {src: src}) 

            @tnDim = $  _.template(@templateDim, {height: @image.height, width: @image.width})

            @div.append @tnImage
            @div.append @tnDim

            #lets add as background and remove tnImage

            @tnSize = {
                height: @tnImage.height(),
                width: @tnImage.width()
            }

            tnHeight = @getTnHeight() + 'px'
            tnWidth = @getTnWidth() + 'px'
            biUrl = "url('" + @src + "')"
            @div.css({
                    height:tnHeight,
                    width:tnWidth,
                    'background-image': biUrl
                    'background-size': tnWidth + ' ' + tnHeight;
                    'background-repeat': 'no-repeat';
            })
            @tnImage.remove()

            @refreshDisplayFrames()
        )
        @image.src = src 



    templateDisplayFrame: "<div class='displayFrame'></div>"

    refreshDisplayFrames: ->
        @clearDisplayFrame()
        for model in @models
                @addDisplayFrame model


    setModels: (@models) ->
        if @image
            @refreshDisplayFrames()

    clearDisplayFrame: ->
        for frames in @displayFrames
            frames.remove()

    addDisplayFrame: (model) ->
        newDisplay =  $ _.template(@templateDisplayFrame, {}) 
        console.log $(@div).position()
        $(@div).append newDisplay
        newDisplay.draggable({ 
            containment: "parent",
            drag: (e, ui) =>
                
                top = @scaleUp(ui.position.top)
                left = @scaleUp(ui.position.left)
                model.set { 
                            imageTop: 0 - top,
                            imageLeft:  0 - left
                            }
        });
        @setDisplaySize model, newDisplay
       
        @displayFrames.push newDisplay


    setDisplaySize: (model, display) ->
        height = @scaleDown(model.get('height')) + 'px'
        width = @scaleDown(model.get('width')) + 'px'
        
        display.css({height: height, width: width })
    
    #scaleUp for position in image
    scaleUp: (px) ->
        parseInt(px * ( @getImageHeight() / @getTnHeight()))

    #scale down for psotion in thumbnail
    scaleDown: (px) ->
        parseInt(px * (@getTnHeight() /  @getImageHeight()))
    
    getTnHeight: ->
        @tnSize.height

    getTnWidth: ->
        @tnSize.width

    getImageHeight: ->
        @image.height

    getImageWidth: ->
        @image.width
    
$(document).ready ->

    _.templateSettings = interpolate: /\{\{(.+?)\}\}/g


    photoList = new PhotoList $('ul#imageList')
    pictureControl = new PictureControl $('div#loadedPicture')

    app = {}
    app.models = []
    app.server = io.connect("/")
    console.log "Loading"

    _log = (message) ->
            console.log message
    _s_log = (o) ->
            console.log JSON.stringify o
    
    app.showDisplay = (message) ->
        $("table#displayList").empty()
        app.models = []
        
        $.each message, (key, display) =>
            #row = $ _.template(displayRow, display) 
            #input = row.find ".message"
            #_log input

            model = new Display (display), socket: app.server
            app.models.push model
            new DisplayRowView model: model, el:  $("table#displayList")

        pictureControl.setModels app.models    

    app.updatePhotoList = (message) ->
        photoList.update message
    
    app.server.on "connect", ->
        _log "Connected to the server" + arguments

    app.server.emit "controlRegister"

    app.server.on "showDisplayList", app.showDisplay
    
    app.server.on "updatePhotoList", app.updatePhotoList

    app.server.on "message", (data) ->
        _log "Received message: " + data.message

    photoList.on 'imgClick', (src) ->
       
        for model in app.models
            model.set { 'imageSrc': src, 'imageTop': 0, 'imageLeft': 0 }

        console.log app.models
        pictureControl.loadImage src    
   
    window.app = app
