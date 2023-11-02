local PageFiles = {}

if apiVersion >= 1.16 then
    PageFiles[#PageFiles + 1] = { title = "PIDs 1", script = "pid_test.lua" }
end

if apiVersion >= 1.16 then
    PageFiles[#PageFiles + 1] = { title = "Advanced PIDs", script = "pid_advanced.lua" }
end

if apiVersion >= 1.46 then
    PageFiles[#PageFiles + 1] = { title = "LED", script = "led.lua" }
end

return PageFiles
