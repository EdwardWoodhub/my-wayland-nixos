# 构建工具

不再使用 BlueBuild Template &nbsp;

[![bluebuild build badge](https://github.com/blue-build/template/actions/workflows/build.yml/badge.svg)](https://github.com/blue-build/template/actions/workflows/build.yml)

转而使用 bootc



# 构建产物

(1) OCI镜像


# 推送方式

由本地客户端主导的 Registry-to-Registry 流式直转，不依赖本地 Docker 存储池。skopeo copy 运行在 Actions Runner 节点上作为流式代理，它只读取远程 GHCR 的 Manifest 和各个 Layer Blob，将其流式复制并组装推送到目标 ACR，完全不依赖本地 Docker 守护进程，也不会在 Runner 磁盘上完整重建/解包 Docker 镜像。
