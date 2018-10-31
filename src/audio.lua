-- This comment enforces unit-test coverage for this file:
--overage: 0
--channel.answer()

--local assets = require("summit.asset")

channel.say("The following statements provide valuable information regarding your excavation…please listen carefully. The utilities or their locators will respond to your request.",{voice="man"})





function demofunction()

local dnis = channel.data.dnis
channel.say(dnis)
--local dnis= 3176086250

--print(dnis)

--local StandardTicket = {1,2,3}

if dnis == '3176086250' then
	--for i=1,3 do
		--audioselect(StandardTicket[i])
		channel.say("1 If you do not begin your work within 10 calendar days of the start date and time or if your work is interrupted for more than 10 consecutive days, the marks will no longer be valid until you have requested and received a relocate for the area.",{voice="man"})
	--end
end
channel.say("If you would like to repeat this message, press 1,If you have questions and would like to speak with a representative, press 2",{voice="man"})
local digit = channel.gather()
if digit == '1' then
	demofunction()

else if digit == '2' then

else
channel.say("Please press either 1 or 2.",{voice="man"})
end
end
channel.hangup()
end

demofunction()