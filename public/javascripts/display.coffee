
$(document).ready ->


	_.templateSettings = interpolate: /\{\{(.+?)\}\}/g

	app = {}
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

		app.display = new Date().getTime();
		$("h1").text("display " + app.display)

		app.server.emit "displayRegister", app.display

		app.server.on "message", (data) ->
			_log "Received message: " + data.message

		app.server.on "overlayMessage", (data) ->
			$("#overlay")
				.empty()
				.text(data.message)
				.addClass('show')
				.css("font-size",$(window).height()+"px")

	$(window).resize -> 
		$("#overlay")
			.css("font-size",$(window).height()+"px")

	window.app = app
