
# AwesomeWM-Config
<div align="center">
<a href="https://awesomewm.org/">
    <img src="https://awesomewm.org/images/awesome-logo.svg">
    </a>
</div>

<br>

<div align="center">
    <img src="assets/awesome.png" alt="Rice Preview">
</div>

<img alt="AwesomeWM Logo" height="160" align="left" src="assets/pfp.png">

A highly personalized, lightweight, and powerful AwesomeWM configuration tailored for Arch Linux. This setup is designed to deliver a seamless, efficient, and aesthetically pleasing desktop experience, perfect for power users and minimalists alike who want full control over their window manager.
<br>
<br>
<br>

## Overview

This repository contains my custom AwesomeWM configuration files, designed for a clean and efficient workflow on Arch Linux. It includes a tailored setup with a variety of programs, keybindings, and a custom launcher, all optimized for productivity and aesthetics.

### System Setup

| Component   | Software          |
|------------|-------------------|
| **WM**     | AwesomeWM         |
| **OS**     | Arch Linux        |
| **Terminal** | kitty           |
| **Shell**  | zsh               |
| **Editor** | Visual Studio Code|
| **Compositor** | picom         |
| **Launcher** | Custom          |

## Installation

Follow these steps to install and configure the dotfiles. **R.T.F.M** (Read The Fine Manual) for a smooth setup.

### Step 1: Install AwesomeWM Configuration Files

1. **Clone the Repository**:
   ```shell
   git clone https://github.com/Augusto-p/AwesomeWM-Config.git
   cd AwesomeWM-Config
   ```

2. **Make the Installation Script Executable**:
   ```shell
   chmod +x install.sh
   ```

3. **Run the Installation Script**:
   ```shell
   ./install.sh
   ```

### Step 2: Configure Settings

The configuration files are located in `~/.config/awesome`. Customize the following:

- **User Preferences and Default Applications**:
  - Edit the *Default Applications* section in `rc.lua` to set your preferred applications.
  - For weather widgets, create an account on [OpenWeatherMap](https://openweathermap.org), obtain your API key, and set `openweathermap_key` and `openweathermap_city_id` in the configuration.

### Step 3: Log In

Log out of your current desktop session and select **AwesomeWM** from your display manager to start using the configuration.

## Keybindings

The configuration uses the <kbd>Super</kbd> (Windows) key as the primary modifier, along with <kbd>Alt</kbd>, <kbd>Shift</kbd>, and <kbd>Ctrl</kbd>.

### Keyboard Shortcuts

| Keybind                        | Action                                              |
|--------------------------------|-----------------------------------------------------|
| <kbd>Super + Enter</kbd>       | Spawn terminal                                      |
| <kbd>Super + w</kbd>           | Spawn web browser                                   |
| <kbd>Super + x</kbd>           | Spawn color picker                                  |
| <kbd>Super + f</kbd>           | Spawn file manager                                  |
| <kbd>Super + d</kbd>           | Launch applications launcher                        |
| <kbd>Super + Shift + d</kbd>   | Toggle dashboard                                    |
| <kbd>Super + q</kbd>           | Close client                                        |
| <kbd>Super + Ctrl + l</kbd>    | Toggle lock screen                                  |
| <kbd>Super + [1-0]</kbd>       | Switch to workspace (tag)                           |
| <kbd>Super + Shift + [1-0]</kbd> | Move focused client to tag                        |
| <kbd>Super + Space</kbd>       | Select next layout                                  |
| <kbd>Super + s</kbd>           | Set tiling layout                                   |
| <kbd>Super + Shift + s</kbd>   | Set floating layout                                 |
| <kbd>Super + c</kbd>           | Center floating client                              |
| <kbd>Super + [Arrow Keys]</kbd>| Change focus by direction                           |
| <kbd>Super + Shift + f</kbd>   | Toggle fullscreen                                   |
| <kbd>Super + m</kbd>           | Toggle maximize                                     |
| <kbd>Super + n</kbd>           | Minimize                                            |
| <kbd>Ctrl + Shift + n</kbd>    | Restore minimized                                   |
| <kbd>Alt + Tab</kbd>           | Window switcher                                     |

### Mouse Bindings (Desktop)

| Mouse Action         | Action                                     |
|----------------------|--------------------------------------------|
| Left Click           | Dismiss all notifications                  |
| Right Click          | Open app drawer                            |
| Middle Click         | Toggle dashboard                           |
| Scroll Up/Down       | Cycle through tags                         |

For additional keybindings, check `awesome/configuration/keys.lua`.

## Acknowledgements

### Credits
- [ner0z](https://github.com/ner0z)
- [augusto-p](https://github.com/augusto-p)

### Special Thanks
- [ChocolateBread799](https://github.com/ChocolateBread799)
- [JavaCafe01](https://github.com/JavaCafe01)

<!-- ## License

This project is licensed under the [GPL-3.0 License](https://github.com/rxyhn/AwesomeWM-Dotfiles/blob/main/.github/LICENSE). -->

---

### Notes
- Replace placeholder links (e.g., screenshots, license link) with actual links if available.
- If you have a screenshot or demo GIF of your setup, consider adding it under the "Overview" section for visual appeal (e.g., `![Screenshot](path/to/screenshot.png)`).
- Let me know if you want to add more sections, such as troubleshooting tips, dependencies, or a theme customization guide!

