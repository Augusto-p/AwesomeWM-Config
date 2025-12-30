-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.keyboard")
local hotkeys_popup = require("awful.hotkeys_popup")

-- Theme handling library
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

-- Notifications library
local naughty = require("naughty")

-- Bling
local bling = require("module.bling")
local playerctl = bling.signal.playerctl.lib()

-- Machi
local machi = require("module.layout-machi")

-- Helpers
local helpers = require("helpers")

-- Default modkeys
modkey = "Mod4"
alt    = "Mod1"
ctrl   = "Control"
shift  = "Shift"

--------------------------------------------------
-- LAUNCHER
--------------------------------------------------
awful.keyboard.append_global_keybindings({
    awful.key({ modkey }, "Return", function()
        awful.spawn(terminal)
    end, { description = "open terminal", group = "launcher" }),

    awful.key({ modkey }, "d", function()
        awful.spawn(launcher)
    end, { description = "open applications menu", group = "launcher" }),

    awful.key({ modkey, shift }, "d", function()
        dashboard_toggle()
    end, { description = "toggle dashboard", group = "launcher" }),

    awful.key({ modkey }, "f", function()
        awful.spawn(file_manager)
    end, { description = "open file manager", group = "launcher" }),

    awful.key({ modkey }, "b", function()
        awful.spawn.with_shell(browser)
    end, { description = "open web browser", group = "launcher" }),

    awful.key({ modkey }, "x", function()
        awful.spawn.with_shell("xcolor-pick")
    end, { description = "open color-picker", group = "launcher" })
})

--------------------------------------------------
-- CLIENT / TABS
--------------------------------------------------
awful.keyboard.append_global_keybindings({
    awful.key({ alt }, "a", function()
        bling.module.tabbed.pick_with_dmenu()
    end, { description = "pick client to add to tab group", group = "tabs" }),

    awful.key({ alt }, "s", function()
        bling.module.tabbed.iter()
    end, { description = "iterate through tab group", group = "tabs" }),

    awful.key({ alt }, "d", function()
        bling.module.tabbed.pop()
    end, { description = "remove client from tab group", group = "tabs" }),

    awful.key({ modkey }, "Down", function()
        awful.client.focus.bydirection("down")
        bling.module.flash_focus.flashfocus(client.focus)
    end, { description = "focus down", group = "client" }),

    awful.key({ modkey }, "Up", function()
        awful.client.focus.bydirection("up")
        bling.module.flash_focus.flashfocus(client.focus)
    end, { description = "focus up", group = "client" }),

    awful.key({ modkey }, "Left", function()
        awful.client.focus.bydirection("left")
        bling.module.flash_focus.flashfocus(client.focus)
    end, { description = "focus left", group = "client" }),

    awful.key({ modkey }, "Right", function()
        awful.client.focus.bydirection("right")
        bling.module.flash_focus.flashfocus(client.focus)
    end, { description = "focus right", group = "client" }),

    awful.key({ modkey }, "j",
        function() awful.client.focus.byidx(1) end,
        { description = "focus next by index", group = "client" }),

    awful.key({ modkey }, "k",
        function() awful.client.focus.byidx(-1) end,
        { description = "focus previous by index", group = "client" }),

    awful.key({ modkey, shift }, "j",
        function() awful.client.swap.byidx(1) end,
        { description = "swap with next client", group = "client" }),

    awful.key({ modkey, shift }, "k",
        function() awful.client.swap.byidx(-1) end,
        { description = "swap with previous client", group = "client" }),

    awful.key({ alt }, "Tab", function()
        awesome.emit_signal("bling::window_switcher::turn_on")
    end, { description = "window switcher", group = "client" })
})

--------------------------------------------------
-- HOTKEYS
--------------------------------------------------
awful.keyboard.append_global_keybindings({
    awful.key({}, "XF86MonBrightnessUp",
        function() awful.spawn("brightnessctl set 5%+ -q") end,
        { description = "increase brightness", group = "hotkeys" }),

    awful.key({}, "XF86MonBrightnessDown",
        function() awful.spawn("brightnessctl set 5%- -q") end,
        { description = "decrease brightness", group = "hotkeys" }),

    awful.key({}, "XF86AudioRaiseVolume",
        function() helpers.volume_control(5) end,
        { description = "increase volume", group = "hotkeys" }),

    awful.key({}, "XF86AudioLowerVolume",
        function() helpers.volume_control(-5) end,
        { description = "decrease volume", group = "hotkeys" }),

    awful.key({}, "XF86AudioMute",
        function() helpers.volume_control(0) end,
        { description = "mute volume", group = "hotkeys" }),

    awful.key({}, "XF86AudioPlay",
        function() playerctl:play_pause() end,
        { description = "toggle music", group = "hotkeys" }),

    awful.key({}, "XF86AudioPrev",
        function() playerctl:previous() end,
        { description = "previous music", group = "hotkeys" }),

    awful.key({}, "XF86AudioNext",
        function() playerctl:next() end,
        { description = "next music", group = "hotkeys" }),

    awful.key({}, "Print",
        function() awful.spawn.with_shell("screensht full") end,
        { description = "screenshot full", group = "hotkeys" }),

    awful.key({ alt }, "Print",
        function() awful.spawn.with_shell("screensht area") end,
        { description = "screenshot area", group = "hotkeys" }),

    awful.key({ modkey, ctrl }, "l",
        function() lock_screen_show() end,
        { description = "lock screen", group = "hotkeys" })
})

--------------------------------------------------
-- AWESOME
--------------------------------------------------
awful.keyboard.append_global_keybindings({
    awful.key({ modkey }, "F1",
        hotkeys_popup.show_help,
        { description = "show help", group = "awesome" }),

    awful.key({ modkey, ctrl }, "r",
        awesome.restart,
        { description = "reload awesome", group = "awesome" }),

    awful.key({ modkey, ctrl }, "q",
        awesome.quit,
        { description = "quit awesome", group = "awesome" })
})

--------------------------------------------------
-- MACHÍ
--------------------------------------------------
awful.keyboard.append_global_keybindings({
    awful.key({ modkey }, ".", function()
        machi.default_editor.start_interactive()
    end, { description = "edit machi layout", group = "layout" }),

    awful.key({ modkey }, "/", function()
        machi.switcher.start(client.focus)
    end, { description = "switch machi layout", group = "layout" })
})

--------------------------------------------------
-- NUM ROW TAGS
--------------------------------------------------
awful.keyboard.append_global_keybindings({
    awful.key {
        modifiers = { modkey },
        keygroup = "numrow",
        on_press = function(index)
            local tag = awful.screen.focused().tags[index]
            if tag then tag:view_only() end
        end
    },
    awful.key {
        modifiers = { modkey, shift },
        keygroup = "numrow",
        on_press = function(index)
            if client.focus then
                local tag = client.focus.screen.tags[index]
                if tag then client.focus:move_to_tag(tag) end
            end
        end
    }
})

--------------------------------------------------
-- MOUSE (DESKTOP)
--------------------------------------------------
awful.mouse.append_global_mousebindings({
    awful.button({}, 1, function()
        naughty.destroy_all_notifications()
        if mymainmenu then mymainmenu:hide() end
    end),

    awful.button({}, 2, function()
        dashboard_toggle()
    end),

    awful.button({}, 3, function()
        mymainmenu:toggle()
    end),

    awful.button({}, 4, awful.tag.viewprev),
    awful.button({}, 5, awful.tag.viewnext)
})

--------------------------------------------------
-- MOUSE (CLIENT)
--------------------------------------------------
client.connect_signal("request::default_mousebindings", function()
    awful.mouse.append_client_mousebindings({
        awful.button({}, 1, function(c)
            c:activate { context = "mouse_click" }
        end),
        awful.button({ modkey }, 1, function(c)
            c:activate { context = "mouse_click", action = "mouse_move" }
        end),
        awful.button({ modkey }, 3, function(c)
            c:activate { context = "mouse_click", action = "mouse_resize" }
        end)
    })
end)