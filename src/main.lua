-- This comment enforces unit-test coverage for this file:
-- coverage: 0
local asset = require('summit.asset')

channel.answer()

channel.play("asset://sounds/titanic.wav")

function demofunction()

--channel.play("assets://sounds/Titanic.wav")
channel.say("Thank you for choosing us. Please press 1 to listen again and 2 to talk to our expert.")

local digit = channel.gather()

if digit == '1' then
	print(demofunction())

else if digit == '2' then

else 
channnel.say("Please press either 1 or 2.")
end
end
channel.hangup()
end

print(demofunction())