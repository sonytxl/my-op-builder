#!/bin/bash
#
# OpenClaw 专属定制: 路由器个性化与插件选择脚本
# 使用方法: 
# 1. 需要的插件保持 =y
# 2. 不需要该插件，只需在行首加上 # 即可注释掉
#

echo "🚀 开始运行自定义注入脚本..."

# ================= 1. 基础个性化设置 =================

# 修改默认 IP 地址 (将 192.168.1.1 修改为您想要的 IP，这里以 192.168.50.1 为例)
sed -i 's/192.168.1.1/192.168.50.1/g' package/base-files/files/bin/config_generate
echo "✅ 默认 IP 已修改为 192.168.50.1"

# 修改默认主机名 (可选，默认为 ImmortalWrt)
sed -i 's/ImmortalWrt/XDR6088/g' package/base-files/files/bin/config_generate

# 设置默认主题 (ImmortalWrt 默认通常就是 Argon。这里防重置，再强制设定一次)
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile
echo "✅ 默认主题已设置为 Argon"


# ================= 2. 核心插件选择区 =================
# 说明：取消注释 (#) 的插件将被编译进固件。
# 编译引擎会自动解析它们需要的底层依赖包，无需手动配置。

cat >> .config <<EOF

# --- 基础实用工具 ---
CONFIG_PACKAGE_luci-app-autoreboot=y
CONFIG_PACKAGE_luci-app-ddns=y
CONFIG_PACKAGE_luci-app-upnp=y
CONFIG_PACKAGE_luci-app-wol=y
# 较新的 OpenWrt 中 samba 通常叫 samba4
CONFIG_PACKAGE_luci-app-samba4=y 

# --- 科学上网核心 (⚠️强烈警告：建议只选 1 到 2 个，多选会严重拖慢编译，且端口易冲突) ---
CONFIG_PACKAGE_luci-app-homeproxy=y
# CONFIG_PACKAGE_luci-app-openclash=y
# CONFIG_PACKAGE_luci-app-passwall=y
# CONFIG_PACKAGE_luci-app-ssr-plus=y
# 注：官方源中一般只有 passwall，没有 passwall2。Passwall 已经极其强大，足以覆盖需求。

# --- 异地组网 / 虚拟局域网 ---
# CONFIG_PACKAGE_luci-app-wireguard=y
# CONFIG_PACKAGE_luci-app-zerotier=y
# CONFIG_PACKAGE_luci-app-tailscale=y

# --- UI 主题包 (打勾的会被编译进固件供切换) ---
CONFIG_PACKAGE_luci-theme-argon=y
# CONFIG_PACKAGE_luci-theme-material=y

EOF

echo "✅ 插件配置及依赖指令已成功注入 .config！"
