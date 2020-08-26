-- init.lua
-- delay 10 seconds to run app_name, just input 'x' or 'X' to abort.

app_name="app.lua"

---------- do not change section bellow ---------------------------------------
exe_delay_seconds=10
exe_enable=true

print("UUU UU U")
print("delay "..(exe_delay_seconds).." second(s) to run '"..app_name.."' ...")
print("input 'x' to abort running "..app_name.." before timeout...")


do_app_file=0;
mytimer = tmr.create()
function TimedCheck()
	exe_delay_seconds=exe_delay_seconds-1
	uart.write(0,0x30+exe_delay_seconds)
	if(exe_enable==false) then
		uart.write(0,"\r\n'"..app_name.."' is aborted to run.\r\n>")
	else
		if(exe_delay_seconds~=0) then
			return
		else
			if(file.exists(app_name)) then
				uart.write(0,"\r\n'"..app_name.."' is readying to run ...\r\n>")
				do_app_file=1;
			else
				uart.write(0,"\r\n'"..app_name.."' not find, stoped to run.\r\n>")
			end
		end
	end
	uart.on("data","x", function(data) end, 1)
	mytimer:unregister()
	mytimer=nil
	exe_delay_seconds=nil
	exe_enable=nil
	collectgarbage()
	if do_app_file==1 then
		do_app_file=nil
		dofile(app_name)
	end
	app_name=nil
end
mytimer:register(1000, tmr.ALARM_AUTO, TimedCheck)
mytimer:start()


uart.on("data", "x", function(data)
    --print("receive from uart:", data)
    if (data=="x") or (data=="X") then
		exe_enable=false
		TimedCheck()
    end
end, 0)		-- 1-表示当前接收的字符后续继续由LuaInterpreter处理
----------- section end -------------------------------------------------------

