#!/bin/bash

echo "🚀 开始运行自定义注入脚本..."

# ================= 1. 拉取额外插件源码 =================
echo "📦 正在拉取 luci-app-ssr-plus (helloworld) 源码..."
git clone --depth=1 https://github.com/fw876/helloworld.git package/helloworld

# 🚀 物理超度大招：直接删掉 helloworld 里那些依赖 Rust 和极容易报错的组件源码！
# 这样 OpenWrt 的编译引擎就根本扫描不到它们，彻底杜绝连环报错！
echo "🧹 正在物理清除容易报错的 Rust/高耗时组件..."
rm -rf package/helloworld/shadowsocks-rust
rm -rf package/helloworld/shadow-tls
rm -rf package/helloworld/tuic-client
rm -rf package/helloworld/hysteria
rm -rf package/helloworld/trojan
rm -rf package/helloworld/naiveproxy

# ================= 2. 基础个性化设置 =================
# 修改默认 IP 地址
sed -i 's/192.168.1.1/192.168.61.1/g' package/base-files/files/bin/config_generate
echo "✅ 默认 IP 已修改为 192.168.61.1"

# ================= 3. 核心插件与修复选择区 =================
cat >> .config <<EOF

# --- 基础实用工具 ---
CONFIG_PACKAGE_luci-app-autoreboot=y
CONFIG_PACKAGE_luci-app-ddns=y
CONFIG_PACKAGE_luci-app-upnp=y

# --- ⚠️ 科学上网核心 (HomeProxy 暂时屏蔽) ---
# 你的日志明确提示此 2410 分支缺少 HomeProxy 必须的 ucode-mod-digest
# 为了保证这次 MTK 必定编译成功，先把它屏蔽掉，只用 SSR-Plus！
# CONFIG_PACKAGE_luci-app-homeproxy=y

# --- 异地组网 / 虚拟局域网 ---
CONFIG_PACKAGE_luci-app-wireguard=y
CONFIG_PACKAGE_luci-app-zerotier=y

# =======================================================
# 🚀 终极防线：开启官方预编译 Rust，绕过本地地狱编译！
# =======================================================
CONFIG_RUST_USE_PREBUILT_HOST=y

# =======================================================
# 🚀 核心定制：保留极其纯净的 SSR-Plus (按截图1:1定制)
# =======================================================
CONFIG_PACKAGE_luci-app-ssr-plus=y
CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_Shadowsocks_New_Version_Server=y
CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_Shadowsocks_V2ray_Plugin=y
CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_Xray=y
CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_MosDNS=y

# --- 补充：万一底层需要，开启极度省内存的经典 C 语言版 SS ---
CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_Shadowsocks_Libev_Client=y
CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_Shadowsocks_Libev_Server=y
CONFIG_PACKAGE_shadowsocks-libev-ss-local=y
CONFIG_PACKAGE_shadowsocks-libev-ss-redir=y

# --- 软屏蔽其它不必要的协议 ---
# CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_Shadowsocks_Rust_Client is not set
# CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_Shadowsocks_Rust_Server is not set
# CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_Shadowsocks_Simple_Obfs_Plugin is not set
# CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_Trojan is not set
# CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_Tuic_Client is not set
# CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_Shadow_TLS is not set
# CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_Hysteria is not set
# =======================================================

EOF

echo "✅ 插件配置及防报错指令已成功注入 .config！"
