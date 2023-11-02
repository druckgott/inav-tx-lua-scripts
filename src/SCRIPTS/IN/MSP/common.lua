-- Protocol version
local MSP_V1 = bit32.lshift(1,5)
local MSP_V2 = bit32.lshift(2,5)
local MSP_STARTFLAG = bit32.lshift(1,4)

-- Sequence number for next MSP packet
local mspSeq = 0
local mspRemoteSeq = 0
local mspRxBuf = {}
local mspRxError = false
local mspRxSize = 0
local mspRxCRC = 0
local mspRxReq = 0
local mspStarted = false
local mspLastReq = 0
local mspTxBuf = {}
local mspTxIdx = 1
local mspTxCRC = 0

function mspProcessTxQ()
    if (#(mspTxBuf) == 0) then
        return false
    end
    if not protocol.push() then
        return true
    end
    local payload = {}
    if mspLastReq <= 0xFF then
        payload[1] = mspSeq + MSP_V1
    else
        payload[1] = mspSeq + MSP_V2
    end
    mspSeq = bit32.band(mspSeq + 1, 0x0F)
    if mspTxIdx == 1 then
        -- start flag
        payload[1] = payload[1] + MSP_STARTFLAG
    end
    local i = 2
    while (i <= protocol.maxTxBufferSize) and mspTxIdx <= #mspTxBuf do
        payload[i] = mspTxBuf[mspTxIdx]
        mspTxIdx = mspTxIdx + 1
        mspTxCRC = bit32.bxor(mspTxCRC,payload[i])  
        i = i + 1
    end
    if i <= protocol.maxTxBufferSize then
        payload[i] = mspTxCRC
        protocol.mspSend(payload)
        mspTxBuf = {}
        mspTxIdx = 1
        mspTxCRC = 0
        return false
    end
    protocol.mspSend(payload)
    return true
end

function mspSendRequest(cmd, payload)
    -- busy
    if #(mspTxBuf) ~= 0 or not cmd then
        return nil
    end
    if cmd <= 0xFF then -- MSP V1
        mspTxBuf[1] = #(payload)
        mspTxBuf[2] = bit32.band(cmd,0xFF)
    else -- MSP V2
        mspTxBuf[1] = 0
        mspTxBuf[2] = bit32.band(cmd,0xFF)
        mspTxBuf[3] = bit32.rshift(cmd,8)
        mspTxBuf[4] = bit32.band(#payload,0xFF)
        mspTxBuf[5] = bit32.rshift(#payload, 8)
    end
    local mspTxBufSize = #mspTxBuf
    for i=1,#(payload) do
        mspTxBuf[i+mspTxBufSize] = bit32.band(payload[i],0xFF)
    end
    mspLastReq = cmd
    return mspProcessTxQ()
end

function mspReceivedReply(payload)
    local idx = 1
    local status = payload[idx]
    local version = bit32.rshift(bit32.band(status, 0x60), 5)
    local start = bit32.btest(status, 0x10)
    local seq = bit32.band(status, 0x0F)
    idx = idx + 1
    if start then
        mspRxBuf = {}
        mspRxError = bit32.btest(status, 0x80)
        mspRxSize = payload[idx]
        mspRxReq = mspLastReq
        idx = idx + 1
        if version == 1 then
            mspRxReq = payload[idx]
            idx = idx + 1
        end
        if version == 2 then
            idx = 3
            mspRxReq = payload[idx]
            idx = idx + 1
            mspRxReq = mspRxReq + bit32.lshift(payload[idx], 8)
            idx = idx + 1
            mspRxSize = payload[idx]
            idx = idx + 1
            mspRxSize = mspRxSize + bit32.lshift(payload[idx], 8)
            idx = idx + 1
        end
        mspRxCRC = bit32.bxor(mspRxSize, mspRxReq)
        if mspRxReq == mspLastReq then
            mspStarted = true
        end
    elseif not mspStarted then
        return nil
    elseif bit32.band(mspRemoteSeq + 1, 0x0F) ~= seq then
        mspStarted = false
        return nil
    end
    while (idx <= protocol.maxRxBufferSize) and (#mspRxBuf < mspRxSize) do
        mspRxBuf[#mspRxBuf + 1] = payload[idx]
        mspRxCRC = bit32.bxor(mspRxCRC, payload[idx])
        idx = idx + 1
    end
    if idx > protocol.maxRxBufferSize then
        mspRemoteSeq = seq
        return false
    end
    mspStarted = false
    -- check CRC
    if mspRxCRC ~= payload[idx] and version == 0 then
        return nil
    end
    return true
end

function mspPollReply()
    while true do
        local mspData = protocol.mspPoll()
        if mspData == nil then
            return nil
        elseif mspReceivedReply(mspData) then
            mspLastReq = 0
            return mspRxReq, mspRxBuf, mspRxError
        end     
    end
end
