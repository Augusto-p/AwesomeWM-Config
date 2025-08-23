#!/bin/bash
# Quiet installer with steps, spinner+progress bar, and strict error handling

set -euo pipefail

# =======================
# UI / Progress helpers
# =======================
TOTAL_STEPS=18
CURRENT_STEP=0

step() {
  ((CURRENT_STEP++))
  echo -e "\n[${CURRENT_STEP}/${TOTAL_STEPS}] ➜ $1..."
}

ok() { echo "    ✔️ $1"; }

# Draws a fake progress bar while PID is running, then waits and checks exit code
progress_wait() {
  local pid="$1"
  local width=28
  local i=0
  local spin='|/-\'
  local s=0

  while kill -0 "$pid" 2>/dev/null; do
    i=$(( (i + 1) % (width + 1) ))
    s=$(( (s + 1) % 4 ))
    printf "\r    [%c] [%-*s]" "${spin:$s:1}" "$width" "$(printf "%${i}s" | tr ' ' '#')"
    sleep 0.1
  done

  # Ensure we catch the exit code
  wait "$pid"
  local rc=$?
  if [[ $rc -ne 0 ]]; then
    printf "\r    [x] %-*s\n" "$width" ""
    echo "    ❌ Failed (exit $rc)"
    exit "$rc"
  fi
  printf "\r    [✓] [%-*s]\n" "$width" "$(printf "%${width}s" | tr ' ' '#')"
}

# Run a command silently in background and show progress bar until it ends
run_q() {
  # Usage: run_q "desc" "command..."
  step "$1"
  bash -c "$2" > /dev/null 2>&1 &
  local pid=$!
  progress_wait "$pid"
  ok "$1 completed"
}

# =======================
# Pre-flight
# =======================

folder=$(pwd)
user="$USER"

# Ask for inputs (no logs)
read -rp "KEYMAP: " keymap
read -rp "Enter your weather city (default: Francorchamps): " weather_city;   weather_city=${weather_city:-Francorchamps}
read -rp "Enter your weather state (default: Liege): " weather_state;         weather_state=${weather_state:-Liege}
read -rp "Enter your weather country (default: Belgium): " weather_country;   weather_country=${weather_country:-Belgium}
read -rp "Enter your weather language (default: en): " weather_lang;          weather_lang=${weather_lang:-en}
read -rp "Enter your weather units (metric/imperial, default: metric): " weather_units; weather_units=${weather_units:-metric}

# Cache sudo credentials and keep them alive (quiet)
step "Validating sudo and starting keep-alive"
sudo -v
( while true; do sleep 60; sudo -n true || exit; done ) & SUDO_KEEPALIVE_PID=$!
trap '[[ -n "${SUDO_KEEPALIVE_PID:-}" ]] && kill "$SUDO_KEEPALIVE_PID" 2>/dev/null || true' EXIT
ok "Sudo session active"

# Ensure target dirs exist (avoid copy failures)
mkdir -p "$HOME/.local/bin" "$HOME/.config"

# =======================
# System base & keyring
# =======================
run_q "System update and keyring refresh" \
  "sudo pacman -Sy --noconfirm archlinux-keyring && sudo pacman -Syu --noconfirm"

run_q "Installing base tools (git, base-devel, etc.)" \
  "sudo pacman -S --needed --noconfirm base-devel git luarocks networkmanager xorg-server gdm firefox zsh unzip wget"

# =======================
# Install paru (AUR helper)
# =======================
step "Installing paru (AUR helper)"
if [[ ! -d "$HOME/paru-bin" ]]; then
  bash -c "git clone https://aur.archlinux.org/paru-bin.git \"$HOME/paru-bin\"" > /dev/null 2>&1 &
  progress_wait $!
fi
bash -c "cd \"$HOME/paru-bin\" && makepkg -si --noconfirm" > /dev/null 2>&1 &
progress_wait $!
ok "Paru installed"

# =======================
# Packages via pacman/paru
# =======================
run_q "Installing extra packages with paru" \
  "paru -S --noconfirm awesome-git picom-git kitty todo-bin feh neofetch acpi acpid wireless_tools jq inotify-tools polkit-gnome xdotool xclip maim brightnessctl alsa-utils alsa-tools lm_sensors mpd mpc mpdris2 ncmpcpp playerctl"

# =======================
# Shell setup
# =======================
run_q "Switching default shell to zsh (user & root)" \
  "sudo usermod -s /bin/zsh \"$user\" && sudo usermod -s /bin/zsh root"

# =======================
# Lua modules (quiet)
# =======================
step "Installing Lua modules"
for mod in "ldoc" "lsqlite3 0.9.5-1" "luasocket" "luasec" "lua-cjson"; do
  bash -c "sudo luarocks install --force $mod" > /dev/null 2>&1 &
  progress_wait $!
done
ok "Lua modules installed"

# =======================
# Services
# =======================
run_q "Enabling and starting services" \
  "sudo systemctl enable mpd.service acpid.service NetworkManager wpa_supplicant && sudo systemctl start mpd.service acpid.service NetworkManager wpa_supplicant"

# =======================
# Copy configs & scripts
# =======================
run_q "Copying configuration and scripts" \
  "cp -r config/* \"$HOME/.config/\" && cp -r bin/* \"$HOME/.local/bin/\""

# =======================
# Fonts
# =======================
run_q "Installing font packages (paru)" \
  "paru -S --noconfirm ttf-jetbrains-mono-nerd ttf-font-awesome ttf-font-awesome-4 ttf-material-design-icons"

# Icomoon (optional, only if folder exists)
step "Installing Icomoon fonts (if present)"
if compgen -G "iconmoon/*" > /dev/null; then
  sudo mkdir -p /usr/share/fonts/iconmoon
  sudo cp -r iconmoon/* /usr/share/fonts/iconmoon/ > /dev/null 2>&1 || true
  # unzip any zips if they exist
  shopt -s nullglob
  for z in /usr/share/fonts/iconmoon/*.zip; do
    sudo unzip -o "$z" -d /usr/share/fonts/iconmoon/ > /dev/null 2>&1 || true
  done
  # move TTFs up one level if present
  if compgen -G "/usr/share/fonts/iconmoon/fonts/*.ttf" > /dev/null; then
    sudo mv /usr/share/fonts/iconmoon/fonts/*.ttf /usr/share/fonts/ > /dev/null 2>&1 || true
  fi
  sudo rm -rf /usr/share/fonts/iconmoon > /dev/null 2>&1 || true
fi
ok "Icomoon step done"

# Hack Nerd Font
run_q "Installing Hack Nerd Font" \
  "sudo mkdir -p /usr/share/fonts/hack && sudo wget -q https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/Hack.zip -O /usr/share/fonts/hack/hack.zip && sudo unzip -o /usr/share/fonts/hack/hack.zip -d /usr/share/fonts/hack/ && sudo mv /usr/share/fonts/hack/*.ttf /usr/share/fonts/ && sudo rm -rf /usr/share/fonts/hack"

# Iosevka Nerd Fonts (3 variants)
run_q "Installing Iosevka Nerd Fonts (Iosevka, Term, TermSlab)" \
  "sudo mkdir -p /usr/share/fonts/Iosevka && for font in Iosevka IosevkaTerm IosevkaTermSlab; do sudo wget -q \"https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/${font}.zip\" -O \"/usr/share/fonts/Iosevka/${font}.zip\"; done && for f in /usr/share/fonts/Iosevka/*.zip; do sudo unzip -o \"\$f\" -d /usr/share/fonts/Iosevka/ > /dev/null 2>&1; done && sudo mv /usr/share/fonts/Iosevka/*.ttf /usr/share/fonts/ && sudo rm -rf /usr/share/fonts/Iosevka"

# =======================
# ZSH plugins & extras
# =======================
run_q "Installing ZSH plugins (syntax highlighting, autosuggestions, lsd, bat)" \
  "paru -S --noconfirm zsh-syntax-highlighting zsh-autosuggestions lsd bat"

run_q "Installing zsh-sudo plugin" \
  "sudo mkdir -p /usr/share/zsh/plugins/zsh-sudo && sudo wget -q https://raw.githubusercontent.com/hcgraf/zsh-sudo/refs/heads/master/sudo.plugin.zsh -O /usr/share/zsh/plugins/zsh-sudo/sudo.plugin.zsh"

# =======================
# Keymap
# =======================
run_q "Configuring X11 keymap" \
  "sudo localectl set-x11-keymap \"$keymap\""

# =======================
# Powerlevel10k
# =======================
step "Installing Powerlevel10k"
bash -c "git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \"$HOME/powerlevel10k\"" > /dev/null 2>&1 || true
bash -c "sudo git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /root/powerlevel10k" > /dev/null 2>&1 || true
cp -f user/.p10k.zsh "$HOME"/ > /dev/null 2>&1 || true
sudo cp -f root/.p10k.zsh /root/. > /dev/null 2>&1 || true
ok "Powerlevel10k installed"

# =======================
# Profile & ZSH files
# =======================
run_q "Copying profile and ZSH configs" \
  "cp -f user/.profile \"$HOME\"/ && cp -f user/.Xresources \"$HOME\"/ && cp -f user/.zshrc \"$HOME\"/ && sudo ln -sf \"/home/$user/.zshrc\" /root/.zshrc"

# =======================
# Weather config (append)
# =======================
step "Writing weather settings to AwesomeWM rc.lua"
{
  echo "weather_city = \"${weather_city,,}\""
  echo "weather_state = \"${weather_state,,}\""
  echo "weather_country = \"${weather_country,,}\""
  echo "weather_lang = \"${weather_lang,,}\""
  echo "weather_units = \"${weather_units,,}\""
} >> "$HOME/.config/awesome/rc.lua"
ok "Weather configured"

# =======================
# GDM
# =======================
run_q "Enabling and starting GDM" \
  "sudo systemctl enable gdm.service && sudo systemctl start gdm.service"

echo -e "\n✅ All done!"
