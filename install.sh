#!/bin/bash
# Script de instalación con barra de progreso y sin logs detallados

# Manejo de errores
set -euo pipefail

# --- Funciones de progreso ---
# Define el número total de pasos para la barra de progreso
TOTAL_STEPS=15
CURRENT_STEP=0

# Función para actualizar la barra de progreso
function update_progress() {
    local step_name=$1
    CURRENT_STEP=$((CURRENT_STEP + 1))
    local bar_length=40
    local filled_chars=$(( (CURRENT_STEP * bar_length) / TOTAL_STEPS ))
    local empty_chars=$(( bar_length - filled_chars ))
    local filled_bar=$(printf '█%.0s' $(seq 1 $filled_chars))
    local empty_bar=$(printf '%.0s' $(seq 1 $empty_chars))
    local percentage=$(( (CURRENT_STEP * 100) / TOTAL_STEPS ))

    # Mueve el cursor al inicio y muestra el progreso
    echo -e "\e[1m[${filled_bar}${empty_bar}] ${percentage}% - Paso ${CURRENT_STEP}/${TOTAL_STEPS}: ${step_name}\e[0m"
}

# --- Captura de entrada del usuario ---
echo "--- Configuración inicial ---"
# Redirecciona los logs de los comandos que siguen a /dev/null
# para que no se muestren en la consola.
read -rp "KEYMAP: " keymap
read -rp "Introduce la ciudad para el clima (por defecto: Francorchamps): " weather_city
weather_city=${weather_city:-Francorchamps}
read -rp "Introduce el estado/provincia (por defecto: Liege): " weather_state
weather_state=${weather_state:-Liege}
read -rp "Introduce el país (por defecto: Belgium): " weather_country
weather_country=${weather_country:-Belgium}
read -rp "Introduce el idioma (por defecto: en): " weather_lang
weather_lang=${weather_lang:-en}
read -rp "Introduce las unidades (metric/imperial, por defecto: metric): " weather_units
weather_units=${weather_units:-metric}

# --- Variables de entorno ---
folder=$(pwd)
user=$USER

# --- Pasos de instalación ---
update_progress "Instalando paru..."
cd ~ >/dev/null 2>&1
if [ ! -d "paru-bin" ]; then
    git clone https://aur.archlinux.org/paru-bin.git >/dev/null 2>&1
fi
cd paru-bin >/dev/null 2>&1
makepkg -si --noconfirm >/dev/null 2>&1
cd "$folder" >/dev/null 2>&1

update_progress "Instalando paquetes con pacman..."
sudo pacman -Sy --noconfirm luarocks networkmanager xorg-server gdm firefox zsh unzip wget >/dev/null 2>&1

update_progress "Cambiando shell a zsh..."
sudo usermod -s /bin/zsh "$user" >/dev/null 2>&1
sudo usermod -s /bin/zsh root >/dev/null 2>&1

update_progress "Instalando módulos de Lua..."
sudo luarocks install --force ldoc >/dev/null 2>&1
sudo luarocks install --force lsqlite3 0.9.5-1 >/dev/null 2>&1
sudo luarocks install --force luasocket >/dev/null 2>&1
sudo luarocks install --force luasec >/dev/null 2>&1
sudo luarocks install --force lua-cjson >/dev/null 2>&1

update_progress "Instalando paquetes con paru..."
paru -Sy --noconfirm awesome-git picom-git kitty todo-bin feh neofetch acpi acpid \
    wireless_tools jq inotify-tools polkit-gnome xdotool xclip maim brightnessctl \
    alsa-utils alsa-tools lm_sensors mpd mpc mpdris2 ncmpcpp playerctl >/dev/null 2>&1

update_progress "Habilitando y arrancando servicios..."
sudo systemctl enable mpd.service acpid.service NetworkManager wpa_supplicant >/dev/null 2>&1
sudo systemctl start mpd.service acpid.service NetworkManager wpa_supplicant >/dev/null 2>&1

update_progress "Copiando configuración y scripts..."
mkdir -p ~/.local/bin/ >/dev/null 2>&1
cp -r config/* ~/.config/ >/dev/null 2>&1
cp -r bin/* ~/.local/bin/ >/dev/null 2>&1

update_progress "Ejecutando el gestor de escritorio..."
export TODO_PATH="$HOME/.todo"
chmod +x ~/.config/awesome/ui/dock-apps/Desktops_Manager >/dev/null 2>&1
~/.config/awesome/ui/dock-apps/Desktops_Manager \
    "$HOME/.config/awesome/Awesome.DB" \
    "$HOME/.config/awesome/theme/AwesomeIcons/" \
    "$HOME/.config/awesome/theme/assets/app.svg" \
    "Augusto-p" "AwesomeWM-Config" "Reset" >/dev/null 2>&1

update_progress "Instalando fuentes..."
paru -S --noconfirm ttf-jetbrains-mono-nerd ttf-font-awesome ttf-font-awesome-4 ttf-material-design-icons >/dev/null 2>&1

update_progress "Descargando e instalando Iconmoon..."
sudo mkdir -p /usr/share/fonts/iconmoon >/dev/null 2>&1
sudo cp -r iconmoon/* /usr/share/fonts/iconmoon/ >/dev/null 2>&1
sudo unzip /usr/share/fonts/iconmoon/*.zip -d /usr/share/fonts/iconmoon/ >/dev/null 2>&1
sudo mv /usr/share/fonts/iconmoon/fonts/*.ttf /usr/share/fonts/ >/dev/null 2>&1
sudo rm -rf /usr/share/fonts/iconmoon >/dev/null 2>&1

update_progress "Descargando e instalando Hack Nerd Font..."
sudo mkdir -p /usr/share/fonts/hack >/dev/null 2>&1
sudo wget -q https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/Hack.zip -O /usr/share/fonts/hack/hack.zip >/dev/null 2>&1
sudo unzip -o /usr/share/fonts/hack/hack.zip -d /usr/share/fonts/hack/ >/dev/null 2>&1
sudo mv /usr/share/fonts/hack/*.ttf /usr/share/fonts/ >/dev/null 2>&1
sudo rm -rf /usr/share/fonts/hack >/dev/null 2>&1

update_progress "Descargando e instalando Iosevka Nerd Fonts..."
sudo mkdir -p /usr/share/fonts/Iosevka >/dev/null 2>&1
for font in Iosevka IosevkaTerm IosevkaTermSlab; do
    sudo wget -q "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/${font}.zip" -O "/usr/share/fonts/Iosevka/${font}.zip" >/dev/null 2>&1
done
for file in /usr/share/fonts/Iosevka/*.zip; do sudo unzip -o "$file" -d /usr/share/fonts/Iosevka/ >/dev/null 2>&1; done
sudo mv /usr/share/fonts/Iosevka/*.ttf /usr/share/fonts/ >/dev/null 2>&1
sudo rm -rf /usr/share/fonts/Iosevka >/dev/null 2>&1

update_progress "Configurando plugins y utilidades de ZSH..."
paru -Sy --noconfirm zsh-syntax-highlighting zsh-autosuggestions lsd bat >/dev/null 2>&1
sudo mkdir -p /usr/share/zsh/plugins/zsh-sudo/ >/dev/null 2>&1
sudo wget -q https://raw.githubusercontent.com/hcgraf/zsh-sudo/refs/heads/master/sudo.plugin.zsh \
    -O /usr/share/zsh/plugins/zsh-sudo/sudo.plugin.zsh >/dev/null 2>&1

update_progress "Configurando keymap..."
sudo localectl set-x11-keymap "$keymap" >/dev/null 2>&1

update_progress "Configurando Powerlevel10k..."
cd $HOME >/dev/null 2>&1
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ./powerlevel10k >/dev/null 2>&1
sudo git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /root/powerlevel10k >/dev/null 2>&1
cd $folder >/dev/null 2>&1
cp user/.p10k.zsh ~/ >/dev/null 2>&1
sudo cp root/.p10k.zsh /root/. >/dev/null 2>&1

update_progress "Copiando archivos de perfil y ZSH..."
cp user/.profile ~/ >/dev/null 2>&1
cp user/.Xresources ~/ >/dev/null 2>&1
cp user/.zshrc ~/ >/dev/null 2>&1
sudo ln -sf "/home/$user/.zshrc" /root/.zshrc >/dev/null 2>&1

update_progress "Configurando el clima..."
echo "weather_city = \"${weather_city,,}\"" >> ~/.config/awesome/rc.lua
echo "weather_state = \"${weather_state,,}\"" >> ~/.config/awesome/rc.lua
echo "weather_country = \"${weather_country,,}\"" >> ~/.config/awesome/rc.lua
echo "weather_lang = \"${weather_lang,,}\"" >> ~/.config/awesome/rc.lua
echo "weather_units = \"${weather_units,,}\"" >> ~/.config/awesome/rc.lua

update_progress "Habilitando y arrancando gdm.service..."
sudo systemctl enable gdm.service >/dev/null 2>&1
sudo systemctl start gdm.service >/dev/null 2>&1

echo "-------------------------------------"
echo "¡Instalación completada con éxito!"
echo "-------------------------------------"
