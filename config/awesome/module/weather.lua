-- Standard awesome library
local gears = require("gears")
local awful = require("awful")

-- Theme handling library
local beautiful = require("beautiful")

local https = require("ssl.https")
local ltn12 = require("ltn12")
local cjson = require("cjson.safe")
local WeatherManager = {}

function WeatherManager:get_key_location(city, state, country)
    local url = string.format("https://www.accuweather.com/web-api/autocomplete?query=%s, %s, %s", city, state,country):gsub(" ","%%20")
    
    local response = {}
    local res, code, headers, status = https.request{
        url = url,
            headers = {
            ["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:102.0) Gecko/20100101 Firefox/102.0",
            ["Accept"] = "*/*"
        },
        method = "GET",
        sink = ltn12.sink.table(response)
    }

    if res and code == 200 then
        local body = table.concat(response)
        local data = cjson.decode(body)

        if data and type(data) == "table" and #data > 0 then
            local first = data[1]

            return first.key
        end
    end  
    return nil 
end



function WeatherManager:get_URL_location(city, state, country, lang, unit)
    local key = WeatherManager:get_key_location(city, state, country)
    local mode = (unit ~= "metric") and "f" or "c"
    local url = string.format("https://www.accuweather.com/web-api/three-day-redirect?key=%s&lang=%s&unit=%s", key, lang, mode)
    local response = {}
    local res, code, headers, status = https.request{
        url = url,
        headers = {
            ["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:102.0) Gecko/20100101 Firefox/102.0",
            ["Accept"] = "*/*"
        },
        method = "GET",
        sink = ltn12.sink.table(response)
    }

    -- si la respuesta es redirección
    if (code == 301 or code == 302) and headers and headers.location then
        return string.format("https://www.accuweather.com%s", headers.location)

    end
    if code == 200 then
        return url
    end
    return nil
end

function WeatherManager:get_weather_location(city, state, country, lang, unit)
    local url = WeatherManager:get_URL_location(city, state, country, lang, unit)
    local response = {}
    
    local res, code, headers, status = https.request{
        url = url,
        headers = {
            ["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:102.0) Gecko/20100101 Firefox/102.0",
            ["Accept"] = "*/*"
        },
        method = "GET",
        sink = ltn12.sink.table(response)
    }
    if not res or code ~= 200 then
        return nil
    end
    
    local html = table.concat(response)
    local data_src = html:match('<svg[^>]-class=["\']weather%-icon["\'][^>]-data%-src=["\'](.-)["\']'):gsub(".svg", ""):gsub("/images/weathericons/","")
    local phrase = html:match('<span[^>]-class="[^"]*phrase[^"]*"[^>]*>(.-)</span>')
    local temp = html:match('<div[^>]-class=["\']temp["\'][^>]*>(.-)</div>'):gsub("-", ""):gsub("&#xB0;<span class=\"aftertemp\">", "°"):gsub("</span>", "")

    return {
        icon = tonumber(data_src),
        phrase = phrase,
        temperature = temp
    }

end


function WeatherManager:getWeatherIcon(code)
    local icons = {
        [1]  = beautiful.ic_weather_clear_day,
        [2]  = beautiful.ic_weather_partly_cloudy_day,
        [3]  = beautiful.ic_weather_partly_cloudy_day,
        [4]  = beautiful.ic_weather_partly_cloudy_day,
        [5]  = beautiful.ic_weather_haze_day,
        [6]  = beautiful.ic_weather_overcast_day,
        [7]  = beautiful.ic_weather_cloudy,
        [8]  = beautiful.ic_weather_overcast,
        [11] = beautiful.ic_weather_fog,
        [12] = beautiful.ic_weather_drizzle,
        [13] = beautiful.ic_weather_partly_cloudy_day_rain,
        [14] = beautiful.ic_weather_partly_cloudy_day_drizzle,
        [15] = beautiful.ic_weather_thunderstorms,
        [16] = beautiful.ic_weather_thunderstorms_day,
        [17] = beautiful.ic_weather_thunderstorms_day,
        [18] = beautiful.ic_weather_rain,
        [19] = beautiful.ic_weather_snow,
        [20] = beautiful.ic_weather_partly_cloudy_day_snow,
        [21] = beautiful.ic_weather_partly_cloudy_day_snow,
        [22] = beautiful.ic_weather_snow,
        [23] = beautiful.ic_weather_overcast_day_snow,
        [24] = beautiful.ic_weather_sleet,
        [25] = beautiful.ic_weather_sleet,
        [26] = beautiful.ic_weather_rain_snow,
        [29] = beautiful.ic_weather_rain_snow,
        [30] = beautiful.ic_weather_hot,
        [31] = beautiful.ic_weather_severe_cold,
        [32] = beautiful.ic_weather_wind,
        [33] = beautiful.ic_weather_clear_night,
        [34] = beautiful.ic_weather_partly_cloudy_night,
        [35] = beautiful.ic_weather_partly_cloudy_night,
        [36] = beautiful.ic_weather_partly_cloudy_night,
        [37] = beautiful.ic_weather_haze_night,
        [38] = beautiful.ic_weather_overcast_night,
        [39] = beautiful.ic_weather_partly_cloudy_night_rain,
        [40] = beautiful.ic_weather_overcast_night_rain,
        [41] = beautiful.ic_weather_partly_cloudy_night_thunderstorms,
        [42] = beautiful.ic_weather_thunderstorms_night,
        [43] = beautiful.ic_weather_partly_cloudy_night_snow,
        [44] = beautiful.ic_weather_overcast_night_snow
    }

    return icons[code] or beautiful.ic_weather_cloudy
end


return WeatherManager
-- local weather  = get_weather_location("mountain view", "califorina", "usa")
-- print(weather.icon)
-- print(weather.temp)
