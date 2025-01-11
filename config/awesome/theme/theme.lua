-- Standard awesome library
local gears = require("gears")
local gfs = require("gears.filesystem")

-- Theme handling library
local themes_path = gfs.get_themes_dir()
local theme = dofile(themes_path .. "default/theme.lua")
local theme_assets = require("beautiful.theme_assets")
local xresources = require("beautiful.xresources")
local xrdb = xresources.get_current_theme()
local dpi = xresources.apply_dpi

-- Helpers
local helpers = require("helpers")


-- Theme
----------


-- colors
----------
-- Load ~/.Xresources
theme.xbackground = xrdb.background
theme.xforeground = xrdb.foreground
theme.xcolor0 = xrdb.color0
theme.xcolor1 = xrdb.color1
theme.xcolor2 = xrdb.color2
theme.xcolor3 = xrdb.color3
theme.xcolor4 = xrdb.color4
theme.xcolor5 = xrdb.color5
theme.xcolor6 = xrdb.color6
theme.xcolor7 = xrdb.color7
theme.xcolor8 = xrdb.color8
theme.xcolor9 = xrdb.color9
theme.xcolor10 = xrdb.color10
theme.xcolor11 = xrdb.color11
theme.xcolor12 = xrdb.color12
theme.xcolor13 = xrdb.color13
theme.xcolor14 = xrdb.color14
theme.xcolor15 = xrdb.color15
-- Aditionals
theme.darker_bg = "#0a1419"
theme.lighter_bg = "#162026"
theme.dashboard_fg = "#666c79"
theme.transparent = "#00000000"
theme.bateryacent = "#6791c9"
-- Power Menu
theme.color_Poweroff = "#8f0000"
theme.color_Reboot = "#bd7e02"
theme.color_Lock = "#087485"
theme.color_Logout = "#088542"
-- Power Menu Hover
theme.color_hover_Poweroff = "#4d0101"
theme.color_hover_Reboot = "#634201"
theme.color_hover_Lock = "#04434d"
theme.color_hover_Logout = "#054d26"
-- Network
theme.color_Wifi_Connect = "#387050"
theme.color_Wifi_Error = "#702828"
theme.color_Wifi_Save = "#6b6b6b"
-- Background Colors
theme.bg_dark = theme.darker_bg
theme.bg_normal = theme.xbackground
theme.bg_focus = theme.xbackground
theme.bg_urgent = theme.xbackground
theme.bg_minimize = theme.xbackground
theme.bg_secondary = theme.darker_bg
theme.bg_accent = theme.lighter_bg
-- Foreground Colors
theme.fg_normal = theme.xforeground
theme.fg_focus = theme.xforeground
theme.fg_urgent = theme.xcolor1
theme.fg_minimize = theme.xcolor0

-- Wallpaper
----------
theme.wallpaper = gfs.get_configuration_dir() .. "theme/assets/bg.png"

-- PFP
----------
theme.pfp = gears.surface.load_uncached(gfs.get_configuration_dir() .. "theme/assets/pfp.png")

-- Tux
--------
theme.Tux = gears.surface.load_uncached(gfs.get_configuration_dir() .. "theme/assets/Tux.png")

-- Icons
----------
theme.dock_apps_icon = gears.surface.load_uncached(gfs.get_configuration_dir() .. "theme/assets/icons/dock_apps_icon.svg")
theme.view_icon = gears.surface.load_uncached(gfs.get_configuration_dir() .. "theme/assets/icons/view.svg")
theme.hidden_icon = gears.surface.load_uncached(gfs.get_configuration_dir() .. "theme/assets/icons/hidden.svg")

-- Power Menu
theme.icon_Poweroff = gears.surface.load_uncached(gfs.get_configuration_dir() .. "theme/assets/icons/Power_Menu/Poweroff.svg")
theme.icon_Reboot = gears.surface.load_uncached(gfs.get_configuration_dir() .. "theme/assets/icons/Power_Menu/Reboot.svg")
theme.icon_Lock = gears.surface.load_uncached(gfs.get_configuration_dir() .. "theme/assets/icons/Power_Menu/Lock.svg")
theme.icon_Logout = gears.surface.load_uncached(gfs.get_configuration_dir() .. "theme/assets/icons/Power_Menu/Logout.svg")
-- Network
theme.icon_Ethernet = gears.surface.load_uncached(gfs.get_configuration_dir() .. "theme/assets/icons/Network/Ethernet.svg")
theme.icon_Offline = gears.surface.load_uncached(gfs.get_configuration_dir() .. "theme/assets/icons/Network/Offline.svg")
theme.icon_Wifi_off = gears.surface.load_uncached(gfs.get_configuration_dir() .. "theme/assets/icons/Network/Wi-Fi/Off.svg")
theme.icon_Wifi_0 = gears.surface.load_uncached(gfs.get_configuration_dir() .. "theme/assets/icons/Network/Wi-Fi/0.svg")
theme.icon_Wifi_1 = gears.surface.load_uncached(gfs.get_configuration_dir() .. "theme/assets/icons/Network/Wi-Fi/1.svg")
theme.icon_Wifi_2 = gears.surface.load_uncached(gfs.get_configuration_dir() .. "theme/assets/icons/Network/Wi-Fi/2.svg")
theme.icon_Wifi_3 = gears.surface.load_uncached(gfs.get_configuration_dir() .. "theme/assets/icons/Network/Wi-Fi/3.svg")
theme.icon_Wifi_4 = gears.surface.load_uncached(gfs.get_configuration_dir() .. "theme/assets/icons/Network/Wi-Fi/4.svg")
theme.icon_Refresh = gears.surface.load_uncached(gfs.get_configuration_dir() .. "theme/assets/icons/Network/Refresh.svg")
theme.icon_Link = gears.surface.load_uncached(gfs.get_configuration_dir() .. "theme/assets/icons/Network/Link.svg")
theme.icon_Unlink = gears.surface.load_uncached(gfs.get_configuration_dir() .. "theme/assets/icons/Network/Unlink.svg")
theme.icon_share = gears.surface.load_uncached(gfs.get_configuration_dir() .. "theme/assets/icons/Network/Share.svg")
theme.icon_Unlocked = gears.surface.load_uncached(gfs.get_configuration_dir() .. "theme/assets/icons/Network/Unlocked.svg")
theme.icon_Unlocked_Password = gears.surface.load_uncached(gfs.get_configuration_dir() .. "theme/assets/icons/Network/Unlocked_Password.svg")
theme.icon_Locked_Password = gears.surface.load_uncached(gfs.get_configuration_dir() .. "theme/assets/icons/Network/Locked_Password.svg")
-- Mini Apps Dock
theme.icon_rubber_duck = gears.surface.load_uncached(gfs.get_configuration_dir() .. "theme/assets/icons/Mini_Apps_Dock/rubber_duck.svg")
theme.icon_Owl = gears.surface.load_uncached(gfs.get_configuration_dir() .. "theme/assets/icons/Owl.svg")
theme.icon_File_Explorer = gears.surface.load_uncached(gfs.get_configuration_dir() .. "theme/assets/icons/File_Explorer.svg")
theme.icon_Visual_Studio_Code = gears.surface.load_uncached(gfs.get_configuration_dir() .. "theme/assets/icons/Visual_Studio_Code.svg")

-- Paths
--------
theme.path_QR = gfs.get_configuration_dir() .. "ui/wifi-center/Share/QR.png"
theme.path_app_default_icon =  gfs.get_configuration_dir() .. "theme/assets/icons/app_default.svg"

-- APPS Dock
--------
theme.Apps_Dock_Database = gfs.get_configuration_dir() .. "Awesome.DB"
theme.Apps_Dock_Desktops_Script = gfs.get_configuration_dir() .. "ui/dock-apps/Desktops_Manager"
theme.Apps_Dock_Icons_Folder = gfs.get_configuration_dir() .. "theme/AwesomeIcons/"
theme.Apps_Dock_Max_Display_APPS = 16
theme.Apps_Dock_Icons_GITHUB_USER = "Augusto-p"
theme.Apps_Dock_Icons_GITHUB_REPO = "AwesomeWM-Config"


-- Notifications bell icon
theme.notification_bell_icon = gears.surface.load_uncached(gfs.get_configuration_dir() .. "theme/assets/icons/notification-bell.png")

-- Notifications icon
theme.notification_icon = gears.surface.load_uncached(gfs.get_configuration_dir() .. "theme/assets/icons/notification.png")

-- Popup notifications icon
theme.volume_icon = gears.surface.load_uncached(gfs.get_configuration_dir() .. "theme/assets/icons/volume.png")
theme.volume_muted_icon = gears.surface.load_uncached(gfs.get_configuration_dir() .. "theme/assets/icons/mute.png")
theme.brightness_icon = gears.surface.load_uncached(gfs.get_configuration_dir() .. "theme/assets/icons/brightness.png")

-- Fonts
theme.font_name = "Iosevka Nerd Font Mono "
theme.font = theme.font_name .. "8"
theme.icon_font_name = "Material Icons "
theme.icon_font = theme.icon_font_name .. "18"
theme.font_taglist = theme.icon_font_name .. "13"

-- Borders
theme.border_width = dpi(0)
theme.oof_border_width = dpi(0)
theme.border_normal = theme.darker_bg
theme.border_focus = theme.darker_bg
theme.widget_border_width = dpi(2)
theme.widget_border_color = theme.darker_bg

-- Radius
theme.border_radius = dpi(12)
theme.client_radius = dpi(10)
theme.dashboard_radius = dpi(10)
theme.bar_radius = dpi(10)

-- Taglist
local taglist_square_size = dpi(0)
theme.taglist_squares_sel = theme_assets.taglist_squares_sel(taglist_square_size, theme.fg_normal)
theme.taglist_squares_unsel = theme_assets.taglist_squares_unsel(taglist_square_size, theme.fg_normal)
theme.taglist_font = theme.font_taglist
theme.taglist_bg = theme.wibar_bg

theme.taglist_bg_focus = theme.lighter_bg
theme.taglist_fg_focus = theme.xcolor3

theme.taglist_bg_urgent = theme.wibar_bg
theme.taglist_fg_urgent = theme.xcolor6

theme.taglist_bg_occupied = theme.wibar_bg
theme.taglist_fg_occupied = theme.xcolor6

theme.taglist_bg_empty = theme.wibar_bg
theme.taglist_fg_empty = theme.xcolor8

theme.taglist_bg_volatile = transparent
theme.taglist_fg_volatile = theme.xcolor11

theme.taglist_disable_icon = true

theme.taglist_shape_focus = helpers.rrect(theme.bar_radius)
theme.taglist_shape_empty = helpers.rrect(theme.bar_radius)
theme.taglist_shape = helpers.rrect(theme.bar_radius)
theme.taglist_shape_urgent = helpers.rrect(theme.bar_radius)
theme.taglist_shape_volatile = helpers.rrect(theme.bar_radius)

-- Titlebars
theme.titlebar_enabled = true
theme.titlebar_size = dpi(31)
theme.titlebar_unfocused = theme.xcolor0

-- Pop up notifications
theme.pop_size = dpi(180)
theme.pop_bg = theme.xbackground
theme.pop_bar_bg = theme.xcolor0
theme.pop_vol_color = theme.xcolor4
theme.pop_brightness_color = theme.xcolor5
theme.pop_fg = theme.xforeground
theme.pop_border_radius = theme.border_radius

-- Tooltip
theme.tooltip_bg = theme.xbackground
theme.tooltip_height = dpi(245)
theme.tooltip_width = dpi(200)
theme.tooltip_gap = dpi(10)
theme.tooltip_box_margin = dpi(10)
theme.tooltip_border_radius = theme.border_radius
theme.tooltip_box_border_radius = theme.bar_radius

-- Edge snap
theme.snap_bg = theme.xcolor8
theme.snap_shape = helpers.rrect(0)

-- Prompts
theme.prompt_bg = transparent
theme.prompt_fg = theme.xforeground

-- dashboard
theme.dashboard_width = dpi(300)
theme.dashboard_box_bg = theme.lighter_bg
theme.dashboard_box_fg = theme.dashboard_fg

-- Playerctl
theme.playerctl_ignore  = {"firefox", "qutebrowser", "chromium", "brave"}
theme.playerctl_player  = {"spotify", "mpd", "%any"}
theme.playerctl_update_on_activity = true
theme.playerctl_position_update_interval = 1

-- Mainmenu
theme.menu_font = theme.font_name .. "medium 10"
theme.menu_height = dpi(30)
theme.menu_width = dpi(150)
theme.menu_bg_normal = theme.xbackground
theme.menu_bg_focus = theme.lighter_bg
theme.menu_fg_normal= theme.xforeground
theme.menu_fg_focus= theme.xcolor4
theme.menu_border_width = dpi(0)
theme.menu_border_color = theme.xcolor0
theme.menu_submenu = "»  "
theme.menu_submenu_icon = nil

-- Hotkeys Pop Up
theme.hotkeys_bg = theme.xbackground
theme.hotkeys_fg = theme.xforeground
theme.hotkeys_modifiers_fg = theme.xforeground
theme.hotkeys_font = theme.font_name .. "11"
theme.hotkeys_description_font = theme.font_name .. "9"
theme.hotkeys_shape = helpers.rrect(theme.border_radius)
theme.hotkeys_group_margin = dpi(40)

-- Layout List
theme.layoutlist_border_color = theme.lighter_bg
theme.layoutlist_border_width = theme.border_width
theme.layoutlist_shape_selected = helpers.rrect(dpi(10))
theme.layoutlist_bg_selected = theme.lighter_bg

-- Recolor Layout icons:
theme = theme_assets.recolor_layout(theme, theme.xforeground)

-- Gaps
theme.useless_gap = dpi(5)

-- Wibar
theme.wibar_width = dpi(45)
theme.wibar_bg = theme.xbackground
theme.wibar_position = "left"

-- Tabs
theme.mstab_bar_height = dpi(60)
theme.mstab_bar_padding = dpi(0)
theme.mstab_border_radius = theme.border_radius
theme.tabbar_disable = true
theme.tabbar_style = "modern"
theme.tabbar_bg_focus = theme.lighter_bg
theme.tabbar_bg_normal = theme.darker_bg
theme.tabbar_fg_focus = theme.xforeground
theme.tabbar_fg_normal = theme.xcolor0
theme.tabbar_position = "bottom"
theme.tabbar_AA_radius = 0
theme.tabbar_size = 40
theme.mstab_bar_ontop = true

-- Notifications
theme.notification_spacing = 24
theme.notification_border_radius = dpi(6)
theme.notification_border_width = dpi(0)

-- Notif center
theme.notif_center_radius = theme.border_radius
theme.notif_center_box_radius = theme.notif_center_radius / 2

-- Swallowing
theme.dont_swallow_classname_list = {
    "firefox", "gimp", "Google-chrome", "Thunar", 
}

-- Layout Machi
theme.machi_switcher_border_color = theme.darker_bg
theme.machi_switcher_border_opacity = 0.25
theme.machi_editor_border_color = theme.darker_bg
theme.machi_editor_border_opacity = 0.25
theme.machi_editor_active_opacity = 0.25

-- Tag Preview
theme.tag_preview_client_border_radius = dpi(6)
theme.tag_preview_client_opacity = 0.1
theme.tag_preview_client_bg = theme.xbackground
theme.tag_preview_client_border_color = theme.darker_bg
theme.tag_preview_client_border_width = theme.widget_border_width

theme.tag_preview_widget_border_radius = theme.border_radius
theme.tag_preview_widget_bg = theme.xbackground
theme.tag_preview_widget_border_color = theme.widget_border_color
theme.tag_preview_widget_border_width = theme.widget_border_width * 0
theme.tag_preview_widget_margin = dpi(10)

-- Task Preview
theme.task_preview_widget_border_radius = dpi(10)
theme.task_preview_widget_bg = theme.xbackground
theme.task_preview_widget_border_color = theme.widget_border_color
theme.task_preview_widget_border_width = theme.widget_border_width * 0
theme.task_preview_widget_margin = dpi(15)

theme.fade_duration = 250

return theme
