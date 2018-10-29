-- This comment enforces unit-test coverage for this file:
-- coverage: 0

channel.answer()
channel.say("Hello Every one thankyou for calling.")
local digits = channel.gather()
channel.say(digits)
channel.hangup()

