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

fields[#fields + 1] = { t = "Brightness", x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 5, max = 100, vals = { 1 } }

return {
    read        = 0x3008, -- MSP2_GET_LED_STRIP_CONFIG_VALUES
    write       = 0x3009, -- MSP2_SET_LED_STRIP_CONFIG_VALUES
    title       = "LED",
    reboot      = false,
    eepromWrite = true,
    minBytes    = 5,
    labels      = labels,
    fields      = fields,
}