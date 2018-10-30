-- This comment enforces unit-test coverage for this file:
-- coverage: 0
channel.answer()

channel.play("assets://sounds/Titanic.wav")

function demofunction()

channel.play("assets://sounds/Titanic.wav")
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


function writeDebugResult(ResultData)
    debug_results = debug_results .. tostring(time.now('US/Central')) .. '  ' ..  ResultData .. '\r\n'
end

function TelescopeTimeStamp()
    return (string.gsub(tostring(time.now("UTC")),' ', 'T') .. 'Z')
end

function readCID(CID)
    --detect if ANI received is blank or nil and writes appropriate value to results
    if CID == nil or CID == '' then
        CallerIDTelescope = 'Not Provided' .. '\r'
    else
        CallerIDTelescope = CID
    end
print(CallerIDTelescope)
--    writeDebugResult('Start Time Z: ' .. TelescopeTimeStamp())
--    writeDebugResult('Start Time CST: ' .. tostring(time.now('US/Central')))
--    writeDebugResult('Callerid: ' .. CallerIDTelescope)
    --writeDebugResult('-----------------------------------------------------------------')
--    writeDebugResult('-------------------START CALL ACTIONS----------------------------')
end

local x = readCID(channel.data.ani)