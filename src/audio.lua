-- This comment enforces unit-test coverage for this file:
--overage: 0
--channel.answer()

--local assets = require("summit.asset")

channel.say("The following statements provide valuable information regarding your excavation…please listen carefully. The utilities or their locators will respond to your request.",{voice="man"})


function audioselect(numb)
	if numb == 1 then channel.say("If you do not begin your work within 10 calendar days of the start date and time or if your work is interrupted for more than 10 consecutive days, the marks will no longer be valid until you have requested and received a relocate for the area.",{voice="man"})
	else if numb == 2 then channel.say("Utilities will mark the area using color coded paint and flags. You need to stay 18 inches away on all sides of any markings with any power equipment used in the work. If you need to go closer, use hand-tools only and dig very carefully.",{voice="man"})
	else if numb == 3 then channel.say("Lines owned by the property owner such as many propane lines, sewer and water laterals or yard lighting will not be marked by the utilities.",{voice="man"})
	else if numb == 4 then channel.say("The member or members in question should respond by telephone as soon as possible or by the start date/time, whichever is later, to indicate when the facilities will be marked. No matter how the start date and time may read on the ticket itself, you will NOT be clear to dig until all member companies have responded in some fashion. In addition, excavating without waiting for member companies to respond and/or locate could result in you being liable for any damages that may occur.",{voice="man"})
	else if numb == 5 then channel.say("The member or members in question should respond by telephone as soon as possible or by the start date/time, whichever is later, to indicate when the facilities will be remarked. No matter how the start date and time may read on the ticket itself, you will NOT be clear to dig until ALL facilities at the work site have been marked by member companies.",{voice="man"})
	else if numb == 6 then channel.say("This ticket is only for planning purposes. You are not legally clear to dig on this ticket. A standard locate request must be filed at least three business days prior to excavation.",{voice="man"})
	end
	end
	end
	end
	end
	end	
end


function demofunction()

local dnis = channel.data.dnis
channel.say(dnis)
--local dnis= 3176086253

--print(dnis)

local StandardTicket = {1,2,3}
local EmergencyTicket = {4,1,2,3}
local PlanningTicket = {6,3}
local MultiTicket = {1,2,3,5,6}

if dnis == 3176086239 then
	for i=1,3 do
		audioselect(StandardTicket[i])
	end

else if dnis == 3176086250 then
	for i=1,4 do
		audioselect(EmergencyTicket[i])
	end

else if dnis == 3176086251 then
	audioselect(5)

else if dnis == 3176086252 then
	for i=1,2 do
		audioselect(PlanningTicket[i])
	end

else if dnis == 3176086253 then 
	for  i=1,5 do
		audioselect(MultiTicket[i])
	end
end
end
end
end
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