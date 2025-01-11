local beautiful = require('beautiful')

local tools = {}

function tools.get_wifi_image(x)
    if x < 10 then
        return beautiful.icon_Wifi_0
    elseif x < 30 then
        return beautiful.icon_Wifi_1
    elseif x < 50 then
        return beautiful.icon_Wifi_2
    elseif x < 75 then
        return beautiful.icon_Wifi_3
    else
        return beautiful.icon_Wifi_4
    end
end



return tools

