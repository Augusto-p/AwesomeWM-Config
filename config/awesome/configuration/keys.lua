-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
local hotkeys_popup = require("awful.hotkeys_popup")

-- Theme
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

-- Notifications
local naughty = require("naughty")

-- Bling
local bling = require("module.bling")
local playerctl = bling.signal.playerctl.lib()

-- Machi
local machi = require("module.layout-machi")

-- Helpers
local helpers = require("helpers")

--------------------------------------------------
-- MOD KEYS
--------------------------------------------------
modkey = "Mod4"
alt    = "Mod1"
ctrl   = "Control"
shift  = "Shift"

--------------------------------------------------
-- GLOBAL KEYS
--------------------------------------------------
globalkeys = awful.util.table.join(

    -- Terminal
    awful.key({ modkey }, "Return", function()
        awful.spawn(terminal)
    end),

    -- Launcher
    awful.key({ modkey }, "d", function()
        awful.spawn(launcher)
    end),

    awful.key({ modkey, shift }, "d", function()
        dashboard_toggle()
    end),

    awful.key({ modkey }, "f", function()
        awful.spawn(file_manager)
    end),

    awful.key({ modkey }, "b", function()
        awful.spawn.with_shell(browser)
    end),

    -- Focus
    awful.key({ modkey }, "Left", function()
        awful.client.focus.bydirection("left")
    end),

    awful.key({ modkey }, "Right", function()
        awful.client.focus.bydirection("right")
    end),

    awful.key({ modkey }, "Up", function()
        awful.client.focus.bydirection("up")
    end),

    awful.key({ modkey }, "Down", function()
        awful.client.focus.bydirection("down")
    end),

    -- Layout
    awful.key({ modkey }, "space", function()
        awful.layout.inc(1)
    end),

    awful.key({ modkey, shift }, "space", function()
        awful.layout.inc(-1)
    end),

    -- Volume
    awful.key({}, "XF86AudioRaiseVolume", function()
        helpers.volume_control(5)
    end),

    awful.key({}, "XF86AudioLowerVolume", function()
        helpers.volume_control(-5)
    end),

    awful.key({}, "XF86AudioMute", function()
        helpers.volume_control(0)
    end),

    -- Music
    awful.key({}, "XF86AudioPlay", function()
        playerctl:play_pause()
    end),

    awful.key({}, "XF86AudioNext", function()
        playerctl:next()
    end),

    awful.key({}, "XF86AudioPrev", function()
        playerctl:previous()
    end),

    -- Awesome
    awful.key({ modkey, ctrl }, "r", awesome.restart),
    awful.key({ modkey, ctrl }, "q", awesome.quit)
)

--------------------------------------------------
-- APPLY KEYS
--------------------------------------------------
root.keys(globalkeys)