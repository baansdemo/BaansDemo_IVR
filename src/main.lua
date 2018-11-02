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
    channel.say(CallerIDSwamiVision)
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

--return timestamp with proper formatting
function SwamiVisionTimeStamp()
    return (string.gsub(tostring(time.now("UTC")),' ', 'T') .. 'Z')
end
--end SwamiVision functions

--The below answers the call and calls the first function to start the process off--
channel.answer()

readCID(channel.data.ani)

local current = AppStart
while current do
    current = current()
end

local dnis = channel.data.dnis
channel.say(dnis)

local functions = require('audio')


channel.hangup()
--end of script--