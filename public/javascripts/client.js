// Generated by CoffeeScript 1.4.0
(function() {

  $(document).ready(function() {
    var addMessage, addUser, app, _log, _s_log;
    _.templateSettings = {
      interpolate: /\{\{(.+?)\}\}/g
    };
    app = {};
    app.server = io.connect("/");
    console.log("Hello");
    _log = function(message) {
      return console.log(message);
    };
    _s_log = function(o) {
      return console.log(JSON.stringify(o));
    };
    $('#message').keyup(function(e) {
      if (e.keyCode === 13) {
        console.log("sending...");
        app.server.emit("chat", $('#message').val());
        addMessage("out", e.srcElement.value);
        return $('#message').val(null);
      }
    });
    app.templates = {
      welcome: "<h1>" + message + "</h1>",
      user: "<div #user>{{userName}}</div>"
    };
    app.template = function(t) {
      return _.template(t);
    };
    addUser = function(user) {
      return $('#user-list').append("<div #user>" + user + "</div>");
    };
    addMessage = function(cls, message) {
      return $("#chat").append('<div class="' + cls + '"> ' + message + '</div>');
    };
    app.server.on("connect", function() {
      var user;
      _log("Connected to the server" + arguments);
      if (!(app.user != null)) {
        user = prompt("Who are you?");
      }
      app.user = user;
      $("h1").text("Welcome " + user);
      addUser(user);
      app.server.emit("userName", app.user);
      app.server.on("message", function(data) {
        _log("Received message: " + data.message);
        return addMessage("in", data.message);
      });
      app.server.on("joined", function(user) {
        return addUser(user.userName);
      });
      return app.server.on("chat", function(data) {
        return _log("Received chat: " + data);
      });
    });
    return window.app = app;
  });

}).call(this);