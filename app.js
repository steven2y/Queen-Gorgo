// Generated by CoffeeScript 1.4.0

/*
module dependencies.
*/


(function() {
  var app, control, display, displayList, express, fs, http, io, path, photoDir, routes, socket, stylus, uploadDir;

  express = require("express");

  stylus = require("stylus");

  socket = require("socket.io");

  routes = require("./routes");

  display = require("./routes/display");

  control = require("./routes/control");

  http = require("http");

  path = require("path");

  fs = require('fs');

  app = module.exports = express.createServer();

  io = socket.listen(app);

  photoDir = "/uploads/";

  uploadDir = __dirname + '/public' + photoDir;

  app.configure(function() {
    app.set("port", process.env.PORT || 3000);
    app.set("views", __dirname + "/views");
    app.set("view engine", "jade");
    app.set("view options", {
      layout: false
    });
    app.use(express.favicon());
    app.use(express.logger("dev"));
    app.use(express.bodyParser());
    app.use(express.methodOverride());
    app.use(app.router);
    app.use(stylus.middleware({
      debug: true,
      force: true,
      src: path.join(__dirname, "public"),
      dest: path.join(__dirname, "public")
    }));
    return app.use(express["static"](path.join(__dirname, "public")));
  });

  app.configure("development", function() {
    return app.use(express.errorHandler());
  });

  app.get("/", routes.index);

  app.get("/display", display.display);

  app.get("/control", control.index);

  app.post("/newphoto", function(req, res, next) {
    return fs.readFile(req.files.photo.path, function(err, data) {
      var d1, newPath, time;
      d1 = new Date();
      time = d1.getFullYear() + '' + d1.getMonth() + d1.getDate() + d1.getHours() + d1.getMinutes() + d1.getSeconds();
      newPath = uploadDir + time + req.files.photo.name;
      return fs.writeFile(newPath, data, function(err) {
        return res.redirect("/control");
      });
    });
  });

  app.listen(3000, function() {
    return console.log("==> Server listening on port %d in %s mode", app.address().port, app.settings.env);
  });

  displayList = {};

  io.sockets.on("connection", function(socket) {
    console.log("User connected");
    socket.emit("message", {
      message: "Welcome to the display counter"
    });
    socket.on("displayRegister", function(data) {
      data.message = "init";
      data.id = socket.id;
      console.log("Display Registered " + data);
      displayList[socket.id] = data;
      console.log(displayList);
      socket.emit("overlayMessage", data);
      return io.sockets["in"]("controls").emit("showDisplayList", displayList);
    });
    socket.on("displayUpdate", function(data) {
      var key, value;
      console.log("Display update " + data);
      for (key in data) {
        value = data[key];
        displayList[socket.id][key] = value;
      }
      console.log("Display update " + data);
      return io.sockets["in"]("controls").emit("showDisplayList", displayList);
    });
    socket.on("controlRegister", function() {
      console.log("controlRegister");
      socket.join('controls');
      io.sockets["in"]("controls").emit("showDisplayList", displayList);
      return fs.readdir(uploadDir, function(err, list) {
        var key, name, _i, _len;
        list.sort();
        list.reverse();
        for (key = _i = 0, _len = list.length; _i < _len; key = ++_i) {
          name = list[key];
          list[key] = photoDir + name;
        }
        console.log(list);
        return io.sockets["in"]("controls").emit("updatePhotoList", list);
      });
    });
    socket.on("controlShowDisplay", function(data) {
      console.log("controlshow" + data);
      if (io.sockets.socket(data.id)) {
        io.sockets.socket(data.id).emit("overlayMessage", data);
      }
      return displayList[data.id] = data;
    });
    socket.on("controlHideDisplay", function() {
      var kk, vv, _results;
      _results = [];
      for (kk in displayList) {
        vv = displayList[kk];
        _results.push(io.sockets.socket(kk).emit("overlayMessageHide"));
      }
      return _results;
    });
    return socket.on("disconnect", function() {
      console.log("User disconnect");
      if (displayList[socket.id]) {
        delete displayList[socket.id];
      }
      return io.sockets["in"]("controls").emit("showDisplayList", displayList);
    });
  });

}).call(this);
