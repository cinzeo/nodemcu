-- config.lua

local module = {}

module.SSID = {}
module.SSID["Feixun_19216811"] = "0lxz2hzp3lsy4lsm"
module.SSID["TP-LINK-xtjc"]    = "xzjtxtjc"
module.HOST = "218.77.106.31" --"192.168.111.181"
module.PORT = 8888            --1883
module.USERNAME = "mqttusername"
module.PASSWORD = "mqttpassword"

module.ID = "esp8266-chipid"..node.chipid()
module.ENDPOINT = "/nodemcu/chipid"..node.chipid()

return module
