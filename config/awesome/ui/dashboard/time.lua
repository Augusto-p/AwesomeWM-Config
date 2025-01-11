-- Standard awesome library
local awful = require("awful")

-- Theme handling library
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

-- Widget library
local wibox = require("wibox")

-- Helpers
local helpers = require("helpers")


-- Time
---------

local time_hour = wibox.widget{
    font = beautiful.font_name .. "bold 26",
    format = helpers.colorize_text("%H", "#cfcdcc"),
    align = "center",
    valign = "center",
    widget = wibox.widget.textclock
}

local time_min = wibox.widget{
    font = beautiful.font_name .. "bold 26",
    format = helpers.colorize_text("%M", "#cfcdcc"),
    align = "center",
    valign = "center",
    widget = wibox.widget.textclock
}

local time_sep = wibox.widget{
    font = beautiful.font_name .. "bold 28",
    format = helpers.colorize_text(":", "#cfcdcc"),
    align = "center",
    valign = "center",
    widget = wibox.widget.textclock
}

local time = wibox.widget{
    time_hour,
    time_sep,
    time_min,
    spacing = dpi(5),
    widget = wibox.layout.fixed.horizontal
}

return time
