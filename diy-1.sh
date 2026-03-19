#!/bin/bash

echo "🚀 开始运行自定义注入脚本..."

# ================= 1. 拉取额外插件源码 =================
echo "📦 正在拉取 luci-app-ssr-plus 源码..."
# 将 helloworld (包含 ssr-plus) 拉取到 package/helloworld 目录下
git clone --depth=1 https://github.com/fw876/helloworld.git package/helloworld

# ================= 2. 基础个性化设置 =================
# 修改默认 IP 地址
sed -i 's/192.168.1.1/192.168.61.1/g' package/base-files/files/bin/config_generate
echo "✅ 默认 IP 已修改为 192.168.61.1"

# ================= 3. 核心插件与修复选择区 =================
# 将你需要编译进固件的插件保持 =y，不需要的保持 # is not set

cat >> .config <<EOF

# --- 基础实用工具 ---
CONFIG_PACKAGE_luci-app-autoreboot=y
CONFIG_PACKAGE_luci-app-ddns=y
CONFIG_PACKAGE_luci-app-upnp=y
# CONFIG_PACKAGE_luci-app-wol=y
# CONFIG_PACKAGE_luci-app-samba4=y 
# CONFIG_PACKAGE_luci-app-usb-printer=y
# CONFIG_PACKAGE_luci-app-wrtbwmon=y

# --- 科学上网核心 ---
CONFIG_PACKAGE_luci-app-ssr-plus=y
CONFIG_PACKAGE_luci-app-homeproxy=y
# CONFIG_PACKAGE_luci-app-openclash=y
# CONFIG_PACKAGE_luci-app-passwall=y

# --- 异地组网 / 虚拟局域网 ---
CONFIG_PACKAGE_luci-app-wireguard=y
CONFIG_PACKAGE_luci-app-zerotier=y
# CONFIG_PACKAGE_luci-app-tailscale=y

# =======================================================
# 🚀 核心修复：精准阉割 Rust 依赖，拯救 2 核编译机
# =======================================================
# 1. 禁用 SSR-Plus 界面上依赖 Rust 的高耗时可选协议
# CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_Shadowsocks_Rust_Client is not set
# CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_Shadowsocks_Rust_Server is not set
# CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_Shadow_TLS is not set
# CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_Tuic_Client is not set

# 2. 强制卸载底层的 Rust 核心编译库
# CONFIG_PACKAGE_shadowsocks-rust-sslocal is not set
# CONFIG_PACKAGE_shadowsocks-rust-ssserver is not set
# CONFIG_PACKAGE_shadow-tls is not set
# CONFIG_PACKAGE_tuic-client is not set

# 3. 启用传统的 C 语言版本 SS (秒编译，极其省内存，完美替代)
CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_Shadowsocks_Libev_Client=y
CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_Shadowsocks_Libev_Server=y
CONFIG_PACKAGE_shadowsocks-libev-ss-local=y
CONFIG_PACKAGE_shadowsocks-libev-ss-redir=y
CONFIG_PACKAGE_shadowsocks-libev-ss-server=y
# =======================================================

EOF

echo "✅ 插件配置及 Rust 规避指令已成功注入 .config！"
