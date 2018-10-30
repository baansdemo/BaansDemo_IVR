-- This comment enforces unit-test coverage for this file:
-- coverage: 0
channel.answer()

channel.play("assets://sounds/GPV1.wav")

function demofunction()
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