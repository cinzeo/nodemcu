--wifisetup.lua

local module = {}
module.wifi_connect_state=false

local wifi_connecting_flag=false



local function wifi_wait_ip()
	if wifi.sta.getip()== nil then
		print("IP is not available, Waiting...")
	else
		print("Got a IP address!")
		--tmr.stop(1)
		mytimer:unregister()
		mytimer=nil
		print("====================================")
		print("ESP8266 mode : "..wifi.getmode())
		print("Chip ID      : "..node.chipid());
		print("MAC address  : "..wifi.ap.getmac())
		print("IP address   : "..wifi.sta.getip())
		print("====================================")
		wifi_connecting_flag=false
		module.wifi_connect_state=true
		--mqttclient.start()
	end
end

local function wifi_start(ap_list)
    if not ap_list then 
		print("Error getting AP list")
		return
	end
	if not config.SSID then 
		print("SSID not config")
		return
	end
	
	print("Scan WIFI AP ... ")
    for key,value in pairs(ap_list) do
		print(key.." : "..value)
		if config.SSID[key] then
			wifi.setmode(wifi.STATION);
			wifi.sta.config({ssid=key,pwd=config.SSID[key],save=false})
			print("Connecting to " .. key .. " ...")
			--config.SSID = nil  -- can save memory
				
			--tmr.alarm(1, 2500, 1, wifi_wait_ip)
			mytimer = tmr.create()
			mytimer:register(2500, tmr.ALARM_AUTO, wifi_wait_ip)
			mytimer:start()
			break
		end
    end
	if(mytimer==nil) then
		print("Cannot connect any Wifi AP.")
		wifi_connecting_flag=false
	end
end

function module.start()
	if(wifi_connecting_flag==true) then return end
	wifi_connecting_flag=true
	
	print("Configuring Wifi ...")
	wifi.setmode(wifi.STATION);
	wifi.eventmon.register(wifi.eventmon.STA_DISCONNECTED, function()
		wifi_connect_state=false
	end)
	wifi.sta.getap(wifi_start)	--list AP
end

return module


