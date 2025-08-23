#!/bin/bash
set -euo pipefail  # Exit on error, unset variables, or failed pipes

# =======================
# Configuration
# =======================
TOTAL_STEPS=15     # Total number of steps
CURRENT_STEP=0     # Counter for completed steps

# -----------------------
# Functions
# -----------------------

# Display progress step
step() {
    ((CURRENT_STEP++))
    local msg="$1"
    echo -e "\n[${CURRENT_STEP}/${TOTAL_STEPS}] ➜ $msg..."
}

# Mark step as completed
success() {
    echo "    ✔️ $1 completed"
}

# Spinner for long-running commands
spinner() {
    local pid=$!
    local spin='|/-\'
    local i=0
    while kill -0 $pid 2>/dev/null; do
        i=$(( (i+1) %4 ))
        printf "\r    [%c] " "${spin:$i:1}"
        sleep 0.1
    done
    printf "\r    ✔️ Done\n"
}

# =======================
# Start Script
# =======================
folder=$(pwd)
user=$USER

# -----------------------
# Ask for user input
# -----------------------
read -rp "KEYMAP: " keymap

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

# -----------------------
# Steps with progress
# -----------------------

# Install paru
step "Installing paru (AUR helper)"
cd ~
if [ ! -d "paru-bin" ]; then
    git clone https://aur.archlinux.org/paru-bin.git > /dev/null 2>&1 &
    spinner
fi
cd paru-bin
(makepkg -si --noconfirm > /dev/null 2>&1) &
spinner
cd "$folder"
success "Paru installed"

# Install base packages with pacman
step "Installing base packages with pacman"
(sudo pacman -Sy --noconfirm luarocks networkmanager xorg-server gdm firefox zsh unzip wget > /dev/null 2>&1) &
spinner
success "Base packages installed"

# Change shell to zsh
step "Changing default shell to zsh"
sudo usermod -s /bin/zsh "$user"
sudo usermod -s /bin/zsh root
success "Shell changed to zsh"

# Install Lua modules
step "Installing Lua modules"
for mod in ldoc "lsqlite3 0.9.5-1" luasocket luasec lua-cjson; do
    (sudo luarocks install --force $mod > /dev/null 2>&1) &
    spinner
done
success "Lua modules installed"

# Install packages with paru
step "Installing extra packages with paru"
(paru -Sy --noconfirm awesome-git picom-git kitty todo-bin feh neofetch acpi acpid \
    wireless_tools jq inotify-tools polkit-gnome xdotool xclip maim brightnessctl \
    alsa-utils alsa-tools lm_sensors mpd mpc mpdris2 ncmpcpp playerctl > /dev/null 2>&1) &
spinner
success "Extra packages installed"

# Enable and start services
step "Enabling and starting services"
sudo systemctl enable mpd.service acpid.service NetworkManager wpa_supplicant > /dev/null 2>&1
sudo systemctl start mpd.service acpid.service NetworkManager wpa_supplicant > /dev/null 2>&1
success "Services enabled and started"

# Copy configuration
step "Copying configuration files"
mkdir -p ~/.local/bin/
cp -r config/* ~/.config/
cp -r bin/* ~/.local/bin/
success "Configuration copied"

# Install fonts
step "Installing fonts"
(paru -S --noconfirm ttf-jetbrains-mono-nerd ttf-font-awesome ttf-font-awesome-4 ttf-material-design-icons > /dev/null 2>&1) &
spinner
# Icomoon fonts
sudo mkdir -p /usr/share/fonts/iconmoon
sudo cp -r iconmoon/* /usr/share/fonts/iconmoon/
sudo unzip -o /usr/share/fonts/iconmoon/*.zip -d /usr/share/fonts/iconmoon/ > /dev/null 2>&1
sudo mv /usr/share/fonts/iconmoon/fonts/*.ttf /usr/share/fonts/
sudo rm -rf /usr/share/fonts/iconmoon
success "Fonts installed"

# ZSH plugins
step "Installing ZSH plugins"
(paru -Sy --noconfirm zsh-syntax-highlighting zsh-autosuggestions lsd bat > /dev/null 2>&1) &
spinner
sudo mkdir -p /usr/share/zsh/plugins/zsh-sudo/
sudo wget -q https://raw.githubusercontent.com/hcgraf/zsh-sudo/refs/heads/master/sudo.plugin.zsh \
    -O /usr/share/zsh/plugins/zsh-sudo/sudo.plugin.zsh
success "ZSH plugins installed"

# Configure keymap
step "Configuring keymap"
sudo localectl set-x11-keymap "$keymap"
success "Keymap configured"

# Powerlevel10k
step "Installing Powerlevel10k theme"
cd $HOME
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ./powerlevel10k > /dev/null 2>&1 || true
sudo git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /root/powerlevel10k > /dev/null 2>&1 || true
cd $folder
cp user/.p10k.zsh ~/
sudo cp root/.p10k.zsh /root/.
success "Powerlevel10k installed"

# Profile and ZSH files
step "Copying profile and ZSH config"
cp user/.profile ~/
cp user/.Xresources ~/
cp user/.zshrc ~/
sudo ln -sf "/home/$user/.zshrc" /root/.zshrc
success "Profile and ZSH config copied"

# Weather configuration
step "Configuring weather"
{
    echo "weather_city = \"${weather_city,,}\""
    echo "weather_state = \"${weather_state,,}\""
    echo "weather_country = \"${weather_country,,}\""
    echo "weather_lang = \"${weather_lang,,}\""
    echo "weather_units = \"${weather_units,,}\""
} >> ~/.config/awesome/rc.lua
success "Weather configured"

# Enable GDM
step "Enabling GDM"
sudo systemctl enable gdm.service > /dev/null 2>&1
sudo systemctl start gdm.service > /dev/null 2>&1
success "GDM enabled"

# =======================
# Done
# =======================
echo -e "\n✅ Script finished successfully!"
