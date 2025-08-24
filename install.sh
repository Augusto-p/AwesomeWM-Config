#!/bin/bash
set -euo pipefail

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
ok()  { echo -e "   ${CHECK} $1"; }
err() { echo -e "   ${CROSS} $1"; }
step() {
    echo -e "\n${YELLOW}==========[ STEP $1 ]==========${RESET}"
}

# ==============================
# Progress Bar Functions
# ==============================
pacman_progress() {
    sudo pacman "$@" --noconfirm | \
    grep --line-buffered '%' | \
    awk '{
        for(i=1;i<=NF;i++){
            if ($i ~ /%$/) { gsub("%","",$i); p=$i }
        }
        w=30; f=int(p*w/100)
        printf "\r["
        for(i=0;i<f;i++) printf "█"
        for(i=f;i<w;i++) printf " "
        printf "] %d%%", p; fflush()
    }
    END { print "" }'
}

paru_progress() {
    paru "$@" --noconfirm | \
    grep --line-buffered '%' | \
    awk '{
        for(i=1;i<=NF;i++){
            if ($i ~ /%$/) { gsub("%","",$i); p=$i }
        }
        w=30; f=int(p*w/100)
        printf "\r["
        for(i=0;i<f;i++) printf "█"
        for(i=f;i<w;i++) printf " "
        printf "] %d%%", p; fflush()
    }
    END { print "" }'
}

git_progress() {
    git "$@" --progress 2>&1 | \
    grep --line-buffered '%' | \
    awk '{
        for(i=1;i<=NF;i++){
            if ($i ~ /%$/) { gsub("%","",$i); p=$i }
        }
        w=30; f=int(p*w/100)
        printf "\r["
        for(i=0;i<f;i++) printf "█"
        for(i=f;i<w;i++) printf " "
        printf "] %d%%", p; fflush()
    }
    END { print "" }'
}

wget_progress() {
    # URL y destino
    url="$1"
    dest="${2:-.}"  # Si no pasas destino, usa directorio actual

    wget --progress=dot:giga "$url" -P "$dest" 2>&1 | \
    grep --line-buffered "%" | \
    awk '{
        # Buscar porcentaje en la línea
        for(i=1;i<=NF;i++){
            if($i ~ /%/){
                gsub("%","",$i)
                p=$i
            }
        }
        w=30; f=int(p*w/100)
        printf "\r["
        for(i=0;i<f;i++) printf "█"
        for(i=f;i<w;i++) printf " "
        printf "] %d%%", p
        fflush()
    } END { print "" }'
}

unzip_progress() {
    zipfile="$1"
    dest="${2:-.}"  # Destino por defecto: directorio actual

    # Contar archivos dentro del zip
    total_files=$(unzip -l "$zipfile" | grep -E '^[ ]+[0-9]+[ ]+[0-9]{4}-[0-9]{2}-[0-9]{2}' | wc -l)
    current=0

    # Extraer archivo uno por uno mostrando progreso
    unzip -o "$zipfile" -d "$dest" | while read -r line; do
        if [[ "$line" == *inflating* || "$line" == *extracting* ]]; then
            ((current++))
            percent=$((current*100/total_files))
            w=30
            f=$((percent*w/100))
            # dibujar barra
            printf "\r["
            for((i=0;i<f;i++)); do printf "█"; done
            for((i=f;i<w;i++)); do printf " "; done
            printf "] %d%%", percent
        fi
    done
    echo ""
}


# ==============================
# Pre-checks
# ==============================
sudo cat /etc/passwd > /dev/null
folder=$(pwd)
user=$USER

# ==============================
# User Input
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
# Install paru
# ==============================
step "2: Install paru"
cd ~
if [ ! -d "paru-bin" ]; then
    git_progress clone https://aur.archlinux.org/paru-bin.git
fi
cd paru-bin
makepkg -si --noconfirm
cd "$folder"
ok "Paru installed!"

# ==============================
# Install packages with pacman
# ==============================
step "3: Install base packages"
pacman_progress -Sy luarocks networkmanager xorg-server gdm firefox zsh unzip wget
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
sudo luarocks install --force ldoc
sudo luarocks install --force lsqlite3 0.9.5-1
sudo luarocks install --force luasocket
sudo luarocks install --force luasec
sudo luarocks install --force lua-cjson
ok "Lua modules installed!"

# ==============================
# STEP 6: Install AUR packages with paru
# ==============================
step "6: Install AUR packages"
paru_progress -Sy awesome-git picom-git kitty todo-bin feh neofetch acpi acpid \
    wireless_tools jq inotify-tools polkit-gnome xdotool xclip maim brightnessctl \
    alsa-utils alsa-tools lm_sensors mpd mpc mpdris2 ncmpcpp playerctl
ok "AUR packages installed!"

# ==============================
# STEP 7: Enable and start services
# ==============================
step "7: Enable and start services"
sudo systemctl enable mpd.service acpid.service NetworkManager wpa_supplicant
sudo systemctl start mpd.service acpid.service NetworkManager wpa_supplicant
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
paru_progress -S ttf-jetbrains-mono-nerd ttf-font-awesome ttf-font-awesome-4 ttf-material-design-icons

# Iconmoon
sudo mkdir -p /usr/share/fonts/iconmoon
sudo cp -r iconmoon/* /usr/share/fonts/iconmoon/
sudo unzip_progress /usr/share/fonts/iconmoon/*.zip -d /usr/share/fonts/iconmoon/
sudo mv /usr/share/fonts/iconmoon/fonts/*.ttf /usr/share/fonts/
sudo rm -rf /usr/share/fonts/iconmoon

# Hack Nerd Font
sudo mkdir -p /usr/share/fonts/hack
sudo wget_progress -q https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/Hack.zip -O /usr/share/fonts/hack/hack.zip
sudo unzip_progress -o /usr/share/fonts/hack/hack.zip -d /usr/share/fonts/hack/
sudo mv /usr/share/fonts/hack/*.ttf /usr/share/fonts/
sudo rm -rf /usr/share/fonts/hack

# Iosevka Nerd Fonts
sudo mkdir -p /usr/share/fonts/Iosevka
for font in Iosevka IosevkaTerm IosevkaTermSlab; do
    sudo wget_progress -q "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/${font}.zip" \
        -O "/usr/share/fonts/Iosevka/${font}.zip"
done
for file in /usr/share/fonts/Iosevka/*.zip; do sudo unzip_progress -o "$file" -d /usr/share/fonts/Iosevka/; done
sudo mv /usr/share/fonts/Iosevka/*.ttf /usr/share/fonts/
sudo rm -rf /usr/share/fonts/Iosevka
ok "Fonts installed!"

# ==============================
# STEP 11: Install ZSH plugins & utilities
# ==============================
step "11: Install ZSH plugins & utilities"
paru_progress -Sy zsh-syntax-highlighting zsh-autosuggestions lsd bat
sudo mkdir -p /usr/share/zsh/plugins/zsh-sudo/
sudo wget_progress -q https://raw.githubusercontent.com/hcgraf/zsh-sudo/refs/heads/master/sudo.plugin.zsh \
    -O /usr/share/zsh/plugins/zsh-sudo/sudo.plugin.zsh
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
git_progress clone --depth=1 https://github.com/romkatv/powerlevel10k.git ./powerlevel10k
sudo git_progress clone --depth=1 https://github.com/romkatv/powerlevel10k.git /root/powerlevel10k
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
sudo systemctl enable gdm.service
sudo systemctl start gdm.service
ok "GDM started!"

msg "🎉 All steps completed successfully!"
