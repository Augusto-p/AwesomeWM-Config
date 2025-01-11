local awful = require('awful')
local wibox = require('wibox')
local beautiful = require('beautiful')
local dpi = require('beautiful').xresources.apply_dpi
local gears = require('gears')
local naughty = require("naughty")
local button_container = require('ui.widgets.button')
local helpers = require("helpers")
local keygrabber = require("awful.keygrabber")
local network = require("ui.wifi-center.Network.init")
local network_tools = require("ui.wifi-center.Network.tools")

-- contants
local text_default = "Enter Password here..."
math.randomseed(os.time()) -- Semilla para el generador aleatorio

-- variavles 
local input_text = "" -- Variable para almacenar el texto ingresado
local keygrabber_active = false
local viewPass = false
local connectonBox = false
local sharebox = false
local NetworkSSID = ""
local rows = {} -- Tabla para almacenar filas con sus IDs

-- Global Función
-----------------------

-- Función para generar un identificador único
local function generate_id()
    return tostring(math.random(100000, 999999)) -- Genera un número aleatorio de 6 dígitos
end


local function get_lock_image(lock)
	if lock == 1 then
		return beautiful.icon_Locked_Password
	elseif lock == 0 then
		return beautiful.icon_Unlocked
	elseif lock == 2 then
		return beautiful.icon_Unlocked_Password
	end
end

local function get_row_color(color)
    if color == 1 then
        return beautiful.color_Wifi_Connect -- green
    elseif color == 2 then
        return beautiful.xcolor0    -- gray
    elseif color == 3 then
        return beautiful.color_Wifi_Error -- red
    elseif color == 4 then
        return beautiful.color_Wifi_Save -- red
    
    
    else
        return beautiful.transparent -- Transparente (RGBA)
    end
end




-- Header
-----------------------
local wifi_header = wibox.widget {
	text   = 'Network Center',
	font   = beautiful.font_name .. 'Bold 18',
	align  = 'left',
	valign = 'center',
	widget = wibox.widget.textbox
}

local refresh_button = wibox.widget {
	{
		{
            widget = wibox.widget.imagebox,
            image = beautiful.icon_Refresh,
            resize = false
        },
		margins = dpi(7),
		widget = wibox.container.margin
	},
	widget = button_container
}

local Share_button = wibox.widget {
    nil,
	{
		{{
            {
                widget = wibox.widget.imagebox,
                image = beautiful.icon_share,
                resize = false
            },
            margins = dpi(7),
            
            widget = wibox.container.margin
        },
        widget = button_container   },
		bg = beautiful.xcolor0,
		shape = gears.shape.circle,
		widget = wibox.container.background
	},
	nil,
	expand = 'none',
    visible = false,
	layout = wibox.layout.align.vertical

}
local refresh_button_wrapped = wibox.widget {
	nil,
	{
		refresh_button,
		bg = beautiful.xcolor0,
		shape = gears.shape.circle,
		widget = wibox.container.background
	},
	nil,
	expand = 'none',
	layout = wibox.layout.align.vertical
}

-- Grid
-----------------------
local grid = wibox.layout.grid()
grid.homogeneous = true
grid.forced_num_cols = 1

-- Función para cambiar el color de una fila por su ID
local function change_row_color_by_SSID(SSID, color)
    local row = rows[SSID]
    if row then
        row.bg = get_row_color(color)
    end
end

-- Función para eliminar una fila por su ID
local function remove_row_by_id(id)
    local row = rows[id]
    if row then
        grid:remove(row)
        rows[id] = nil -- Eliminar de la tabla de filas
        print("Fila con ID " .. id .. " eliminada.")
    else
        print("No se encontró ninguna fila con ID " .. id)
    end
end

-- Función para eliminar todas las filas
local function clear_rows()
    for _, row in pairs(rows) do
        grid:remove(row)
    end
    rows = {} -- Reiniciar la tabla de filas
end


-- Connection
-----------------------

-- Input Widget
local input_widget = wibox.widget {
    {
        id = "textbox",
        font = beautiful.font_name .. 'Regular 11',
        widget = wibox.widget.textbox,
        text = text_default,
        align = "left"
    },

    forced_width = 180,
    margins = 10,
    widget = wibox.container.margin
}

-- Password view
local pass_mode_buton = wibox.widget {
    {
        {{
            id = "img",
            widget = wibox.widget.imagebox,
            image = beautiful.view_icon,
            resize = true
        },
        id ="mg",
        margins = 5,
        widget = wibox.container.margin
    },
        id = "backgroundBox",
        widget = wibox.container.background,
        bg = beautiful.xcolor0,

        fg = beautiful.xforeground,
        shape = gears.shape.rounded_rect
    },
    forced_width = 50,
    margins = 5,
    widget = wibox.container.margin
}
helpers.add_hover_cursor_button(pass_mode_buton)


-- Container Box
local containerBox = wibox.widget {
    {
        {
            input_widget,
            pass_mode_buton,
            layout = wibox.layout.fixed.horizontal
        },
        id = "borderbox",
        widget = wibox.container.background,
        bg = beautiful.darker_bg,
        border_color = beautiful.darker_bg,
        border_width = 1,
        fg = beautiful.xforeground,
        shape = gears.shape.rounded_rect

    },
    forced_width = 400,
    margins = 5,
    widget = wibox.container.margin
}
containerBox.focus = function(self)
    if keygrabber_active then
        self.borderbox.border_color = beautiful.xforeground
    else
        self.borderbox.border_color = beautiful.darker_bg
    end
end

-- Input Box
local input_box = wibox.widget {
    width = 350,
    height = 50,
    visible = true,
    ontop = false,
    bg = "#ff0000",
    forced_width = 400,
    widget = wibox.container.margin
}
input_box:setup{
    containerBox,
    layout = wibox.layout.flex.horizontal
}

-- Connect Button
local connectButton = wibox.widget {
    {
        {
            {
                text = "Connect",
                align = "center",
                valign = "center",
                font = beautiful.font.. "Bold 16",
                widget = wibox.widget.textbox
            },
            margins = 7,
            widget = wibox.container.margin
        },
        id = "backgroundBox",
        widget = wibox.container.background,
        bg = beautiful.darker_bg,
        fg = beautiful.xforeground,
        shape = gears.shape.rounded_rect
    },
    margins = 5,
    widget = wibox.container.margin
}
helpers.add_hover_cursor(connectButton, "hand2")
connectButton:connect_signal("mouse::enter", function()
    connectButton.backgroundBox.bg = beautiful.xcolor4
end)
connectButton:connect_signal("mouse::leave", function()
    connectButton.backgroundBox.bg = beautiful.darker_bg
end)

-- Connection Widget
local connection_widget = wibox.widget {
    {
        {
            text = "Wi-Fi Connection",
            align = "center",
            valign = "center",
            font = beautiful.font .. " 14",
            widget = wibox.widget.textbox
        },
        {
            text = "Connecting to ",
            align = "center",
            valign = "center",
            font = beautiful.font .. " 12",
            widget = wibox.widget.textbox,
            id = "TextName"
        },
        spacing = 15,
        id = "LayoutVertcal",
        layout = wibox.layout.fixed.vertical
    },
    {
        input_box,
        margins = 10,
        widget = wibox.container.margin
    },
    connectButton,
    spacing = 0,
    layout = wibox.layout.fixed.vertical
}

-- Connection Widget Box
local connection_widget_Box = wibox.widget {
    {
        connection_widget,
        margins = 10,
        widget = wibox.container.margin
    },
    visible = false,
    forced_height = 200, -- Altura fija
    forced_width = 300, -- Ancho fijo
    bg = beautiful.xcolor0,
    shape = gears.shape.rounded_rect, -- Bordes redondeados
    widget = wibox.container.background
}

-- Share
-----------------------
local Share_widget = wibox.widget {
    {
        {
            widget = wibox.widget.imagebox,
            image = beautiful.path_QR,
            id="img",
            resize = true
        },
        margins = 10,
        id="margin",
        widget = wibox.container.margin
    },
    visible = false,
    forced_height = 270, -- Altura fija
    forced_width = 300, -- Ancho fijo
    bg = beautiful.xcolor0,
    shape = gears.shape.rounded_rect, -- Bordes redondeados
    widget = wibox.container.background
}


-- Connection Función
local function HidePass(Text)
    local icon = "·"
    local returnText = ""
    for i = 1, #Text do
        returnText = returnText .. icon
    end
    return returnText
end

local function writeText()
    if #input_text == 0 then
        input_widget.textbox.text = text_default
    elseif viewPass then
        input_widget.textbox.text = input_text
    elseif not viewPass then
        input_widget.textbox.text = HidePass(input_text)
    end
end

function UpdateSSID(SSID)
    NetworkSSID = SSID
    connection_widget.LayoutVertcal.TextName.text = "Connecting to " .. SSID
end

    -- keygrabber
function stop_keygrabber()
    keygrabber.stop()
    keygrabber_active = false
    containerBox:focus()
end
local function start_input_capture()
    writeText()
    keygrabber_active = true
    containerBox:focus()
    keygrabber.run(function(_, key, event)
        if keygrabber_active then
            if event == "press" then
                if key == "Escape" then
                    stop_keygrabber()
                elseif key == "BackSpace" then
                    input_text = input_text:sub(1, -2)
                    writeText()
                elseif key == "Return" then
                    stop_keygrabber()
                elseif #key == 1 or key == "space" then
                    input_text = input_text .. key
                    writeText()
                end
            end
        end
    end)
end

    -- Buttons Función
containerBox:connect_signal("button::press", function()
    if not keygrabber_active then
        start_input_capture() -- Iniciar la captura de texto
    end
end)
connectButton:connect_signal("button::press", function()
    if keygrabber_active then
        stop_keygrabber()
    end

    local Responese = network.connect(NetworkSSID, input_text)
    if Responese == 0 then
        if connectonBox then
            connectonBox = not connectonBox
            connection_widget_Box.visible = false
        end
        LoadNetworks()
    elseif Responese == 1 then
        change_row_color_by_SSID(NetworkSSID, 4)
    elseif Responese == 2 then
        change_row_color_by_SSID(NetworkSSID, 3)
    end
    input_text = ""
    writeText()

end)
pass_mode_buton:connect_signal("button::press", function()
    viewPass = not viewPass
    writeText()
    if not viewPass then
        pass_mode_buton.backgroundBox.mg.img.image = beautiful.view_icon
    elseif viewPass then
        pass_mode_buton.backgroundBox.mg.img.image = beautiful.hidden_icon
    end    
end)
refresh_button:connect_signal("button::press", function()
    sharebox = false
    Share_widget.visible = false
    if network.getConnectionType() == 2 then
        Share_button.visible = true
    else
        Share_button.visible = false
    end


    LoadNetworks()
end)

Share_button:connect_signal("button::press", function()
    if connectonBox then
        connectonBox = not connectonBox
        connection_widget_Box.visible = false
    end

    if not sharebox then
        if network.ShareWifi() then
            Share_widget.visible = true
            Share_widget.margin.img.image = gears.surface.load_uncached(beautiful.path_QR)

            sharebox = not sharebox
        end
    else
        Share_widget.visible = false
        sharebox = not sharebox
    end
end)


local wifi_center = function(s)
    if network.getConnectionType() == 2 then
        Share_button.visible = true
    else
        Share_button.visible = false
    end

	return wibox.widget {
    layout = wibox.layout.align.vertical,
    {
        expand = 'none',
        layout = wibox.layout.fixed.vertical,
        spacing = dpi(10),
        {
            expand = 'none',
            layout = wibox.layout.align.horizontal,
            wifi_header,
            nil,
            {
                layout = wibox.layout.fixed.horizontal,
                spacing = dpi(5),
                refresh_button_wrapped,
                Share_button,
            }
        },
        grid
    },nil,
    {
        layout = wibox.layout.fixed.horizontal,
    {
        connection_widget_Box,
        margins = dpi(0),
        widget = wibox.container.margin
    },{
        Share_widget,
        margins = dpi(0),
        widget = wibox.container.margin
    }}
}
end

function add_row(x, SSID, lock, color)
    -- Columna 1: Imagen de WiFi
    local wifi_widget = wibox.widget {
        {
        image  = network_tools.get_wifi_image(x),
        resize = true,
        widget = wibox.widget.imagebox,
		forced_width = 25,
		forced_height = 25,},
        widget = wibox.container.margin,
        margins = 5
    }

    -- Columna 2: Texto
    local text_widget = wibox.widget {
        text   = SSID,
        font   = beautiful.font_name .. 'regular 12',
        align  = "left",
        valign = "center",
        widget = wibox.widget.textbox,
        forced_width = 150,
    }
    -- Columna 3: Imagen de bloqueo
    local lock_widget = wibox.widget {
        image  = get_lock_image(lock),
        resize = true,
        widget = wibox.widget.imagebox,
		forced_width = 25,
		forced_height = 25
    }

    -- Columna 4: Botón con imagen de "ver"
    local view_button =  wibox.widget {
        {
            {{
                id = "img",
                widget = wibox.widget.imagebox,
                image = beautiful.icon_Link,
                resize = true,
                -- forced_width = 20,
			    -- forced_height = 20
            },
            id ="mg",
            margins = 3,
            widget = wibox.container.margin
        },
            id = "backgroundBox",
            widget = wibox.container.background,
            bg = beautiful.transparent,
    
            fg = beautiful.xforeground,
            -- shape = gears.shape.circle
            shape = gears.shape.rect
            },
        margins = 0,
        widget = wibox.container.margin
    }

    if color == 1 then
        view_button.backgroundBox.mg.img.image = beautiful.icon_Unlink
    end

    view_button:connect_signal("mouse::enter", function()
        view_button.backgroundBox.bg = beautiful.xcolor4
        local w = _G.mouse.current_wibox
        if w then
            w.cursor = "hand2"
        end
    end)

    view_button:connect_signal("mouse::leave", function()
        view_button.backgroundBox.bg = beautiful.transparent
        local w = _G.mouse.current_wibox
        if w then
            w.cursor = "left_ptr"
        end
    end)

    -- Hacer clic en el botón de vista (opcional)
    view_button:connect_signal("button::press", function()
        if color == 1 then
            if connectonBox then
                connectonBox = not connectonBox
                connection_widget_Box.visible = false
            end
            network.desconnect()
            LoadNetworks()        
        elseif lock == 0 then
            if connectonBox then
                connectonBox = not connectonBox
                connection_widget_Box.visible = false
            end
            local responce = network.connect(SSID,"")
            if responce == 0 then
                LoadNetworks()
            else
                change_row_color_by_SSID(SSID, 3)
            end
        else
            if not connectonBox then
                connectonBox = not connectonBox
                Share_widget.visible = false
                sharebox = false
                connection_widget_Box.visible = true
            end
            UpdateSSID(SSID)        
            
            
        end

    end)

    
    -- Agrupar widgets en una fila y aplicar color de fondo
    local row = wibox.widget {
        {
            wifi_widget,
            text_widget,
            lock_widget,
            view_button,
            layout = wibox.layout.fixed.horizontal,
			spacing = 10,
        },
		forced_width = 300,
        bg     = get_row_color(color), -- Establecer color de fondo
        widget = wibox.container.background,
    }

    rows[SSID] = row
    -- Añadir la fila al grid
    grid:add(row)
end


-- Get Start Networks
-----------------------

function LoadNetworks()
    local networks = network.getData()
    clear_rows()
    for i, v in ipairs(networks) do
        local color = 2
        local lock = 1
        if v[1] == 1 then
            color = 1
        end
        if v[4] == 0 then
            lock = 0
        elseif v[1] == 1 then
            lock = 2
        end
        add_row(v[3], v[2], lock, color)
    end
end

LoadNetworks()

-- Añadir algunas filas de ejemplo
-- add_row(5, "Dispositivo A", 0, 1)  -- Verde
-- add_row(40, "Dispositivo B", 1, 2) -- Gris
-- add_row(80, "Dispositivo C", 1, 3)  -- Rojo
-- add_row(15, "Dispositivo D", 1, 0) -- Transparente



return wifi_center