
$(document).ready ->


	_.templateSettings = interpolate: /\{\{(.+?)\}\}/g

	app = {}
	app.server = io.connect("/")
	console.log "Hello"

	_log = (message) ->
		console.log message
	_s_log = (o) ->
		console.log JSON.stringify o

	$('#message').keyup (e) ->
		if e.keyCode is 13
			console.log "sending..."
			app.server.emit "chat", $('#message').val()
			addMessage "out", e.srcElement.value
			$('#message').val null


	app.templates =
		welcome: "<h1>#{message}</h1>"
		user: "<div #user>{{userName}}</div>"

	app.template = (t) ->
		_.template t

	addUser = (user) ->
		$('#user-list').append("<div #user>" + user + "</div>")

	addMessage = (cls, message) ->
		$("#chat").append '<div class="' + cls + '"> ' + message + '</div>'

	app.server.on "connect", ->
		_log "Connected to the server" + arguments

		user = prompt "Who are you?" if !app.user?
		app.user = user
		$("h1").text("Welcome " + user)
		addUser(user)

		app.server.emit "userName", app.user

		app.server.on "message", (data) ->
			_log "Received message: " + data.message
			addMessage "in", data.message


		app.server.on "joined", (user) ->
			addUser user.userName


		app.server.on "chat", (data) ->
			_log "Received chat: " + data



	window.app = app
