-- Standard awesome library
local gears = require("gears")
local awful = require("awful")

-- Theme handling library
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

-- Widget library
local wibox = require("wibox")


-- Helpers
local helpers = require("helpers")


-- Weather
------------
local weatherApi = require("module.weather")


local weather_text = wibox.widget{
    font = beautiful.font_name .. "medium 8",
    markup = helpers.colorize_text("Weather unavailable", beautiful.dashboard_box_fg),
    valign = "center",
    widget = wibox.widget.textbox
}

local weather_temp = wibox.widget{
    font = beautiful.font_name .. "medium 11",
    markup = "999°c",
    valign = "center",
    widget = wibox.widget.textbox
}


local weather_icon = wibox.widget {
        {
            widget = wibox.widget.imagebox,
            image = beautiful.ic_weather_clear_day,
            resize = true,
            id = "icon"
        },
        margins = dpi(0),
        widget = wibox.container.margin
    }

local weather = wibox.widget{
        {
            weather_text,
            weather_temp,
            spacing = dpi(3),
            layout = wibox.layout.fixed.vertical
        },
        nil,
        weather_icon,
        expand = "none",
        layout = wibox.layout.align.vertical
}

awesome.connect_signal("signal::weather", function()
    local weather = weatherApi:get_weather_location(weather_city, weather_state, weather_country, weather_lang, weather_units)
    weather_icon.icon.image = weatherApi:getWeatherIcon(weather.icon)
    weather_text.markup = helpers.colorize_text(weather.phrase, beautiful.dashboard_box_fg)
    weather_temp.markup = weather.temperature
end)

return weather
