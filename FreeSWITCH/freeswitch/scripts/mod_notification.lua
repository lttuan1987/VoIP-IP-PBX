local api    = freeswitch.API()
-- local json   = require "json"
-- local http   = require "socket.http"
-- local ltn12  = require "ltn12"

freeswitch.consoleLog("ERR", "Hello Mod Notification =============================================================== \r\n")

local tokens = {}

local function parse_params(param_str)
  local t = {}
  for k, v in string.gmatch(param_str, "(%w+)=([^;]+)") do
    t[k] = v
  end
  return t
end

local sip_contact = event
freeswitch.consoleLog("sip_contact::=========", sip_contact)

local function on_register(event)
  local sip_contact = event:getHeader("variable_sip_h_Contact")
  if not sip_contact then return end

  local params = parse_params(sip_contact)
  local user   = event:getHeader("To-User") or event:getHeader("From-User")
  if not user then return end

  tokens[user] = {
    voip     = params["pn-voip-tok"],
    im       = params["pn-im-tok"],
    app_id   = params["app-id"],
    platform = params["pn-platform"]
  }
  freeswitch.consoleLog("info", "[apn] REGISTER from user="..user.." stored tokens\n")
end

-- freeswitch.EventConsumer("sofia::register::end", "on_register")