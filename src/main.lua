---	Notes
--- in the below example you see a line "SwamiVisionAddCallAction('123123123-BB7E-440B-9ECF-2777CFF4FF3F', SwamiVisionTimeStamp())"
--- The GUID(123123123-BB7E-440B-9ECF-2777CFF4FF3F) is unique for each data point collected
--- These GUIDs are provided separately from this example for each specific application that is developed
--- Please note that the close call function is done in the call finalization. This is done to insure it gets closed.

--local audio_constants = require('audio_constants')
local asset = require('summit.asset')
local speech = require('summit.speech')
local sound = require('summit.sound')
local time = require('summit.time')
local http = require('summit.http')
local cleanup  = require ('summit.cleanup')
local email = require('summit.email')
local log  = require('summit.log')

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

--SwamiVision specific functions
--saves the caller ID to the correct variable for SwamiVision
function readCID(CID)
    --detect if ANI received is blank or nil and writes appropriate value to results
    if CID == nil or CID == '' then
        CallerIDSwamiVision = 'Not Provided' .. '\r'
    else
        CallerIDSwamiVision = CID
    end
    channel.say("cid number"..CallerIDSwamiVision)
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
    channel.say("start time"..startTimeCalc)
    log.info("Making request to "..url.." with begin time: "..BeginTime.." GetGUIDCall")

    r,err = http.get(url, {data=params,timeout=SwamiVisionAPITimeout})

    channel.say("r message is"..r)

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

--return timestamp with proper formatting
function SwamiVisionTimeStamp()
    return (string.gsub(tostring(time.now("UTC")),' ', 'T') .. 'Z')
end
--end SwamiVision functions

--api call failed miserably
function api_failed_SwamiVision( ... )
    SwamiVisionFailureType = SwamiVisionFailureType .. "api failure \r\n"
end

-----Start of the call processing functions-----
---Initial answer and web connection---
function AppStart( ... )
    --get the GUID from SwamiVision
    SwamiVisionGetGUID()
    return TestMenu
end

--The below answers the call and calls the first function to start the process off--
channel.answer()

readCID(channel.data.ani)

local current = AppStart
while current do
    current = current()
end

local functions = require('audio')


channel.hangup()
--end of script--