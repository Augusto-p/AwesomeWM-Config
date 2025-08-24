#!/bin/bash
set -euo pipefail
# sudo cat /etc/passwd > /dev/null
folder=$(pwd)
# user=$USER

# ==============================
# Colors & Styling
# ==============================
GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
BLUE="\e[34m"
BOLD="\e[1m"
RESET="\e[0m"
CHECK="${GREEN}✔${RESET}"
CROSS="${RED}✘${RESET}"
ARROW="${BLUE}➜${RESET}"

msg() { echo -e "${ARROW} ${BOLD}$1${RESET}"; }
ok()  { echo -e "${CHECK} $1"; }
err() { echo -e "${CROSS} $1"; }
step() {
    echo -e "\n${YELLOW}==========[ STEP $1 ]==========${RESET}"
}

# ==============================
# STEP 1: Configure keyboard & weather
# ==============================
step "1: Configure keyboard & weather"
read -rp "KEYMAP: " keymap

read -rp "Weather city (default: Francorchamps): " weather_city
weather_city=${weather_city:-Francorchamps}

read -rp "Weather state (default: Liege): " weather_state
weather_state=${weather_state:-Liege}

read -rp "Weather country (default: Belgium): " weather_country
weather_country=${weather_country:-Belgium}

read -rp "Weather language (default: en): " weather_lang
weather_lang=${weather_lang:-en}

read -rp "Weather units (metric/imperial, default: metric): " weather_units
weather_units=${weather_units:-metric}
ok "Weather configured!"

# ==============================
# STEP 2: Install paru
# ==============================
step "2: Install paru"
cd ~
if [ ! -d "paru-bin" ]; then
    git clone https://aur.archlinux.org/paru-bin.git > /dev/null
fi
cd paru-bin
makepkg -si --noconfirm > /dev/null
cd "$folder"
ok "Paru installed!"

# ==============================
# STEP 3: Install base packages with pacman
# ==============================
step "3: Install base packages"
sudo pacman -Sy luarocks networkmanager xorg-server gdm firefox zsh unzip wget > /dev/null
ok "Base packages installed!"
# ==============================
# STEP 4: Change shell to zsh
# ==============================
step "4: Change shell to zsh for user and root"
sudo usermod -s /bin/zsh "$user"
sudo usermod -s /bin/zsh root
ok "Shell changed to zsh!"

# ==============================
# STEP 5: Install Lua modules
# ==============================
step "5: Install Lua modules"
sudo luarocks install --force ldoc > /dev/null
sudo luarocks install --force lsqlite3 0.9.5-1 > /dev/null
sudo luarocks install --force luasocket > /dev/null
sudo luarocks install --force luasec > /dev/null
sudo luarocks install --force lua-cjson > /dev/null
ok "Lua modules installed!"

# ==============================
# STEP 6: Install AUR packages with paru
# ==============================
step "6: Install AUR packages"
paru -Sy awesome-git picom-git kitty todo-bin feh neofetch acpi acpid \
    wireless_tools jq inotify-tools polkit-gnome xdotool xclip maim brightnessctl \
    alsa-utils alsa-tools lm_sensors mpd mpc mpdris2 ncmpcpp playerctl > /dev/null
ok "AUR packages installed!"

# ==============================
# STEP 7: Enable and start services
# ==============================
step "7: Enable and start services"
sudo systemctl enable mpd.service acpid.service NetworkManager wpa_supplicant > /dev/null
sudo systemctl start mpd.service acpid.service NetworkManager wpa_supplicant > /dev/null
ok "Services enabled and started!"

# ==============================
# STEP 8: Copy configuration and scripts
# ==============================
step "8: Copy configuration and scripts"
mkdir -p ~/.local/bin/
cp -r config/* ~/.config/
cp -r bin/* ~/.local/bin/
ok "Configs and scripts copied!"

# ==============================
# STEP 9: Run Desktop Manager
# ==============================
step "9: Run Desktop Manager"
export TODO_PATH="$HOME/.todo"  # Adjust as needed
chmod +x ~/.config/awesome/ui/dock-apps/Desktops_Manager
~/.config/awesome/ui/dock-apps/Desktops_Manager \
    "$HOME/.config/awesome/Awesome.DB" \
    "$HOME/.config/awesome/theme/AwesomeIcons/" \
    "$HOME/.config/awesome/theme/assets/app.svg" \
    "Augusto-p" "AwesomeWM-Config" "Reset"
ok "Desktop Manager launched!"

# ==============================
# STEP 10: Install fonts
# ==============================
step "10: Install fonts"
paru -S ttf-jetbrains-mono-nerd ttf-font-awesome ttf-font-awesome-4 ttf-material-design-icons

# Iconmoon
step "10.1: Install Iconmoon fonts"
sudo mkdir -p /usr/share/fonts/iconmoon
sudo cp -r iconmoon/* /usr/share/fonts/iconmoon/
sudo unzip -o /usr/share/fonts/iconmoon/*.zip -d /usr/share/fonts/iconmoon/ > /dev/null
sudo mv /usr/share/fonts/iconmoon/fonts/*.ttf /usr/share/fonts/
sudo rm -rf /usr/share/fonts/iconmoon
ok "10.1: Iconmoon Fonts installed!"

# Hack Nerd Font
step "10.2: Install Hack Nerd Font fonts"
sudo mkdir -p /usr/share/fonts/hack
sudo wget -q https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/Hack.zip -O /usr/share/fonts/hack/hack.zip
sudo unzip -o /usr/share/fonts/hack/hack.zip -d /usr/share/fonts/hack/ > /dev/null
sudo mv /usr/share/fonts/hack/*.ttf /usr/share/fonts/
sudo rm -rf /usr/share/fonts/hack
ok "10.2: Hack Nerd Font Fonts installed!"
# Iosevka Nerd Fonts
step "10.3: Install Iosevka fonts"
sudo mkdir -p /usr/share/fonts/Iosevka
for font in Iosevka IosevkaTerm IosevkaTermSlab; do
    sudo wget -q "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/${font}.zip" \
        -O "/usr/share/fonts/Iosevka/${font}.zip" > /dev/null
done
for file in /usr/share/fonts/Iosevka/*.zip; do sudo unzip -o "$file" -d /usr/share/fonts/Iosevka/ > /dev/null; done
sudo mv /usr/share/fonts/Iosevka/*.ttf /usr/share/fonts/
sudo rm -rf /usr/share/fonts/Iosevka
ok "10.3: Iosevka Fonts installed!"
ok "Fonts installed!"

# ==============================
# STEP 11: Install ZSH plugins & utilities
# ==============================
step "11: Install ZSH plugins & utilities"
paru -Sy zsh-syntax-highlighting zsh-autosuggestions lsd bat
sudo mkdir -p /usr/share/zsh/plugins/zsh-sudo/
sudo wget -q https://raw.githubusercontent.com/hcgraf/zsh-sudo/refs/heads/master/sudo.plugin.zsh \
    -O /usr/share/zsh/plugins/zsh-sudo/sudo.plugin.zsh > /dev/null
ok "ZSH plugins installed!"

# ==============================
# STEP 12: Configure keymap
# ==============================
step "12: Configure keymap"
sudo localectl set-x11-keymap "$keymap"
ok "Keymap configured!"

# ==============================
# STEP 13: Install Powerlevel10k
# ==============================
step "13: Install Powerlevel10k"
cd $HOME
step "13.1: Install Powerlevel10k User"
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ./powerlevel10k > /dev/null
ok "Powerlevel10k User installed!"
step "13.2: Install Powerlevel10k ROOT"
sudo git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /root/powerlevel10k
ok "Powerlevel10k ROOT installed!"
cd "$folder"
cp user/.p10k.zsh ~/
sudo cp root/.p10k.zsh /root/.
ok "Powerlevel10k installed!"

# ==============================
# STEP 14: Profile and ZSH files
# ==============================
step "14: Configure profile and ZSH"
cp user/.profile ~/
cp user/.Xresources ~/
cp user/.zshrc ~/
sudo ln -sf "/home/$user/.zshrc" /root/.zshrc
ok "Profile and ZSH configured!"

# ==============================
# STEP 15: Configure weather
# ==============================
step "15: Configure weather for AwesomeWM"
{
    echo "weather_city = \"${weather_city,,}\""
    echo "weather_state = \"${weather_state,,}\""
    echo "weather_country = \"${weather_country,,}\""
    echo "weather_lang = \"${weather_lang,,}\""
    echo "weather_units = \"${weather_units,,}\""
} >> ~/.config/awesome/rc.lua
ok "Weather configured!"

# ==============================
# STEP 16: Enable and start GDM
# ==============================
step "16: Enable and start gdm.service"
sudo systemctl enable gdm.service > /dev/null
sudo systemctl start gdm.service > /dev/null
ok "GDM started!"

msg "🎉 All steps completed successfully!"