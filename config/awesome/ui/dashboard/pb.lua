local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local helpers = require("helpers") -- Asegúrate de que helpers.rrect esté disponible

-- Función para crear un botón de poder con imagen SVG
local function create_power_button(image_path, color, command)
    return wibox.widget {
        {
            {
                {
                    image = image_path,
                    resize = true,
                    widget = wibox.widget.imagebox
                },
                margins = 10,
                widget = wibox.container.margin, -- Centra la imagen dentro del contenedor
            },
            forced_width = 50,
            forced_height = 50,
            shape = helpers.rrect(25), -- Botón redondo
            bg = color,
            id="backgroundBox",
            widget = wibox.container.background
        },
        margins = 8,
        widget = wibox.container.margin,
        buttons = {
            awful.button({}, 1, function()
                awful.spawn.with_shell(command)
            end)
        }
    }
end

-- Crear cada botón con su respectiva imagen SVG y comando
function add_pb_hover(buttom, normal, hover )
    buttom:connect_signal("mouse::enter", function()
        buttom.backgroundBox.bg = hover
        local w = _G.mouse.current_wibox
        if w then
            w.cursor = "hand2"
        end
    end)

    buttom:connect_signal("mouse::leave", function()
        buttom.backgroundBox.bg = normal
        local w = _G.mouse.current_wibox
        if w then
            w.cursor = "left_ptr"
        end
    end)
    -- body
end


local poweroff_button = create_power_button(beautiful.icon_Poweroff, beautiful.color_Poweroff, "poweroff") -- Rojo
local reboot_button = create_power_button(beautiful.icon_Reboot, beautiful.color_Reboot, "reboot") -- Amarillo
local lock_button = create_power_button(beautiful.icon_Lock, beautiful.color_Lock, "i3lock") -- Rosado
local logout_button = create_power_button(beautiful.icon_Logout, beautiful.color_Logout, "pkill -KILL -u $USER") -- Verde


add_pb_hover(poweroff_button, beautiful.color_Poweroff, beautiful.color_hover_Poweroff)
add_pb_hover(reboot_button, beautiful.color_Reboot, beautiful.color_hover_Reboot)
add_pb_hover(lock_button, beautiful.color_Lock, beautiful.lock_color_hover)
add_pb_hover(logout_button, beautiful.color_Logout, beautiful.color_hover_Lock)



-- helpers.add_hover_cursor(poweroff_button, "hand2")
helpers.add_hover_cursor(reboot_button, "hand2")
helpers.add_hover_cursor(lock_button, "hand2")
helpers.add_hover_cursor(logout_button, "hand2")

-- Crear el layout de los botones en un contenedor horizontal
local power_buttons = wibox.widget {
    {
        poweroff_button,
        reboot_button,
        lock_button,
        logout_button,
        layout = wibox.layout.fixed.horizontal,
        spacing = 5 -- Espacio entre botones
    },
    margins = 0,
    bottom = dpi(15),
    widget = wibox.container.margin
}

return power_buttons
