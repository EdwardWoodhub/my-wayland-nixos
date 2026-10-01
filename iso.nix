{ pkgs ? import <nixpkgs> {} }:

let
  nixos = import <nixpkgs/nixos> {
    system = "x86_64-linux";
    configuration = { lib, pkgs, ... }: {
      imports = [
        # 1. 引入 NixOS 官方安装介质模块（自动配置 ISO 引导、内嵌 Live 内核与只读 squashfs 根目录）
        <nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix>
        # 2. 复用你的系统配置（桌面环境、Wayland、IBus、软件列表等）
        ./configuration.nix
      ];

      # 3. 覆盖 configuration.nix 中针对物理机/VM 硬盘的冲突配置
      # ISO 会自带独立的 EFI/isolinux 引导，无需向 /dev/sda 写 GRUB
      boot.loader.grub.enable = lib.mkForce false;

      # 确保 ISO 能够通过 live 账户免密登录（方便启动直接进桌面）
      users.users.nack.initialPassword = "nix";
      services.displayManager.autoLogin.enable = lib.mkDefault true;
      services.displayManager.autoLogin.user = lib.mkDefault "nack";

      # Live 镜像中加快压缩构建速度（使用 zstd）
      isoImage.squashfsCompression = "zstd -Xcompression-level 6";
    };
  };
in
nixos.config.system.build.isoImage
