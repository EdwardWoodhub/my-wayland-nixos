# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, ... }:
##############################Basic#############################
{
  imports = [ 
#   Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

# Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;

# networking.hostName = "nixos"; # Define your hostname.
  networking.hostName = "vmNixWayland"; # Define your hostname.
# networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

# Configure network proxy if necessary
# networking.proxy.default = "http://user:password@proxy:port/";
# networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

# Enable networking
  networking.networkmanager.enable = true;

  nix.settings.substituters = [ "https://mirrors.sjtug.sjtu.edu.cn/nix-channels/store" "https://cache.nixos.org/" ];

##############################Hardware#############################
# Set your time zone.
  time.timeZone = "Asia/Shanghai";

# Select internationalisation properties.
  i18n.supportedLocales = [ "zh_CN.UTF-8/UTF-8" "en_US.UTF-8/UTF-8" ];
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "zh_CN.UTF-8";
    LC_IDENTIFICATION = "zh_CN.UTF-8";
    LC_MEASUREMENT = "zh_CN.UTF-8";
    LC_MONETARY = "zh_CN.UTF-8";
    LC_NAME = "zh_CN.UTF-8";
    LC_NUMERIC = "zh_CN.UTF-8";
    LC_PAPER = "zh_CN.UTF-8";
    LC_TELEPHONE = "zh_CN.UTF-8";
    LC_TIME = "zh_CN.UTF-8";
  };

# 输入法
  i18n.inputMethod = {
#   enabled = "fcitx5";
#   fcitx5.addons = with pkgs; [
#     fcitx5-mozc
#     fcitx5-gtk
#     fcitx5-rime
#     fcitx5-chinese-addons
#   ];

    enable = true;
    type = "ibus";
    ibus.engines = with pkgs.ibus-engines; [
      libpinyin
      rime
    ];
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
#     xdg-desktop-portal-wlr
#     xdg-desktop-portal-lxqt      
      xdg-desktop-portal-gtk
      xdg-desktop-portal
    ];
    config.common.default = [ "wlr" "gtk" ];
  };

  xdg.portal.lxqt.enable = true;
  xdg.portal.wlr.enable = true;

##############################Hardware Services#############################
  virtualisation.vmware.guest.enable = true;
  virtualisation.vmware.guest.headless = false;
# hardware.vbox.enable = true;

# Enable the OpenSSH daemon.
# services.openssh.enable = true;

# Open ports in the firewall.
# networking.firewall.allowedTCPPorts = [ ... ];
# networking.firewall.allowedUDPPorts = [ ... ];
# Or disable the firewall altogether.
# networking.firewall.enable = false;
# 防火墙规则：允许本地代理、服务器端口和 Web UI 访问
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 1080 8080 2017 10801 10802];  # 允许本地代理和 Web UI
#   allowedTCPOut = [ 443 ];          # 允许出站到服务器的 443 端口
  };  


  
# Enable the X11 windowing system.
# You can disable this if you're only using the Wayland session.
  services.xserver.enable = true;

  programs.labwc.enable = true;

# Enable the KDE Plasma Desktop Environment.
# services.displayManager.sddm.enable = true;
# 显示管理器建议使用 SDDM（支持 Wayland）
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };
# services.desktopManager.plasma6.enable = true;
# services.displayManager.defaultSession = "xfce";
  services.displayManager.defaultSession = "labwc";
# services.displayManager.defaultSession = "lxqt-wayland"; # 或在 SDDM 登录界面选择 labwc / LXQt (Wayland)

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

# Configure keymap in X11
  services.xserver.desktopManager = {
    xterm.enable = false;
#   xfce.enable = true;
    lxqt.enable = true;
  };

  environment.sessionVariables = {
    # 强制让 Qt / GTK / Electron 应用优先运行在 Wayland 原生模式下
    NIXOS_OZONE_WL = "1";
    QT_QPA_PLATFORM = "wayland;xcb";
    GDK_BACKEND = "wayland,x11,*";
    SDL_VIDEODRIVER = "wayland";
    CLUTTER_BACKEND = "wayland";

    # 保留原有的输入法变量
    GTK_IM_MODULE   = "ibus";
    QT_IM_MODULE    = "ibus";
    XMODIFIERS      = "@im=ibus";
    GLFW_IM_MODULE  = "ibus";
  };

# 字体配置
  fonts = {
    packages = with pkgs; [
      nerd-fonts.fira-code
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
#     noto-fonts-emoji
      noto-fonts-color-emoji
    ];
    fontconfig = {
      antialias = true;
      hinting.enable = true;
      defaultFonts = {
        emoji = [ "Noto Color Emoji" ];
        monospace = [ "FiraCode Nerd Font" ];
        sansSerif = [ "Noto Sans CJK SC" ];
        serif = [ "Noto Serif CJK SC" ];
      };
    };
  };

# Enable CUPS to print documents.
  services.printing.enable = true;

# Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
#   If you want to use JACK applications, uncomment this
#   jack.enable = true;

#   use the example session manager (no others are packaged yet so this is enabled by default,
#   no need to redefine it in your config for now)
#   media-session.enable = true;
  };

# Enable touchpad support (enabled default in most desktopManager).
# services.xserver.libinput.enable = true;

##############################Users#############################
# Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.nack = {
    isNormalUser = true;
    description = "Nack";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      kdePackages.kate
#     thunderbird
      tree
      flatpak
    ];
  };


  
##############################Software#############################
# Allow unfree packages
  nixpkgs.config.allowUnfree = true;

# Install firefox.
  programs.firefox.enable = true;

# List packages installed in system profile. To search, run:
# $ nix search wget
  environment.systemPackages = with pkgs; [
    # 核心组件
    labwc
    lxqt.lxqt-session
    lxqt.lxqt-wayland-session  
    lxqt.lxqt-panel
    lxqt.screengrab   
    lxqt.qterminal  
    lxqt.lxqt-config  
    lxqt.lxqt-themes  
    lxqt.lxqt-policykit  
    lxqt.lxqt-notificationd  
    lxqt.xdg-desktop-portal-lxqt  
    # Wayland 常用外围工具
    wl-clipboard
    grim
    slurp
    waybar       # 可选：如果不用 lxqt-panel
    wlr-randr    # Wayland 显示器设置工具
    kdePackages.discover   
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    curl
#   open-vm-tools
#   open-vm-tools-headless
    xorg.xf86inputvmmouse
    samba
#   libsForQt5.kdenetwork-filesharing
    kdePackages.kdenetwork-filesharing
    fuse
    perl
    mate.pluma
    firefox
    git
#   fcitx5
#   fcitx5-configtool
    ibus
    ibus-with-plugins
    ibus-engines.rime
    ibus-engines.libpinyin
#   neofetch
    fastfetch
    google-chrome
    gedit
    trojan-go
    v2raya
    v2ray
    xray
#   proxychains-ng
    podman
    flameshot
    meld   
    vscode

  ];

# Some programs need SUID wrappers, can be configured further or are
# started in user sessions.
# programs.mtr.enable = true;
# programs.gnupg.agent = {
#   enable = true;
#   enableSSHSupport = true;
# };

##############################Software Services#############################
# List services that you want to enable:
  services.flatpak.enable = true;

  systemd.services.flatpak-repo = {
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.flatpak ];
    script = ''
      flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    '';
  };

  systemd.user.services.flatpak-repo-user = {
    wantedBy = [ "default.target" ]; # 用户登录后启动
    path = [ pkgs.flatpak ];
    script = ''
#     添加用户级 Flathub 源
      flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    '';
  };



# This value determines the NixOS release from which the default
# settings for stateful data, like file locations and database versions
# on your system were taken. It‘s perfectly fine and recommended to leave
# this value at the release version of the first install of this system.
# Before changing this value read the documentation for this option
# (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}
