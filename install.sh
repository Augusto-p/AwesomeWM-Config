#!/bin/bash
set -euo pipefail  # Improved error handling
sudo cat /etc/passwd > /dev/null

folder=$(pwd)
user=$USER

# Read keymap correctly
read -rp "KEYMAP: " keymap

# Read weather configuration with defaults
read -rp "Enter your weather city (default: Francorchamps): " weather_city
weather_city=${weather_city:-Francorchamps}

read -rp "Enter your weather state (default: Liege): " weather_state
weather_state=${weather_state:-Liege}

read -rp "Enter your weather country (default: Belgium): " weather_country
weather_country=${weather_country:-Belgium}

read -rp "Enter your weather language (default: en): " weather_lang
weather_lang=${weather_lang:-en}

read -rp "Enter your weather units (metric/imperial, default: metric): " weather_units
weather_units=${weather_units:-metric}

# =======================
# Install paru
# =======================
cd ~
if [ ! -d "paru-bin" ]; then
    git clone https://aur.archlinux.org/paru-bin.git
fi
cd paru-bin
makepkg -si --noconfirm
cd "$folder"

# =======================
# Install packages with pacman
# =======================
sudo pacman -Sy --noconfirm luarocks networkmanager xorg-server gdm firefox zsh unzip wget

# =======================
# Change shell to zsh for user and root
# =======================
sudo usermod -s /bin/zsh "$user"
sudo usermod -s /bin/zsh root

# =======================
# Install Lua modules
# =======================
sudo luarocks install --force ldoc
sudo luarocks install --force lsqlite3 0.9.5-1
sudo luarocks install --force luasocket
sudo luarocks install --force luasec
sudo luarocks install --force lua-cjson

# =======================
# Install packages with paru
# =======================
paru -Sy --noconfirm awesome-git picom-git kitty todo-bin feh neofetch acpi acpid \
    wireless_tools jq inotify-tools polkit-gnome xdotool xclip maim brightnessctl \
    alsa-utils alsa-tools lm_sensors mpd mpc mpdris2 ncmpcpp playerctl

# =======================
# Enable and start services
# =======================
sudo systemctl enable mpd.service acpid.service NetworkManager wpa_supplicant
sudo systemctl start mpd.service acpid.service NetworkManager wpa_supplicant

# =======================
# Copy configuration and scripts
# =======================
mkdir -p ~/.local/bin/
cp -r config/* ~/.config/
cp -r bin/* ~/.local/bin/

# Run desktop manager
export TODO_PATH="$HOME/.todo"  # Adjust as needed
chmod +x ~/.config/awesome/ui/dock-apps/Desktops_Manager
~/.config/awesome/ui/dock-apps/Desktops_Manager \
    "$HOME/.config/awesome/Awesome.DB" \
    "$HOME/.config/awesome/theme/AwesomeIcons/" \
    "$HOME/.config/awesome/theme/assets/app.svg" \
    "Augusto-p" "AwesomeWM-Config" "Reset"

# =======================
# Install fonts
# =======================
paru -S --noconfirm ttf-jetbrains-mono-nerd ttf-font-awesome ttf-font-awesome-4 ttf-material-design-icons

# Iconmoon
sudo mkdir -p /usr/share/fonts/iconmoon
sudo cp -r iconmoon/* /usr/share/fonts/iconmoon/
sudo unzip /usr/share/fonts/iconmoon/*.zip -d /usr/share/fonts/iconmoon/
sudo mv /usr/share/fonts/iconmoon/fonts/*.ttf /usr/share/fonts/
sudo rm -rf /usr/share/fonts/iconmoon

# Hack Nerd Font
sudo mkdir -p /usr/share/fonts/hack
sudo wget -q https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/Hack.zip -O /usr/share/fonts/hack/hack.zip
sudo unzip /usr/share/fonts/hack/hack.zip -d /usr/share/fonts/hack/
sudo mv /usr/share/fonts/hack/*.ttf /usr/share/fonts/
sudo rm -rf /usr/share/fonts/hack

# Iosevka Nerd Fonts
sudo mkdir -p /usr/share/fonts/Iosevka
for font in Iosevka IosevkaTerm IosevkaTermSlab; do
    sudo wget -q "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/${font}.zip" \
        -O "/usr/share/fonts/Iosevka/${font}.zip"
done
for file in /usr/share/fonts/Iosevka/*.zip; do sudo unzip "$file" -d /usr/share/fonts/Iosevka/; done
sudo mv /usr/share/fonts/Iosevka/*.ttf /usr/share/fonts/
sudo rm -rf /usr/share/fonts/Iosevka

# =======================
# ZSH plugins and utilities
# =======================
paru -Sy --noconfirm zsh-syntax-highlighting zsh-autosuggestions lsd bat
sudo mkdir -p /usr/share/zsh/plugins/zsh-sudo/
sudo wget -q https://raw.githubusercontent.com/hcgraf/zsh-sudo/refs/heads/master/sudo.plugin.zsh \
    -O /usr/share/zsh/plugins/zsh-sudo/sudo.plugin.zsh

# =======================
# Configure keymap
# =======================
sudo localectl set-x11-keymap "$keymap"

# =======================
# Powerlevel10k
# =======================
cp -r user/powerlevel10k ~/.
cp user/.p10k.zsh ~/
sudo cp -r root/powerlevel10k /root/.
sudo cp user/.p10k.zsh /root/.

# =======================
# Profile and ZSH files
# =======================
cp user/.profile ~/
cp user/.Xresources ~/
cp user/.zshrc ~/
sudo ln -sf "/home/$user/.zshrc" /root/.zshrc

# =======================
# Configure weather
# =======================
echo "weather_city = \"${weather_city,,}\"" >> ~/.config/awesome/rc.lua
echo "weather_state = \"${weather_state,,}\"" >> ~/.config/awesome/rc.lua
echo "weather_country = \"${weather_country,,}\"" >> ~/.config/awesome/rc.lua
echo "weather_lang = \"${weather_lang,,}\"" >> ~/.config/awesome/rc.lua
echo "weather_units = \"${weather_units,,}\"" >> ~/.config/awesome/rc.lua

# =======================
# Enable and start gdm.service
# =======================
sudo systemctl enable gdm.service
sudo systemctl start gdm.service