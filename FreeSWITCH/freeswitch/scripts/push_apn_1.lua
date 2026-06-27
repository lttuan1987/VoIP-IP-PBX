freeswitch.consoleLog("INFO", "Starting APNs push + wait loop.\n")

-- local http = require("socket.http")
-- local ltn12 = require("ltn12")
-- local json = require("cjson")
local curl = require "freeswitch.curl"

callee = argv[1]
freeswitch.consoleLog("ERR", "Push request for: " .. tostring(callee) .. "\n")

function handler(callee)
	local api = freeswitch.API()
--	local domain = freeswitch.getGlobalVariable("domain_name")
  -- local tries = 10
  -- local wait_time = 1000 -- milliseconds

	freeswitch.consoleLog("ERR", "======= EXT: " .. callee .. "\n")

  local api_url = "https://api-sb11.rpc.ziichat.dev/Call/PushNotification"
  

  local post_data = {
    callee = callee,
    caller = "test_caller", -- Replace with actual caller if needed
    domain = "example.com" -- Replace with actual domain if needed
  }

  -- Tạo đối tượng curl
  local c = curl.new()

  -- Thiết lập các tùy chọn cho yêu cầu POST
  c:setopt(curl.OPT_URL, url)
  c:setopt(curl.OPT_POST, true)
  c:setopt(curl.OPT_HTTPHEADER, {
      "Content-Type: application/json",
      "Accept: application/json"
  })
  c:setopt(curl.OPT_POSTFIELDS, post_data)

  -- Thực hiện yêu cầu
  local ok, err = c:perform()
  freeswitch.consoleLog("ERR", "Result: " .. tostring(ok) .. tostring(err) .. "\n")

  -- Kiểm tra kết quả
  if ok then
      local response_code = c:getinfo(curl.INFO_RESPONSE_CODE)
      local response_body = c:body()
      freeswitch.consoleLog("INFO", "Response Code: " .. response_code .. "\n")
      freeswitch.consoleLog("INFO", "Response Body: " .. response_body .. "\n")
  else
      freeswitch.consoleLog("ERR", "Error: " .. err .. "\n")
  end

  -- Đóng curl
  c:close()
end

handler(callee)
