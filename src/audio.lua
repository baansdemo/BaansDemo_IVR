local application = require("summit.application")
local asset = require("summit.asset")
local counter = 0

channel.play("asset://sounds/1_FollowingStatementsListenClosely.wav")
channel.play("asset://sounds/2_TheUtilitiesorLocatorsWillRespond.wav")

function audioselect(numb)
	if numb == 1 then channel.play("asset://sounds/3_10CalendarDayStatement.wav")
	else if numb == 2 then channel.play("asset://sounds/4_18InchStatement.wav")
	else if numb == 3 then channel.play("asset://sounds/5_PrivateLineStatement.wav")
	else if numb == 4 then channel.say("The member or members in question should respond by telephone as soon as possible or by the start date/time, whichever is later, to indicate when the facilities will be marked. No matter how the start date and time may read on the ticket itself, you will NOT be clear to dig until all member companies have responded in some fashion. In addition, excavating without waiting for member companies to respond and/or locate could result in you being liable for any damages that may occur.",{voice="man"})
	else if numb == 5 then channel.play("asset://sounds/7_Relocates-LessThan3Days.wav")
	else if numb == 6 then channel.play("asset://sounds/8_PlanningPurposeStatement.wav")
	end
	end
	end
	end
	end
	end	
end

function demofunction()

counter = counter + 1

--local dnis = channel.data.dnis
--channel.say(dnis)
local number = application.get_destination()
channel.say("ad number"..number)

--local dnis= 3176086253

--print(dnis)

local StandardTicket = {1,2,3}
local EmergencyTicket = {4,1,2,3}
local PlanningTicket = {6,3}
local MultiTicket = {1,2,3,5,6}

if number == '2625187671' then
	for i=1,3 do
		audioselect(StandardTicket[i])
	end

else if number == '2625187672' then
	for i=1,4 do
		audioselect(EmergencyTicket[i])
	end

else if number == '+2625187673' then
	audioselect(5)

else if number == '2625187646' then
	for i=1,2 do
		audioselect(PlanningTicket[i])
	end

else if number == '2625187161' then 
	for  i=1,5 do
		audioselect(MultiTicket[i])
	end
end
end
end
end
end

channel.play("asset://sounds/9_MenuSelectionAudio1.wav")
channel.play("asset://sounds/10_MenuSelectionAudio2.wav")

local digit = channel.gather()

if digit == '1' then
	demofunction()

else if digit == '2' then
--channel.dial('',{destinationType = 'outbound'})
counter = 0
end
end
if counter == 1 then
demofunction()
else if counter ~= 1 then
	channel.hangup()
end
end

end --demofunction() end

demofunction()