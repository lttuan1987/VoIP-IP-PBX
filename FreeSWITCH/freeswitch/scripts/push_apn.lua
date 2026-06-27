freeswitch.consoleLog("INFO", "Starting APNs push + wait loop.\n")

local event_consumer = freeswitch.EventConsumer()

event_consumer:bind("CUSTOM", "sofia::register")
event_consumer:bind("API", "CHANNEL_ANSWER")
event_consumer:bind("ALL")

local handlers = {}

handlers["CHANNEL_STATE"] = function(event)
	local uuid = event:getHeader("Unique-ID")
    freeswitch.consoleLog("INFO", "CHANNEL_ANSWERRRRRRRRRRR" .. uuid)
end

callee = argv[1]
freeswitch.consoleLog("ERR", "Push request for: " .. tostring(callee) .. "\n")

local domain = freeswitch.getGlobalVariable("domain_name")
local max_wait_ms = 20000
local check_interval_ms = 1000

-- while true do
--     local event = event_consumer:pop(1, 1000)
--     
--     if event then
--         local event_name = event:getHeader("Event-Name")
--         local handler = handlers[event_name]
--         
--         if handler then
--             pcall(handler, event) -- Sử dụng pcall để bắt lỗi
--         else
--             freeswitch.consoleLog("DEBUG", "Unhandled event: " .. (event_name or "unknown"))
--         end
--     end
--     
--     -- Có thể thêm logic kiểm tra dừng
--     if os.time() % 60 == 0 then
--         freeswitch.consoleLog("INFO", "Event listener still running...")
--     end
-- end

function handler(callee)
	local api = freeswitch.API()

	-- freeswitch.consoleLog("ERR", "======= EXT: " .. callee .. "\n")

	local api_url = "https://api-sb11.rpc.ziichat.dev/Call/PushNotification"
	local username = "minhcute123"
	local password = "1234"

	local command = string.format(
	  "curl -X POST -u '%s:%s' -H 'Content-Type: application/json' -d '{\"callee\":\"%s\"}' %s",
	  username, password, callee, api_url
	)
	
	freeswitch.consoleLog("ERR", command .. "\n")

	local result = os.execute(command)
	freeswitch.consoleLog("ERR", "os.execute returned: " .. tostring(result) .. "\n")

	local elapsed = 0
	local contact = nil
	local api = freeswitch.API()

	while elapsed < max_wait_ms do
        freeswitch.consoleLog("INFO", "Event listener still running...")	 
	
		local event = event_consumer:pop(1, 100)
		    
	    if event then
	        local event_name = event:getHeader("Event-Name")
	        local handler = handlers[event_name]
	        
	        if handler then
	            pcall(handler, event)
	            freeswitch.consoleLog("INFO", "EVENT FOUND, BREAK THE LOOP NOW!!!!!!!")
	        else
	            freeswitch.consoleLog("WARN", "Unhandled event: " .. (event_name or "unknown"))
	        end
	    else
	        freeswitch.consoleLog("ERR", "Event error" .. tostring(event))    
	    end

		contact = api:execute("sofia_contact", callee .. "@" .. domain)
		if contact and not contact:match("^error") then
			freeswitch.consoleLog("INFO", callee .. " is now registered: " .. contact .. "\n")
			session:execute("bridge", contact)
		end

		freeswitch.consoleLog("INFO", callee .. " not registered yet, wait " .. check_interval_ms .. "ms...\n")
		freeswitch.msleep(check_interval_ms)
		elapsed = elapsed + check_interval_ms
	end

	-- Gọi hoặc treo máy
	-- if contact and not contact:match("^error") then
	-- 	session:execute("bridge", contact)
	-- else
	-- freeswitch.consoleLog("ERR", "User not registered after waiting.\n")
	-- session:hangup("USER_NOT_REGISTERED")
	-- end

end

handler(callee)
