---	Notes
--- in the below example you see a line "SwamiVisionAddCallAction('123123123-BB7E-440B-9ECF-2777CFF4FF3F', SwamiVisionTimeStamp())"
--- The GUID(123123123-BB7E-440B-9ECF-2777CFF4FF3F) is unique for each data point collected
--- These GUIDs are provided separately from this example for each specific application that is developed
--- Please note that the close call function is done in the call finalization. This is done to insure it gets closed.

local audio_constants = require('audio_constants')
local asset = require('summit.asset')
local speech = require('summit.speech')
local sound = require('summit.sound')
local time = require('summit.time')
local http = require('summit.http')
local cleanup  = require ('summit.cleanup')
local email = require('summit.email')
local log  = require('summit.log')
local application = require("summit.application")
local counter = 0

--SwamiVision variables
local SwamiVisionAPITimeout = 5
local CallGUID = nil
local CallerIDSwamiVision = '5556667777'
local urlGUID = 'https://telescopeapi.voipswami.com/api/CustomerLogin'
local urlCreateAction = 'https://telescopeapi.voipswami.com/api/CreateCallAction'
local urlCloseAction = 'https://telescopeapi.voipswami.com/api/CloseCallAction'
local urlClose =  'https://telescopeapi.voipswami.com/api/CloseCall'
local AccountName = 'Diggers Hotline Inc.'
local PasswordHash = '43d21ca4bc5201cd80da1c0b74b735a3'
local IVRName = 'After Call Information IVR'
local BeginTime = string.gsub(tostring(time.now("UTC")),' ', 'T') .. 'Z'
local SwamiVisionHangup = '1' --seed hangup as yes so that anytime a call ends before we say it's not a hangup, it is recorded as a hangup
local SwamiVisionFailureType = ''
local CallActionGUID = 'reset'
local to_email = 'nikhilsaini5748@gmail.com'--'caytonr@voipswami.com,petersone@voipswami.com' --recipient email addresses separated by comma if multiple
local from_email = 'shoretelplatform@voipswami.com' --senders email address. MUST be in allowed senders list in summit dashboard
local subject_email = 'SwamiVision API ERROR - ' --email subject
local debug_results = '' --seed debug results to send with any api error emails
local timecalc_over_1 = ''
local TestCall = '1' -- set to 1 to mark calls as tests
--End SwamiVision Variables


--call finalization functions
function finalizeCall()
    --close call in SwamiVision
    SwamiVisionCloseCall(SwamiVisionHangup, SwamiVisionTimeStamp())

    --email if there is any sort of api failure
    if SwamiVisionFailureType == '' then
        --do nothing the call was a success
    else
        --email us the error(s)
        for to_address in string.gmatch(to_email,"([^,]+)") do
            email.send(to_address, from_email, subject_email ..' ' .. AccountName .. ' ' .. IVRName, SwamiVisionFailureType .. '\r\n' .. debug_results)
        end
    end
end

--call cleanup to process data received even if call disconnects early or there is a script issue
cleanup.register(finalizeCall, 'finalizeCall', false)

--end call finalization


--Generic Functions
function FailedCallTroubleFunction( ... )
   channel.play('asset://InvalidInputGoodbye.wav')
   channel.hangup()
end
--End Generic Functions


--SwamiVision specific functions
--saves the caller ID to the correct variable for SwamiVision
function readCID(CID)
    --detect if ANI received is blank or nil and writes appropriate value to results
    if CID == nil or CID == '' then
        CallerIDSwamiVision = 'Not Provided' .. '\r'
    else
        CallerIDSwamiVision = CID
    end
    writeDebugResult('Start Time Z: ' .. SwamiVisionTimeStamp())
    writeDebugResult('Start Time CST: ' .. tostring(time.now('US/Central')))
    writeDebugResult('Callerid: ' .. CallerIDSwamiVision)
    --writeDebugResult('-----------------------------------------------------------------')
    writeDebugResult('-------------------START CALL ACTIONS----------------------------')
end

--writes specified results to the debug data for email
function writeDebugResult(ResultData)
    debug_results = debug_results .. tostring(time.now('US/Central')) .. '  ' ..  ResultData .. '\r\n'
end

--submits needed data to SwamiVision to start the call and retrieve the unique call GUID
function SwamiVisionGetGUID( ... )
    local startTimeCalc
    local endTimeCalc

    params = {AccountName=AccountName, PasswordHash=PasswordHash, IVRName=IVRName, BeginTime=BeginTime, CallerID=CallerIDSwamiVision, TestCall=TestCall}
    url = urlGUID

    startTimeCalc = time.to_unix_ts(time.now("UTC"))
    log.info("Making request to "..url.." with begin time: "..BeginTime.." GetGUIDCall")

    r,err = http.get(url, {data=params,timeout=SwamiVisionAPITimeout})

    --log.info("HTTP Response content: "..r.content.." status code: "..r.statusCode.." reason: "..r.reason)
    endTimeCalc = time.to_unix_ts(time.now("UTC"))
    writeDebugResult('Get GUID: ' .. (endTimeCalc - startTimeCalc))

    if tonumber(endTimeCalc - startTimeCalc) > 1 then
        timecalc_over_1 = 'yes'
    end

    if not err then

        local data = string.gsub(r.content,'"','')

        if not data then
            writeDebugResult('No data received during GUID retrieval')
            api_failed_SwamiVision()
        else
            if data == '{Message:An error has occurred.}' or data == 'error' or string.sub(data,1,9) == '<!DOCTYPE' then
                writeDebugResult('Error receiving GUID ' .. string.sub(data,1,40))
                api_invalid_data(string.sub(data,1,40), 'GetGUID Failure')
            else
                CallGUID = data
                writeDebugResult('CallGUID: ' .. data)
            end
        end
    else
        writeDebugResult('No data received during GUID retrieval - web connection error')
        writeDebugResult(err)
        api_failed_SwamiVision()
    end
end

--submits a call action to SwamiVision
function SwamiVisionAddCallAction( PromptGUID, BeginTime )
    CallActionGUID = 'reset'
    if CallGUID ~= nil then
        writeDebugResult('-----------------------------------------------------------------')
        local startTimeCalc
        local endTimeCalc
        params = {CallGUID=CallGUID, BeginTime=BeginTime, PromptGUID=PromptGUID}
        url = urlCreateAction

        startTimeCalc = time.to_unix_ts(time.now("UTC"))
        log.info("Making request to "..url.." with begin time: "..BeginTime.." and prompt GUID:"..PromptGUID)

        r,err = http.get(url, {data=params,timeout=SwamiVisionAPITimeout})

        --log.info("HTTPResponse content: "..r.content.." status code: "..r.statusCode.." reason: "..r.reason)
        endTimeCalc = time.to_unix_ts(time.now("UTC"))
        writeDebugResult('Add Action: ' .. (endTimeCalc - startTimeCalc))

        if tonumber(endTimeCalc - startTimeCalc) > 1 then
            timecalc_over_1 = 'yes'
        end

        if not err then

            local data = string.gsub(r.content,'"','')

            if not data then
                writeDebugResult('No data received during Create Action' .. CallGUID .. '   ' .. PromptGUID)
                api_failed_SwamiVision()
            else
                if data == '{Message:An error has occurred.}' or data == 'error' or string.sub(data,1,9) == '<!DOCTYPE' or data == '' then
                    writeDebugResult('Error receiving Action GUID ' .. string.sub(data,1,40))
                    writeDebugResult(PromptGUID .. ' ' .. PromptGUID .. ' ' .. PromptGUID)
                    api_invalid_data(string.sub(data,1,40), 'GetActionGUID Failure')
                else
                    CallActionGUID = data
                    writeDebugResult('CallActionGUID: ' .. data)
                end
            end
        else
            writeDebugResult('No data received during Create Action - web connection failure ' .. CallGUID .. '   ' .. PromptGUID)
            writeDebugResult(err)
            api_failed_SwamiVision()
        end
    else
        --do nothing because the call GUID is invalid
    end
end

--submits a call action to SwamiVision
function SwamiVisionCloseCallAction( TSCallActionGUID,ActionValue,TimeStamp )
    if CallGUID ~= nil and TSCallActionGUID ~= 'reset' then
        local startTimeCalc
        local endTimeCalc
        params = {CallActionGUID=TSCallActionGUID, ActionValue=ActionValue, EndTime=TimeStamp}
        url = urlCloseAction

        startTimeCalc = time.to_unix_ts(time.now("UTC"))
        log.info("Making request to "..url.." with begin time: "..TimeStamp.." and call action GUID:"..TSCallActionGUID)

        r,err = http.get(url, {data=params,timeout=SwamiVisionAPITimeout})

        --log.info("HTTPResponse content: "..r.content.." status code: "..r.statusCode.." reason: "..r.reason)
        endTimeCalc = time.to_unix_ts(time.now("UTC"))
        writeDebugResult('Close action: ' .. (endTimeCalc - startTimeCalc))

        if tonumber(endTimeCalc - startTimeCalc) > 1 then
            timecalc_over_1 = 'yes'
        end

        if not err then

            local data = string.gsub(r.content,'"','')

            if not data then
                writeDebugResult('No data received during close call action ' .. CallGUID .. '   ' .. TSCallActionGUID)
                api_failed_SwamiVision()
            else
                if data == 'ok' then
                --channel.say(data)
                else
                    --data received is in error
                    writeDebugResult('Error writing call action Close to API for PromptGUID: ' .. TSCallActionGUID .. ' ' .. ActionValue .. ' ' .. TimeStamp)
                    api_invalid_data(string.sub(data,1,40), 'CallActionGUID: ' .. TSCallActionGUID)
                end
            end
        else
            writeDebugResult('No data received during close call action - web connection failure ' .. CallGUID .. '   ' .. TSCallActionGUID)
            writeDebugResult(err)
            api_failed_SwamiVision()
        end
    else
        --do nothing because the call GUID or action GUID is invalid so we can't write data
    end
    --reset the call action GUID so it doesn't try to close action again if a get GUID failure
    CallActionGUID = 'reset'
end


--submits close call action to SwamiVision
function SwamiVisionCloseCall( Hangup,TimeStamp )
    if CallGUID ~= nil then
        writeDebugResult('-----------------------------------------------------------------')
        local startTimeCalc
        local endTimeCalc
        local closeRetryCount = 0
        params = {CallGUID=CallGUID, PasswordHash=PasswordHash, Hangup=Hangup, EndTime=TimeStamp}
        url = urlClose

        --try closing the call three times since it wont affect the callers perception of flow
        while closeRetryCount < 3 do
            startTimeCalc = time.to_unix_ts(time.now("UTC"))
            log.info("Making request to "..url.." with begin time: "..TimeStamp.." Close Call Action")

            r,err = http.get(url, {data=params,timeout=30})

            --log.info("HTTPResponse content: "..r.content.." status code: "..r.statusCode.." reason: "..r.reason)
            endTimeCalc = time.to_unix_ts(time.now("UTC"))
            writeDebugResult('Close call: ' ..  (endTimeCalc - startTimeCalc))

            if tonumber(endTimeCalc - startTimeCalc) > 1 then
                timecalc_over_1 = 'yes'
            end

            if not err then
                break
            else
                closeRetryCount = closeRetryCount + 1
            end
        end

        if not err then

            local data = string.gsub(r.content,'"','')

            if not data then
                writeDebugResult('No data received during close call action after ' .. (closeRetryCount + 1) .. ' tries')
                api_failed_SwamiVision()
            else
                if data == 'ok' then
                    --do nothing, call closed successfully
                    writeDebugResult('Number of close call attempts: ' .. (closeRetryCount + 1))
                else
                    --{Message:An error has occurred.}' or data == 'error'
                    writeDebugResult('Error closing call ' .. string.sub(data,1,40))
                    api_invalid_data(string.sub(data,1,40),'Closing Call')
                end
            end
        else
            writeDebugResult('No data received during close call action - web connection error')
            writeDebugResult('Number of close tries' .. (closeRetryCount + 1))
            writeDebugResult(err)
            api_failed_SwamiVision()
        end
    else
        --do nothing because the call GUID is invalid and closing the call is pointless
    end
end

--api call failed miserably
function api_failed_SwamiVision( ... )
    SwamiVisionFailureType = SwamiVisionFailureType .. "api failure \r\n"
end

--api call worked but we sent something over we shouldn't have
function api_invalid_data( data, additionalData )
    SwamiVisionFailureType = SwamiVisionFailureType .. 'api returned invalid data. ' .. data .. ' ' .. additionalData .. '\r\n'
end

--return timestamp with proper formatting
function SwamiVisionTimeStamp()
    return (string.gsub(tostring(time.now("UTC")),' ', 'T') .. 'Z')
end
--end SwamiVision functions


--Example of an application start to finish:

-----Start of the call processing functions-----
---Initial answer and web connection---
function AppStart( ... )
    --get the GUID from SwamiVision
    SwamiVisionGetGUID()
    return demofunction
end

function TestMenu( ... )

	local MyTestMenu = '0'
    SwamiVisionAddCallAction('12199520-DF34-471A-ADFC-4B1EDC0638D5', SwamiVisionTimeStamp())
    MyTestMenu = channel.gather({play=audio_constants.TestMenuAudio, maxDigits=1, attempts=1, timeout=3, regex='[12]', invalidPlay=audio_constants.blank_audio})--, play=audio_constants.TestMenuAudio
        
        channel.say(MyTestMenu)

        if MyTestMenu == '1' then
        	demofunction()
            writeDebugResult('23123123-BB7E-440B-9ECF-2777CFF4FF3F' .. ' ' ..  MyTestMenu .. ' ' .. SwamiVisionTimeStamp())
            SwamiVisionCloseCallAction(CallActionGUID, MyTestMenu, SwamiVisionTimeStamp())
            return NextFunction1
        elseif MyTestMenu == '2' then
   			counter = 0
			--channel.dial('',{destinationType = 'outbound'})
            writeDebugResult('23123123-BB7E-440B-9ECF-2777CFF4FF3F' .. MyTestMenu .. SwamiVisionTimeStamp())
            SwamiVisionCloseCallAction(CallActionGUID, MyTestMenu, SwamiVisionTimeStamp())
            return NextFunction2
		-- elseif MyTestMenu == '0' then
		-- 	demofunction()
        else
        	if counter == 1 then
        		demofunction()
        	end
            writeDebugResult('23123123-BB7E-440B-9ECF-2777CFF4FF3F' .. ' Caller did not make a selection' .. SwamiVisionTimeStamp())
            SwamiVisionCloseCallAction(CallActionGUID, ' Caller did not make a selection', SwamiVisionTimeStamp())
            return FailedCallTroubleFunction
        end
end

function audioselect(numb)
	if numb == 1 then
			channel.play("asset://sounds/3_10CalendarDayStatement.wav")
	elseif numb == 2 then 
			channel.play("asset://sounds/4_18InchStatement.wav")
	elseif numb == 3 then 
			channel.play("asset://sounds/5_PrivateLineStatement.wav")
	elseif numb == 4 then 
			channel.say("The member or members in question should respond by telephone as soon as possible or by the start date/time, whichever is later, to indicate when the facilities will be marked. No matter how the start date and time may read on the ticket itself, you will NOT be clear to dig until all member companies have responded in some fashion. In addition, excavating without waiting for member companies to respond and/or locate could result in you being liable for any damages that may occur.",{voice="man"})
	elseif numb == 5 then 
			channel.play("asset://sounds/7_Relocates-LessThan3Days.wav")
	elseif numb == 6 then 
			channel.play("asset://sounds/8_PlanningPurposeStatement.wav")
	end	
end

function demofunction()

counter = counter + 1
if counter == 1 then
	channel.play("asset://sounds/1_FollowingStatementsListenClosely.wav")
	channel.play("asset://sounds/2_TheUtilitiesorLocatorsWillRespond.wav")
end

local number = application.get_destination()

local StandardTicket = {1,2,3}
local EmergencyTicket = {4,1,2,3}
local PlanningTicket = {6,3}
local MultiTicket = {1,2,3,5,6}

if number == '2625187671' then
	for i=1,3 do
		audioselect(StandardTicket[i])
	end

elseif number == '2625187672' then
	for i=1,4 do
		audioselect(EmergencyTicket[i])
	end

elseif number == '2625187673' then
	audioselect(5)

elseif number == '2625187646' then
	for i=1,2 do
		audioselect(PlanningTicket[i])
	end

elseif number == '2625187161' then 
	for  i=1,5 do
		audioselect(MultiTicket[i])
	end

end

TestMenu()

end --demofunction() end

--The below answers the call and calls the first function to start the process off--
channel.answer()

readCID(channel.data.ani)

local current = AppStart
while current do
    current = current()
end

channel.hangup()
--end of script--