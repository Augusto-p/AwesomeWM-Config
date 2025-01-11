--[[
 _____ __ _ __ _____ _____ _____ _______ _____
|     |  | |  |  ___|  ___|     |       |  ___|
|  -  |  | |  |  ___|___  |  |  |  | |  |  ___|
|__|__|_______|_____|_____|_____|__|_|__|_____|
               ~ AestheticArch ~
                     Null
--]]
pcall(require, "luarocks.loader")

-- Standard awesome library
local gfs = require("gears.filesystem")
local awful = require("awful")

-- Theme handling library
local beautiful = require("beautiful")
dpi = beautiful.xresources.apply_dpi
beautiful.init(gfs.get_configuration_dir() .. "theme/theme.lua")

-- Default Applications
terminal = "kitty"
editor = "code"
vscode = "code"
browser = "firefox"
launcher = "rofi -show drun -show-icons -b "
file_manager = "nautilus"
music_client = terminal .. " --class music -e ncmpcpp"

-- Weather API
weather_city = "Capurro"
weather_state = "San José"
weather_country = "Uruguay"

openweathermap_key = "" -- API Key
openweathermap_city_id = "" -- City ID
weather_units = "metric" -- Unit

-- Global Vars
screen_width = awful.screen.focused().geometry.width
screen_height = awful.screen.focused().geometry.height

-- Autostart
awful.spawn.with_shell(gfs.get_configuration_dir() .. "configuration/autostart")

-- Import Configuration
require("configuration")

-- Import Daemons and Widgets
require("signal")
require("ui")

-- Garbage Collector Settings
collectgarbage("setpause", 110)
collectgarbage("setstepmul", 1000)

-- Wallpaper
-- local wallpaper_cmd="feh --bg-fill /home/augusto/Pictures/Firewatch+Tower.jpg"
local wallpaper_cmd = string.format("feh --bg-fill %s", beautiful.wallpaper)
os.execute(wallpaper_cmd)
