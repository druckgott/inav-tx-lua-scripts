local template = assert(loadScript(radio.template))()
local margin = template.margin
local indent = template.indent
local lineSpacing = template.lineSpacing
local tableSpacing = template.tableSpacing
local sp = template.listSpacing.field
local yMinLim = radio.yMinLimit
local x = margin
local y = yMinLim - lineSpacing
local inc = { x = function(val) x = x + val return x end, y = function(val) y = y + val return y end }
local labels = {}
local fields = {}

fields[#fields + 1] = { t = "A", x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = -999999, max = 999999, vals = { 1 } }
fields[#fields + 1] = { t = "B", x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = -999999, max = 999999, vals = { 2 } }
fields[#fields + 1] = { t = "C", x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = -999999, max = 999999, vals = { 3 } }
fields[#fields + 1] = { t = "D", x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = -999999, max = 999999, vals = { 4 } }

return {
    read        = 0x2030, -- MSP2_PID
    write       = 0x2031, -- MSP2_SET_PID
    title       = "TEST",
    reboot      = false,
    eepromWrite = false,
    minBytes    = 5,
    labels      = labels,
    fields      = fields,
}