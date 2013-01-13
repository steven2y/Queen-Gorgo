
$(document).ready ->


	_.templateSettings = interpolate: /\{\{(.+?)\}\}/g

	app = {}
	displayModel = {}
	win = $ window
	app.server = io.connect("/")
	console.log "Loading"

	_log = (message) ->
		console.log message
	_s_log = (o) ->
		console.log JSON.stringify o
		welcome: "<h1>#{message}</h1>"
		user: "<div #user>{{userName}}</div>"

	app.server.on "connect", ->
		_log "Connected to the server" + arguments

		displayModel.timestamp = new Date().getTime();
		$("h1").text("display " + displayModel.timestamp)
                
		displayModel.height = win.height()
		displayModel.width = win.width()
                 
		app.server.emit "displayRegister", displayModel

		app.server.on "message", (data) ->
			_log "Received message: " + data.message

		app.server.on "overlayMessage", (data) ->
			console.log data
			$("#overlay")
				.empty()
				.text(data.message)
				.addClass('show')
				.css("font-size",$(window).height()+"px")
			if data.imageSrc
				$("#overlay").css('background-image', "url('" + data.imageSrc + "')")
				$("#overlay").css('background-position', data.imageLeft + 'px ' + data.imageTop + 'px')

	$(window).resize -> 
		$("#overlay")
			.css("font-size",$(window).height()+"px")
		displayModel.height = win.height();
		displayModel.width = win.width()
		app.server.emit "displayUpdate", displayModel
		console.log displayModel
	window.app = app
