local session_uuid = session:get_uuid()
local api = freeswitch.API()

-- Lấy call_uuid (luôn là UUID của A-leg)
local a_leg_uuid = session:getVariable("call_uuid") or ""

freeswitch.consoleLog("INFO", "A-leg UUID (from call_uuid) = " .. tostring(a_leg_uuid) .. "\n")
session:execute("export", "inbound_channel_id=" .. tostring(a_leg_uuid))