channel.answer()

--local log = require("summit.log")

local dnis = channel.data.dnis
channel.say(dnis)

--local application = require("summit.application")

-- local number = application.get_destination()
-- channel.say(number)

-- log.info(app_dest)
-- local dss = channel.data.dnis
-- channel.say(dss)
-- channel.dial(channel.data.dnis)

local functions = require('audio')