{Adapter,TextMessage} = require 'hubot'

class SocketIO extends Adapter
  constructor: (@robot) ->
    @sockets = {}
    @io = require('socket.io').listen @robot.server
    super @robot

  send: (envelope, strings...) ->
    socket = @sockets[envelope.user.id]
    for str in strings
      socket.emit 'message', str

  reply: @prototype.send

  run: ->
    self = @
    @io.sockets.on 'connection', (socket) =>
      self.sockets[socket.id] = socket

      socket.on 'message', (message) =>
        user = self.robot.brain.userForId socket.id
        self.receive new TextMessage(user, message)

      socket.on 'disconnect', =>
        delete self.sockets[socket.id]

    @emit 'connected'

exports.use = (robot) ->
  new SocketIO robot
