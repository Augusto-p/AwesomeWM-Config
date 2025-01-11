local connect_Comand = 'nmcli dev wifi connect "ºSSIDº" password "ºPASSWORDº" > /dev/null 2>&1 && echo "0" || (nmcli dev wifi connect "ºSSIDº" password "ºPASSWORDº" 2>&1 | grep -q "Incorrect password" && echo "1" || echo "2")'
local getData_Comand = "nmcli dev wifi list"
local desconnect_Comand = 'nmcli connection delete "$(nmcli -t -f TYPE,NAME connection show | grep "wireless:" | cut -d ":" -f 2 )"'
local getWifiSignal_command = "nmcli -t -f ACTIVE,SSID,SIGNAL dev wifi | grep '^yes:' | awk -F: '{print $3}'"
local getConnectionType_comand = 'active_connection=$(nmcli -t -f TYPE,STATE connection show --active | grep "ethernet:activated") && echo "1" || (active_connection=$(nmcli -t -f TYPE,STATE connection show --active | grep "wireless:activated") && echo "2" || (active_connection=$(nmcli -t -f WIFI g | grep "enabled") && echo "3" || echo "0"))'
local ShareWifi_command = "nmcli dev wifi show-password"

local beautiful = require('beautiful')

function split(input, delimiter)
    local result = {}
    for part in string.gmatch(input, "([^" .. delimiter .. "]+)") do
        table.insert(result, part)
    end
    return result
end

function replace_spaces( input )
    return input:gsub("%s%s%s+", "  ")
end

function LoadCredentials(SSID, Password)
    local SID = string.gsub(connect_Comand, "ºSSIDº", SSID)
    return string.gsub(SID, "ºPASSWORDº", Password)
end

function replace_spaces_for_tab( input )
    return input:gsub("  ", "\t")
end
local Network = {}

function Network.getData()
    local Netwoks = {}
    local handle = io.popen(getData_Comand)
    local NetData = handle:read("*a")
    handle:close()
    local NetRows = split(NetData, "\n")
    table.remove(NetRows, 1) -- Remove Headers
    for _, row in ipairs(NetRows) do
        local Net = {}
        local rowClear = replace_spaces_for_tab(replace_spaces(row))
        local Cols = split(rowClear, "\t")
        if Cols[1] ~= "*" then -- IN-USE 
            table.insert( Net, 0)
            table.insert(Cols, 1, "+")
        else
            table.insert( Net, 1)
        end
        table.insert( Net, Cols[3]) -- SSID
        table.insert( Net, tonumber(Cols[7])) -- SIGNAL
        if Cols[9] ~= "--" then -- SECURITY
            table.insert( Net, 1)
        else
            table.insert( Net, 0)
        end
        table.insert(Netwoks, Net)
    end

    table.sort(Netwoks, function(a,b)
        if a[1] ~= b[1]  then
            return a[1] > b[1]
        else
            return a[3] > b[3]
        end
        
    end)

    return Netwoks
end

function Network.desconnect()
    local handle = io.popen(desconnect_Comand)
    local Responce = handle:read("*a")
    handle:close()
    
end

function Network.getConnectionType()
    local handle = io.popen(getConnectionType_comand)
    local Responce = handle:read("*a")
    handle:close()
    return tonumber(Responce)
end


function Network.connect(SSID, password)
    if Network.getConnectionType() == 2 then
        Network.desconnect()
    end
    local handle = io.popen(LoadCredentials(SSID, password), "r")
    local Responce = handle:read("*a")
    handle:close()
    return tonumber(Responce)
end

function Network.getWifiSignal()
    local handle = io.popen(getWifiSignal_command)
    local Responce = handle:read("*a")
    handle:close()
    return tonumber(Responce)
end

function Network.ShareWifi()
    if Network.getConnectionType() ~= 2 then
        return false
    end
    local handle = io.popen(ShareWifi_command)
    local Responce = handle:read("*a")
    handle:close()
    local Datos = split(Responce, "\n")
    local SSID = string.gsub(Datos[1], "SSID: ", "")
    local Security = string.gsub(Datos[2], "Security: ", "")
    local Password = string.gsub(Datos[3], "Password: ", "")
    local wifi_String = string.format( "qrencode -o %s 'WIFI:S:%s;T:%s;P:%s;;' --size 20 -m 2", beautiful.path_QR, SSID, Security, Password )
    local handle = io.popen(wifi_String)
    local Responce = handle:read("*a")
    handle:close()
    if Responce ~= "" then
        return false
    end
    return true
    -- body
end


return Network

