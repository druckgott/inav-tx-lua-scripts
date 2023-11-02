local apiVersionReceived = false
local mcuIdReceived = false
local boardInfoReceived = false
local getApiVersion, getMCUId
local returnTable = { f = nil, t = "" }

local function init()
    if getRSSI() == 0 then
        returnTable.t = "Waiting for connection"
    elseif not apiVersionReceived then
        getApiVersion = getApiVersion or assert(loadScript("api_version.lua"))()
        returnTable.t = getApiVersion.t
        apiVersionReceived = getApiVersion.f()
        if apiVersionReceived then
            getApiVersion = nil
            collectgarbage()
        end
    elseif not mcuIdReceived and apiVersion >= 1.42 then
        getMCUId = getMCUId or assert(loadScript("mcu_id.lua"))()
        returnTable.t = getMCUId.t
        mcuIdReceived = getMCUId.f()
        if mcuIdReceived then
            getMCUId = nil
            collectgarbage()
            f = loadScript("BOARD_INFO/"..mcuId..".lua")
            if f and f() then
                boardInfoReceived = true
                f = nil
            end
            collectgarbage()
        end
        return true
    end
    return apiVersionReceived and mcuId
end

returnTable.f = init

return returnTable
