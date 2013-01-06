###
module dependencies.
###
express = require("express")
stylus = require("stylus")
socket = require("socket.io")
routes = require("./routes")
display = require("./routes/display")
control = require("./routes/control")
http = require("http")
path = require("path")
fs = require('fs')


app = module.exports = express.createServer()
io = socket.listen(app)

photoDir = "/uploads/"

uploadDir = __dirname + '/public' + photoDir



app.configure ->
  app.set "port", process.env.PORT or 3000
  app.set "views", __dirname + "/views"
  app.set "view engine", "jade"
  app.set "view options", layout: false  
  app.use express.favicon()
  app.use express.logger("dev")
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use app.router
  app.use stylus.middleware
    debug: true
    force: true
    src: path.join(__dirname, "public")
    dest: path.join(__dirname, "public")

  app.use express.static(path.join(__dirname, "public"))

app.configure "development", ->
  app.use express.errorHandler()

app.get "/", routes.index
app.get "/display", display.display
app.get "/control", control.index
app.post "/newphoto", (req, res, next) -> 
  fs.readFile req.files.photo.path, (err, data) -> 
    d1=new Date();
    time = d1.getFullYear() + '' + d1.getMonth() + d1.getDate() + d1.getHours() + d1.getMinutes() + d1.getSeconds()
     
    newPath = uploadDir + time + req.files.photo.name;

    fs.writeFile newPath, data, (err) -> 
      res.redirect("/control");
      
    


app.listen 3000, ->
  console.log "==> Server listening on port %d in %s mode", app.address().port, app.settings.env

displayList = {}

io.sockets.on "connection", (socket) ->
  console.log "User connected"
  socket.emit "message",
    message: "Welcome to the display counter"

  socket.on "displayRegister", (data) ->
    data.message = "init"
    data.id = socket.id
    console.log "Display Registered " + data
    displayList[socket.id] = data
    # console.log users.contains(data)
    console.log displayList
    socket.emit "overlayMessage", data
    io.sockets.in("controls").emit  "showDisplayList", displayList 

  socket.on "displayUpdate", (data) ->
    console.log "Display update " + data
    for key, value of data
      displayList[socket.id][key] = value
    
    console.log "Display update " + data
    io.sockets.in("controls").emit  "showDisplayList", displayList 

  socket.on "controlRegister", () ->
    console.log "controlRegister"
    #socket.emit "showDisplayList", displayList
    socket.join('controls'); 
    io.sockets.in("controls").emit  "showDisplayList", displayList 
    
    fs.readdir uploadDir, (err, list)->
      list.sort()
      list.reverse()

      for name, key in list
        list[key] = photoDir + name

      console.log list
      io.sockets.in("controls").emit  "updatePhotoList", list

  socket.on "controlShowDisplay", (data) ->
    console.log "controlshow" + data
    io.sockets.socket(data.id).emit "overlayMessage", data  if io.sockets.socket(data.id)	
    displayList[data.id] = data

  socket.on "controlHideDisplay", () ->
    for kk, vv of displayList
      io.sockets.socket(kk).emit "overlayMessageHide"	

  socket.on "disconnect", () ->
    console.log "User disconnect"
    delete displayList[socket.id] if displayList[socket.id]
    io.sockets.in("controls").emit  "showDisplayList", displayList 

