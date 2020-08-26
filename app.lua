--app.lua

config = require("config")  
local wifiSetup  = require("wifisetup")
local mqttClient = require("mqttclient")
local gpioState  = "XXXX"

local tSensor    = require("ds18b20")

local function processRecvMsg()
	local Msg=mqttClient.getMsg();
	if(Msg==nil) then return end;
	
	local start,tail
	start,tail=string.find(Msg,"set gpio4=1")
	if(start~=nil) then
		gpio.write(4,gpio.HIGH)
		--mqttClient.sendMsg("Reply: set ok")
		gpioState=""
	else
		start,tail =string.find(Msg,"set gpio4=0")
		if(start~=nil) then
			gpio.write(4,gpio.LOW)
			--mqttClient.sendMsg("Reply: set ok")
			gpioState=""
		end
	end
	
    start,tail=string.find(Msg,"get gpio_state")
	if(start~=nil) then
		mqttClient.sendMsg("Reply: GPIO[1:4]="..gpioState)
	end
end

local function processDetect()
	local state=gpio.read(1)..gpio.read(2)..gpio.read(3)..gpio.read(4)
	if(gpioState~=state) then
		--print("Device's GPIO[1:4]="..gpioState);
		if(mqttClient.mqtt_connect_state==true) then
			mqttClient.sendMsg("Event: GPIO[1:4]="..state)
			gpioState=state;
		end
	end
end
	
function mainProcess()
	--Callback every timed, here is 2000ms
	if(wifiSetup.wifi_connect_state==false) then
		wifiSetup.start()
	else
		if(mqttClient.mqtt_connect_state==false) then
			mqttClient.start()
			gpioState="";	--清除gpio状态，以触发在mqqt联接成功后立刻发送一条消息出去
		else
			processRecvMsg()
			processDetect()
		end
	end
	
	--print("Uptime (probably):", tmr.time())

	--Stop timed callback
    --mainTimer:unregister()
	--mainTimer=nil
end

gpio.mode(4,gpio.OUTPUT)
mainTimer = tmr.create()
mainTimer:register(2000, tmr.ALARM_AUTO, mainProcess)
mainTimer:start()


