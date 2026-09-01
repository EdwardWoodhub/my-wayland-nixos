{ pkgs ? import <nixpkgs> {}
, configFile ? ./configuration.nix
}:

let
  # 1. 经典模式直接求值 NixOS 系统
  nixos = import <nixpkgs/nixos> {
    configuration = configFile;
    system = "x86_64-linux"; # 如果是 ARM 机器则写 "aarch64-linux"
  };

  toplevel = nixos.system;

  # 2. 官方标准闭包元数据生成器（自动包含所有依赖的哈希与拓扑关系）
  closureInfo = pkgs.closureInfo {
    rootPaths = [ toplevel ];
  };
in
pkgs.dockerTools.buildLayeredImage {
  name = "my-wayland-nixos-vm";
  tag = "latest";

  # 最多切分 100 层，最大化复用基础库和未变动组件
  maxLayers = 100;

  # 3. 将官方生成的 registration 文件直接拷贝到镜像的 /nix-support 目录
  extraCommands = ''
    mkdir -p nix-support
    cp ${closureInfo}/registration nix-support/registration
  '';

  # 4. 将顶层系统闭包及基础命令放入容器
  contents = [
    toplevel
    pkgs.coreutils
    pkgs.bashInteractive
  ];

  config = {
    Env = [ "TARGET_TOPLEVEL=${toplevel}" ];
    Cmd = [ "${pkgs.coreutils}/bin/echo" "${toplevel}" ];
  };
}
