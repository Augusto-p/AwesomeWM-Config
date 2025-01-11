-- Standard awesome library
local gears = require("gears")
local awful = require("awful")

-- Theme handling library
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local lfs = require("lfs")
-- Widget library
local wibox = require("wibox")

-- rubato
local rubato = require("module.rubato")

-- Helpers
local helpers = require("helpers")
local keyrec = require("awful.keygrabber")
local DataBaseManager = require("ui.dock-apps.Database")
local naughty = require("naughty")

-- Get screen geometry
local screen_width = awful.screen.focused().geometry.width
local screen_height = awful.screen.focused().geometry.height


-- variavles
-----------------------
local querry_default = "@ Search:"
local querry = "" -- Variable para almacenar el texto ingresado
local querry_key_rec_active = false
local DB = DataBaseManager:new(beautiful.Apps_Dock_Database)





-- dashboard
apps_dock = wibox({
    type = "dock",
    screen = screen.primary,
    height = screen_height - dpi(50),
    width = beautiful.dashboard_width or dpi(300),
    shape = helpers.rrect(beautiful.border_radius),
    ontop = true,
    y = dpi(25),
    -- x = dpi(100),
    visible = false

})

local app_slide = rubato.timed{
    pos = dpi(-300),
    rate = 60,
    intro = 0.3,
    duration = 0.8,
    easing = rubato.quadratic,
    awestore_compat = true,
    subscribed = function(pos) apps_dock.x = pos end
}


local apps_dock_status = false

app_slide.ended:subscribe(function()
    if not apps_dock_status then
        apps_dock.visible = false
    end
end)


apps_dock_show = function()
    apps_dock.visible = true
    app_slide:set(100)
    apps_dock_status = true

end

apps_dock_hide = function()
    app_slide:set(-375)
    apps_dock_status = false
    
end

apps_dock_toggle = function()
    if apps_dock_status then
        apps_dock_hide()
    else
        apps_dock_show()
    end
end
local function carpeta_existe(ruta)
    local attr = lfs.attributes(ruta)
    return (attr and attr.mode == "directory")
end
local function archivo_existe(ruta)
    local archivo = io.open(ruta, "r") -- "r" es el modo de solo lectura
    if archivo then
        io.close(archivo)
        return true
    else
        return false
    end
end

function  loadDesktops() 
    if not carpeta_existe(beautiful.Apps_Dock_Icons_Folder) then
        lfs.mkdir(beautiful.Apps_Dock_Icons_Folder)
    end
    if not archivo_existe(beautiful.Apps_Dock_Database) then
        local handle = io.popen(beautiful.Apps_Dock_Desktops_Script.." "..beautiful.Apps_Dock_Database.." "..beautiful.Apps_Dock_Icons_Folder.." "..beautiful.path_app_default_icon.." "..beautiful.Apps_Dock_Icons_GITHUB_USER.." "..beautiful.Apps_Dock_Icons_GITHUB_REPO.."Reset")
        local file = handle:read("*a")
        handle:close()    
    end 
    
    local handle = io.popen(beautiful.Apps_Dock_Desktops_Script.." "..beautiful.Apps_Dock_Database.." "..beautiful.Apps_Dock_Icons_Folder.." "..beautiful.path_app_default_icon.." "..beautiful.Apps_Dock_Icons_GITHUB_USER.." "..beautiful.Apps_Dock_Icons_GITHUB_REPO);
    local file = handle:read("*a");
    handle:close();
end


local querry_widget = wibox.widget {
    {
        id = "textbox",
        font = beautiful.font_name .. 'Regular 15',
        widget = wibox.widget.textbox,
        text = querry_default,
        align = "left"
    },
    forced_width = 180,
    margins = 10,
    widget = wibox.container.margin
}

local querry_box = wibox.widget {
    {
        querry_widget,
        id = "borderbox",
        widget = wibox.container.background,
        bg = beautiful.lighter_bg,
        border_color = beautiful.darker_bg,
        border_width = 1,
        fg = beautiful.xforeground,
        shape = gears.shape.rounded_rect,
    },
    height = 50,
    forced_width = 300,
    visible = true,
    ontop = false,
    margins = 10,
    widget = wibox.container.margin,
    layout = wibox.layout.fixed.vertical,
}


querry_box.focus = function(self)
    if querry_key_rec_active then
        self.borderbox.border_color = beautiful.xforeground
    else
        self.borderbox.border_color = beautiful.darker_bg
    end
end

local function writeQuerry()
    if #querry == 0 then
        querry_widget.textbox.text = querry_default
        LoadApps(DB:get_top_apps(beautiful.Apps_Dock_Max_Display_APPS))
    else
        querry_widget.textbox.text = querry
        LoadApps(DB:search(querry, beautiful.Apps_Dock_Max_Display_APPS))
    end
end

function stop_QuerryKeyRec()
    keyrec.stop()
    querry_key_rec_active = false
    querry_box:focus()
end
local function start_QuerryKeyRec()
    writeQuerry()
    querry_key_rec_active = true
    querry_box:focus()
    keyrec.run(function(_, key, event)
        if querry_key_rec_active then
            if event == "press" then
                if key == "Escape" then
                    
                    stop_QuerryKeyRec()
                elseif key == "BackSpace" then
                    querry = querry:sub(1, -2)
                    writeQuerry()
                elseif key == "Return" then
                    stop_QuerryKeyRec()
                elseif #key == 1 or key == "space" then
                    querry = querry .. key
                    writeQuerry()
                end
            end
        end
    end)
end

querry_box:connect_signal("button::press", function()
    if not querry_key_rec_active then
        start_QuerryKeyRec() -- Iniciar la captura de texto
    end
end)

local CreateElementNil = function()
    local img = wibox.widget {
        {
            widget = wibox.widget.imagebox,
            -- image = beautiful.,
            resize = true
        },
        margins = 25,
        top = 10,
        bottom = 0,
        forced_height = 110,
        widget = wibox.container.margin
    }

    local texto = wibox.widget {
        {
            font = beautiful.font_name .. 'Regular 12',
            widget = wibox.widget.textbox,
            text = "",
            forced_height = 50,
            align = "center"
        },
        forced_height = 70,
        margins = 5,
        top = 0,
        widget = wibox.container.margin
    }

    local element = wibox.widget {
        {
            img,
            texto,
            layout = wibox.layout.fixed.vertical,
            spacing = -20,
            margins = 0,
            widget = wibox.container.margin
        },
        bg = beautiful.transparent,
        widget = wibox.container.background,
        fg = beautiful.xforeground,
        shape = gears.shape.rounded_rect,
        forced_width = 100,
        forced_height = 145
    }


    return element
end

local CreateElement = function(App)
    -- Image widget with margins
    local img = wibox.widget {
        {
            widget = wibox.widget.imagebox,
            image = App["Icon"],
            resize = true
        },
        margins = 25,
        top = 10,
        bottom = 0,
        forced_height = 110,
        widget = wibox.container.margin
    }

    -- Center the image horizontally using align.horizontal
    local img_centered = wibox.widget {
        img,
        layout = wibox.layout.align.horizontal,
        expand = "none"
    }

    -- Text widget with vertical and horizontal centering
    local texto = wibox.widget {
        {
            font = beautiful.font_name .. 'Regular 12',
            widget = wibox.widget.textbox,
            text = App["Name"],
            align = "center",  -- Horizontally center the text
            valign = "center",  -- Vertically center the text
            forced_height = 50
        },
        forced_height = 70,
        margins = 5,
        top = 0,
        bottom = 20,  -- Increased bottom margin for spacing below the text
        widget = wibox.container.margin
    }

    -- Create the final widget (element) with centered image and text
    local element = wibox.widget {
        {
            img_centered,
            texto,
            layout = wibox.layout.fixed.vertical,
            spacing = -20,
            margins = 0,
            widget = wibox.container.margin,
            id ="a"
        },
        bg = beautiful.xcolor0,
        widget = wibox.container.background,
        fg = beautiful.xforeground,
        shape = gears.shape.rounded_rect,
        forced_width = 100,
        forced_height = 145
    }

    -- Create the tooltip for the element
    if App["Coment"] then
        
        local tooltip = awful.tooltip({     
            objects = {element},
            text = App["Coment"],  -- Texto del tooltip
            margins = 5,  -- Márgenes alrededor del texto del tooltip
            -- -- preferred_positions = {"bottom", "top", "left", "right"},  -- Posiciones preferidas para el tooltip
            preferred_positions = {"right"},  -- Posiciones preferidas para el tooltip
            font = beautiful.font_name .. 'Regular 10',
            bg = beautiful.xcolor0,  -- Color de fondo del tooltip
            fg = beautiful.xforeground,  -- Color del texto
            
        })
    end

    element:connect_signal("button::press", function(_, lx, ly, button)
        if button == 1 then  -- Left click (button 1)
            awful.spawn.with_shell(string.gsub(App["Exec"], "%%(.)", ""))
            DB:new_use(App["ID"])
            stop_QuerryKeyRec()
            querry = ""
            writeQuerry()
            apps_dock_hide()
        elseif button == 3 then  -- Right click (button 3)
            naughty.notify({text = "Right-click on " .. App["Name"]})

        end
    end)
    -- Mouse enter action
    element:connect_signal("mouse::enter", function()
        element.bg = beautiful.xcolor4
        local w = _G.mouse.current_wibox
        if w then
            w.cursor = "hand2"
        end
    end)

    -- Mouse leave action
    element:connect_signal("mouse::leave", function()
        element.bg = beautiful.xcolor0
        local w = _G.mouse.current_wibox
        if w then
            w.cursor = "left_ptr"
        end
    end)

    return element
end




local createRow = function(Col0, Col1)
    local Row = wibox.widget {
            forced_width = 300,
            margins = 10,
            spacing = dpi(10),
            widget = wibox.container.margin,
            layout = wibox.layout.flex.horizontal
        }
    if Col0 ~= nil or Col1 ~= nil then
        -- naughty.notify({text="IN"})
        if Col0 ~= nil then
            local Column0 = CreateElement(Col0)
            Row:add(Column0)
        else
            local Column0 = CreateElementNil()
            Row:add(Column0)
        end
        
        if Col1 ~= nil then
            local Column1 = CreateElement(Col1)
            Row:add(Column1)
        else
            local Column1 = CreateElementNil()
            Row:add(Column1)
        end

        return Row
    else
        return nil
    end

end



local applications = wibox.widget {
    
        {
            spacing = dpi(10),
            margins = 0,
            widget = wibox.container.margin,
            layout = wibox.layout.fixed.vertical,
            id="box"
        },
        
    forced_height = screen_height - 120,
    forced_width = 270,
    margins = 10,
    widget = wibox.container.margin
}

local ClearApps = function()
   applications.box:reset()
end

function LoadApps(Apps)
   ClearApps()
    local maxindex = math.min(beautiful.Apps_Dock_Max_Display_APPS, #Apps)
    for i = 1, maxindex, 2 do
        local row = createRow(Apps[i] or nil, Apps[i+1] or nil)
        if row ~= nil then
            applications.box:add(row)
        end
    end 

end


loadDesktops()
LoadApps(DB:get_top_apps(beautiful.Apps_Dock_Max_Display_APPS))

apps_dock:setup{
    {
        {
            querry_box,
            applications,
            -- scroll,
            layout = wibox.layout.align.vertical
        },
        margins = dpi(10),
        bottom = 0,
        widget = wibox.container.margin,
        forced_height = screen_height - dpi(50)
    },
    bg = beautiful.xbackground,
    shape = helpers.rrect(beautiful.dashboard_radius),
    widget = wibox.container.background
}
