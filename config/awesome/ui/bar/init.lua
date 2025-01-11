-- Standard awesome library
local awful = require("awful")
local gears = require("gears")

-- Widget library
local wibox = require("wibox")

-- Theme handling library
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

local naughty = require("naughty")
-- Rubato
local rubato = require("module.rubato")

-- Helpers
local helpers = require("helpers")

-- Get screen geometry
local screen_width = awful.screen.focused().geometry.width
local screen_height = awful.screen.focused().geometry.height

local Browser_App = "firefox"

-- Network
local network = require("ui.wifi-center.Network.init")
local network_tools = require("ui.wifi-center.Network.tools")

local wrap_widget = function(widget)
    return {
        widget,
        margins = dpi(6),
        widget = wibox.container.margin
    }
end

-- Wibar
-----------

screen.connect_signal("request::desktop_decoration", function(s)

    -- Launcher
    -------------

    local awesome_icon = wibox.widget {
        {
            widget = wibox.widget.imagebox,
            image = beautiful.Tux,
            resize = true
        },
        margins = dpi(0),
        widget = wibox.container.margin
    }

    helpers.add_hover_cursor(awesome_icon, "hand2")
    -- APPS
    --------

    -- Browser
    local app_browser_buton = wibox.widget {
        {
            {
                {
                    widget = wibox.widget.imagebox,
                    image = beautiful.icon_rubber_duck,
                    resize = true
                },
                margins = 7,
                widget = wibox.container.margin
            },
            id = "backgroundBox",
            widget = wibox.container.background,
            bg = beautiful.xcolor0,
            border_color = beautiful.xcolor0,
            fg = beautiful.xforeground,
            shape = gears.shape.rounded
        },
        margins = -2,
        widget = wibox.container.margin
    }

    -- code
    local app_code_buton = wibox.widget {
        {
            {
                {
                    widget = wibox.widget.imagebox,
                    image = beautiful.icon_Visual_Studio_Code,
                    resize = true
                },
                margins = 9,
                widget = wibox.container.margin
            },
            id = "backgroundBox",
            widget = wibox.container.background,
            bg = beautiful.xcolor0,
            border_color = beautiful.xcolor0,
            fg = beautiful.xforeground,
            shape = gears.shape.rounded
        },
        margins = -2,
        widget = wibox.container.margin
    }

    -- FileManager
    local app_FileManager_buton = wibox.widget {
        {
            {
                {
                    widget = wibox.widget.imagebox,
                    image = beautiful.icon_File_Explorer,
                    resize = true
                },
                margins = 7,
                widget = wibox.container.margin
            },
            id = "backgroundBox",
            widget = wibox.container.background,
            bg = beautiful.xcolor0,
            border_color = beautiful.xcolor0,
            fg = beautiful.xforeground,
            shape = gears.shape.rounded
        },
        margins = -2,
        widget = wibox.container.margin
    }

    -- office
    local app_Office_buton = wibox.widget {
        {
            {
                {
                    widget = wibox.widget.imagebox,
                    image = beautiful.icon_Owl,
                    resize = true
                },
                margins = 7,
                widget = wibox.container.margin
            },
            id = "backgroundBox",
            widget = wibox.container.background,
            bg = beautiful.xcolor0,
            border_color = beautiful.xcolor0,
            fg = beautiful.xforeground,
            shape = gears.shape.rounded
        },
        margins = -2,
        widget = wibox.container.margin
    }

    helpers.add_hover_cursor_button(app_browser_buton)
    helpers.add_hover_cursor_button(app_code_buton)
    helpers.add_hover_cursor_button(app_FileManager_buton)
    helpers.add_hover_cursor_button(app_Office_buton)
    -- helpers.add_hover_cursor(app_FileManager_buton, "hand2")
    -- Battery
    -------------

    local charge_icon = wibox.widget {
        bg = beautiful.xcolor8,
        widget = wibox.container.background,
        visible = false
    }

    local batt = wibox.widget {
        charge_icon,
        color = {beautiful.xcolor2},
        bg = beautiful.xcolor8 .. "88",
        value = 50,
        min_value = 0,
        max_value = 100,
        thickness = dpi(4),
        padding = dpi(2),
        -- rounded_edge = true,
        start_angle = math.pi * 3 / 2,
        widget = wibox.container.arcchart
    }

    awesome.connect_signal("signal::battery", function(value)
        local fill_color = beautiful.xcolor2

        if value >= 11 and value <= 30 then
            fill_color = beautiful.xcolor3
        elseif value <= 10 then
            fill_color = beautiful.xcolor1
        end

        batt.colors = {fill_color}
        batt.value = value
    end)

    awesome.connect_signal("signal::charger", function(state)
        if state then
            charge_icon.visible = true
        else
            charge_icon.visible = false
        end
    end)

    -- Time
    ----------

    local hour = wibox.widget {
        font = beautiful.font_name .. "bold 14",
        format = "%H",
        align = "center",
        valign = "center",
        widget = wibox.widget.textclock
    }

    local min = wibox.widget {
        font = beautiful.font_name .. "bold 14",
        format = "%M",
        align = "center",
        valign = "center",
        widget = wibox.widget.textclock
    }

    local clock = wibox.widget {
        {
            {
                hour,
                min,
                spacing = dpi(5),
                layout = wibox.layout.fixed.vertical
            },
            top = dpi(5),
            bottom = dpi(5),
            widget = wibox.container.margin
        },
        bg = beautiful.lighter_bg,
        shape = helpers.rrect(beautiful.bar_radius),
        widget = wibox.container.background
    }

    -- Stats
    -----------

    local stats = wibox.widget {
        {
            wrap_widget(batt),
            clock,
            spacing = dpi(5),
            layout = wibox.layout.fixed.vertical
        },
        bg = beautiful.xcolor0,
        shape = helpers.rrect(beautiful.bar_radius),
        widget = wibox.container.background
    }

    stats:connect_signal("mouse::enter", function()
        stats.bg = beautiful.bateryacent
        stats_tooltip_show()
    end)

    stats:connect_signal("mouse::leave", function()
        stats.bg = beautiful.xcolor0
        stats_tooltip_hide()
    end)

    -- Notification center
    -------------------------

    notif_center = wibox({
        type = "dock",
        screen = screen.primary,
        height = screen_height - dpi(50),
        width = dpi(300),
        shape = helpers.rrect(beautiful.notif_center_radius),
        ontop = true,
        visible = false
    })
    notif_center.y = dpi(25)

    -- Rubato
    local slide = rubato.timed {
        pos = dpi(-300),
        rate = 60,
        intro = 0.3,
        duration = 0.8,
        easing = rubato.quadratic,
        awestore_compat = true,
        subscribed = function(pos)
            notif_center.x = pos
        end
    }

    local notif_center_status = false

    slide.ended:subscribe(function()
        if notif_center_status then
            notif_center.visible = false
        end
    end)

    -- Make toogle button
    local notif_center_show = function()
        notif_center.visible = true
        slide:set(dpi(100))
        notif_center_status = false
    end

    local notif_center_hide = function()
        slide:set(dpi(-375))
        notif_center_status = true
    end

    local notif_center_toggle = function()
        if notif_center.visible then
            notif_center_hide()
        else
            notif_center_show()
        end
    end

    -- notif_center setup
    s.notif_center = require('ui.notifs.notif-center')(s)

    notif_center:setup{
        s.notif_center,
        margins = dpi(15),
        widget = wibox.container.margin
    }

    local notif_center_button = wibox.widget {
        markup = helpers.colorize_text("", beautiful.xcolor4),
        font = beautiful.font_name .. "18",
        align = "center",
        valign = "center",
        widget = wibox.widget.textbox
    }

    notif_center_button:connect_signal("mouse::enter", function()
        notif_center_button.markup = helpers.colorize_text(notif_center_button.text, beautiful.xcolor4 .. 55)
    end)

    notif_center_button:connect_signal("mouse::leave", function()
        notif_center_button.markup = helpers.colorize_text(notif_center_button.text, beautiful.xcolor4)
    end)

    notif_center_button:buttons(gears.table.join(awful.button({}, 1, function()
        notif_center_toggle()
    end)))
    helpers.add_hover_cursor(notif_center_button, "hand2")

    -- wifi manager
    ---------------
    local Wifi_Type_Conection = -1

    wifi_center = wibox({
        type = "dock",
        screen = screen.primary,
        height = screen_height - dpi(50),
        width = dpi(300),
        shape = helpers.rrect(beautiful.notif_center_radius),
        ontop = true,
        visible = false
    })
    wifi_center.y = dpi(25)

    -- Rubato
    local wifi_slide = rubato.timed {
        pos = dpi(-300),
        rate = 60,
        intro = 0.3,
        duration = 0.8,
        easing = rubato.quadratic,
        awestore_compat = true,
        subscribed = function(pos)
            wifi_center.x = pos
        end
    }

    local wifi_center_status = false

    -- Make toogle button
    local wifi_center_show = function()
        wifi_center.visible = true
        wifi_slide:set(dpi(100))
        wifi_center_status = true
    end

    local wifi_center_hide = function()
        wifi_slide:set(dpi(-375))
        wifi_center_status = false
    end

    local wifi_center_toggle = function()
        if wifi_center_status then
            wifi_center_hide()
        else
            
            wifi_center_show()
        end
    end

    -- wifi_center setup
    s.wifi_center = require('ui.wifi-center')(s)

    wifi_center:setup{

        layout = wibox.layout.align.vertical,
        {
            s.wifi_center,
            margins = dpi(15),
            widget = wibox.container.margin,
            forced_height = screen_height - dpi(50)
        }

    }

    local WifiManager = wibox.widget {
        {
            {
                {
                    id = "img",
                    widget = wibox.widget.imagebox,
                    resize = true
                },
                id = "mg",
                margins = 7,
                widget = wibox.container.margin
            },
            id = "backgroundBox",
            widget = wibox.container.background,
            bg = beautiful.xcolor0,

            fg = beautiful.xforeground,
            shape = gears.shape.rounded_rect
        },

        margins = 0,
        widget = wibox.container.margin
    }
    function WifiManagerIconLoad()
        local connectionType = network.getConnectionType()
        Wifi_Type_Conection = connectionType

        if connectionType == 0 then
            WifiManager.backgroundBox.mg.img.image = beautiful.icon_Offline
            WifiManager.backgroundBox.shape = nil
            WifiManager.backgroundBox.bg = beautiful.transparent
            if wifi_center.visible then
                wifi_center_hide()
            end

        elseif connectionType == 1 then
            WifiManager.backgroundBox.mg.img.image = beautiful.icon_Ethernet
            WifiManager.backgroundBox.shape = nil
            WifiManager.backgroundBox.bg = beautiful.transparent
            if wifi_center.visible then
                wifi_center_hide()
            end
        elseif connectionType == 3 then
            WifiManager.backgroundBox.mg.img.image = beautiful.icon_Wifi_off
            WifiManager.backgroundBox.shape = gears.shape.rounded_rect
            WifiManager.backgroundBox.bg = beautiful.xcolor0
            
        elseif connectionType == 2 then
            local signal = network.getWifiSignal()
            WifiManager.backgroundBox.mg.img.image = network_tools.get_wifi_image(signal)
            WifiManager.backgroundBox.shape = gears.shape.rounded_rect
            WifiManager.backgroundBox.bg = beautiful.xcolor0
        end
    end
    WifiManager:connect_signal("button::press", function()
        if Wifi_Type_Conection == 2 or Wifi_Type_Conection == 3 then
            wifi_center_toggle()
        end
    end)

    WifiManager:connect_signal("mouse::enter", function()
        local w = _G.mouse.current_wibox
        if Wifi_Type_Conection > 1 then
            WifiManager.backgroundBox.bg = beautiful.xcolor4
            if w then
                w.cursor = "hand2"
            end
        end
    end)

    WifiManager:connect_signal("mouse::leave", function()
        local w = _G.mouse.current_wibox
        if Wifi_Type_Conection < 2 then
            WifiManager.backgroundBox.bg = beautiful.transparent
        else
            WifiManager.backgroundBox.bg = beautiful.xcolor0
        end
        if w then
            w.cursor = "left_ptr"
        end
    end)



    local WifiManagericonLoadTimer = gears.timer{
        timeout = 30,
        autostart = true,
        call_now = true,
        callback = WifiManagerIconLoad
    }

    WifiManagericonLoadTimer:start()

    -- Setup wibar
    -----------------

    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()

    -- Layoutbox
    local layoutbox_buttons = gears.table.join( -- Left click
    awful.button({}, 1, function(c)
        awful.layout.inc(1)
    end), -- Right click
    awful.button({}, 3, function(c)
        awful.layout.inc(-1)
    end), -- Scrolling
    awful.button({}, 4, function()
        awful.layout.inc(-1)
    end), awful.button({}, 5, function()
        awful.layout.inc(1)
    end))

    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(layoutbox_buttons)

    local layoutbox = wibox.widget {
        s.mylayoutbox,
        margins = {
            bottom = dpi(7),
            left = dpi(8),
            right = dpi(8)
        },
        widget = wibox.container.margin
    }

    helpers.add_hover_cursor(layoutbox, "hand2")

    -- Create the wibar
    s.mywibar = awful.wibar({
        type = "dock",
        position = "left",
        screen = s,
        height = awful.screen.focused().geometry.height - dpi(50),
        width = dpi(50),
        shape = helpers.rrect(beautiful.border_radius),
        bg = beautiful.transparent,
        ontop = true,
        visible = true
    })

    awesome_icon:buttons(gears.table.join(awful.button({}, 1, function()
        dashboard_toggle()
    end)))

    app_browser_buton:buttons(gears.table.join(awful.button({}, 1, function()
        awful.spawn.with_shell(browser)
    end)))
    app_FileManager_buton:buttons(gears.table.join(awful.button({}, 1, function()
        awful.spawn.with_shell(file_manager)
    end)))

    app_code_buton:buttons(gears.table.join(awful.button({}, 1, function()
        awful.spawn.with_shell(vscode)
    end)))

    app_Office_buton:buttons(gears.table.join(awful.button({}, 1, function()
        awful.spawn.with_shell(office)
    end)))

    -- Remove wibar on full screen
    local function remove_wibar(c)
        if c.fullscreen or c.maximized then
            c.screen.mywibar.visible = false
        else
            c.screen.mywibar.visible = true
        end
    end

    -- Remove wibar on full screen
    local function add_wibar(c)
        if c.fullscreen or c.maximized then
            c.screen.mywibar.visible = true
        end
    end

    client.connect_signal("property::fullscreen", remove_wibar)

    client.connect_signal("request::unmanage", add_wibar)

    -- Create the taglist widget
    s.mytaglist = require("ui.widgets.pacman_taglist")(s)

    local taglist = wibox.widget {
        s.mytaglist,
        shape = beautiful.taglist_shape_focus,
        bg = beautiful.xcolor0,
        widget = wibox.container.background
    }

    local apps = wibox.widget {
        {
            {
                app_browser_buton,
                app_Office_buton,
                app_FileManager_buton,
                app_code_buton,
                spacing = dpi(3),
                layout = wibox.layout.fixed.vertical
            },
            top = dpi(0),
            bottom = dpi(0),
            widget = wibox.container.margin
        },
        bg = beautiful.lighter_bg,
        shape = helpers.rrect(beautiful.bar_radius),
        widget = wibox.container.background
    }



    local dock_apps = wibox.widget {
        {
            {
                {
                    widget = wibox.widget.imagebox,
                    image = beautiful.dock_apps_icon,
                    resize = true
                },
                margins = 7,
                widget = wibox.container.margin
            },
            id = "backgroundBox",
            widget = wibox.container.background,
            bg = beautiful.xcolor0,
            border_color = beautiful.xcolor0,
            fg = beautiful.xforeground,
            shape = gears.shape.rounded_rect
        },
        margins = 0,
        widget = wibox.container.margin
    }

    helpers.add_hover_cursor_button(dock_apps)

    dock_apps:buttons(gears.table.join(awful.button({}, 1, function()
        apps_dock_toggle()
    end)))

    -- Add widgets to wibar
    s.mywibar:setup{
        {
            {
                layout = wibox.layout.align.vertical,
                expand = "none",
                { -- top
                    awesome_icon,
                    taglist,
                    spacing = dpi(10),
                    layout = wibox.layout.fixed.vertical
                },
                -- middle
                {
                    apps,
                    spacing = dpi(10),
                    layout = wibox.layout.fixed.vertical
                },
                { -- bottom
                    stats,
                    WifiManager,
                    notif_center_button,
                    -- layoutbox,
                    dock_apps,
                    spacing = dpi(8),
                    layout = wibox.layout.fixed.vertical
                }
            },
            margins = dpi(8),
            widget = wibox.container.margin
        },
        bg = beautiful.darker_bg,
        shape = helpers.rrect(beautiful.border_radius),
        widget = wibox.container.background
    }

    -- wibar position
    s.mywibar.x = dpi(25)
end)
