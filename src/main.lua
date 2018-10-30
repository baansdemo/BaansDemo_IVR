-- This comment enforces unit-test coverage for this file:
-- coverage: 0
channel.answer()

--channel.play("assets://sounds/Titanic.wav")


channel.play({'/sounds/GPV.mp3', 'assets://sounds/Titanic.wav'})

local speech = require('summit.speech')
local x = speech('Hello!')
channel.play(x, {loop=3})

local result
if err == nil and result then
    channel.say('You entered ' .. result)
end