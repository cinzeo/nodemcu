--mqttclient.lua

local mqtt_conn=nil
local mqtt_tx_topic=config.ENDPOINT.."/tx"
local mqtt_txMsg={}	--发送的信息列表
local mqtt_rx_topic=config.ENDPOINT.."/rx"
local mqtt_rxMsg={}	--收到的信息列表
local mqtt_connecting_flag=false
local module= {}
module.mqtt_connect_state=false


local function consume_data(conn, payload)
	--do someting with the payload and send responce
	mqtt_rxMsg[#mqtt_rxMsg+1]=payload
end

-- Module function: to get msg from msglist
function module.getMsg()
	local Msg=nil;
	if(#mqtt_rxMsg>0) then
		Msg=mqtt_rxMsg[1];
		table.remove(mqtt_rxMsg,1)
	end
	return Msg;
end

-- Sends a simple ping to the broker
local function send_ping(conn)
	-- mqtt:publish(topic, payload, qos, retain[, function(conn)])
	if(#mqtt_txMsg>0) then
		conn:publish(mqtt_tx_topic, mqtt_txMsg[1], 0,0, function(conn)
			print("Send: "..mqtt_tx_topic.." - "..mqtt_txMsg[1])
			table.remove(mqtt_txMsg,1)
			send_ping(conn)
		end)
	end
end

-- Module function: sends a msg to the broker
function module.sendMsg(Msg)
	mqtt_txMsg[#mqtt_txMsg+1]=Msg
	if(#mqtt_txMsg==1) then
		send_ping(mqtt_conn)
	end
end

-- start mqtt moduale
local function mqtt_start()
	print("MQTT client start...")
    m = mqtt.Client(config.ID, 120, config.USERNAME, config.PASSWORD)
	
	-- setup Last Will and Testament (optional)
	m:lwt(mqtt_tx_topic, "LWT: offline", 0, 0)
	
    -- register message callback before to hand
	m:on("offline", function(conn)
		print ("MQTT Broker is offline.")
		m:close()	-- close connection to broker
		mqtt_connecting_flag=false
		module.mqtt_connect_state=false
	end)
    m:on("message", function(conn, topic, data)
		if data ~= nil then
			print("Recv: "..topic.." - "..data)
			consume_data(conn, data)
		end
    end)
	
	-- do connecting to broker
    m:connect(config.HOST, config.PORT, function(conn)    -- Connect to broker
		print("Connected broker and register myself!")
		conn:subscribe(mqtt_rx_topic,0,function(conn)
			print("Successfully subscribed mqtt rx-topic.")
		end)
		mqtt_conn=conn
		mqtt_connecting_flag=false
		module.mqtt_connect_state=true
    end,
	function(conn, reason)
		print("failed reason: " .. reason)
		m:close();
		-- you can call m:connect again
		mqtt_conn=nil
		mqtt_connecting_flag=false
		module.mqtt_connect_state=false
	end)
end

-- ready to start mqtt module
function module.start()
	if(mqtt_connecting_flag==true) then return end
	mqtt_connecting_flag=true
	mqtt_start()
end

return module


