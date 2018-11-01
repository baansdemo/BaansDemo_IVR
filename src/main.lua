channel.answer()
local functions = require('audio')
local dialno = channel.dial.dnis
channel.say(dialno)
channel.hangup()