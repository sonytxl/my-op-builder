#!/bin/bash
echo "🚀 开始执行 MTK 7981 (23.05 分支) 编译前置任务..."

# 1. 修改默认 IP
echo "🔧 正在修改默认 IP 地址..."
sed -i 's/192.168.1.1/192.168.51.1/g' package/base-files/files/bin/config_generate
sed -i 's/192.168.6.1/192.168.51.1/g' package/base-files/files/bin/config_generate

# 2. 修改默认主机名
echo "🏷️ 正在修改默认主机名..."
sed -i 's/ImmortalWrt/EComRouter/g' package/base-files/files/bin/config_generate

# 3. 注入 SSR-Plus 源码
echo "📦 正在拉取 luci-app-ssr-plus 源码..."
git clone --depth=1 https://github.com/fw876/helloworld.git package/helloworld

# 4. 解决冲突：物理清除 helloworld 自带的、与系统官方源冲突的底层核心包
# 这样 SSR Plus 就会乖乖去调用 ImmortalWrt 系统自带的稳定核心了
echo "🧹 正在清理冲突组件..."
rm -rf package/helloworld/xray-core
rm -rf package/helloworld/v2ray-core
rm -rf package/helloworld/sing-box
rm -rf package/helloworld/shadowsocks-rust
rm -rf package/helloworld/shadow-tls
rm -rf package/helloworld/tuic-client
rm -rf package/helloworld/hysteria
rm -rf package/helloworld/trojan
rm -rf package/helloworld/naiveproxy
rm -rf package/helloworld/v2ray-geodata
rm -rf package/helloworld/microsocks
rm -rf package/helloworld/dns2tcp
rm -rf package/helloworld/tcping
rm -rf package/helloworld/v2ray-plugin
rm -rf package/helloworld/xray-plugin

# 5. 加入预编译 Rust 保底防线
echo "🛡️ 注入 Rust 预编译防线..."
echo "CONFIG_RUST_USE_PREBUILT_HOST=y" >> .config

# 6. 开启全局编译缓存 (配合 Github Actions 提速！)
echo "⚡ 开启全局 Ccache 编译缓存..."
echo "CONFIG_CCACHE=y" >> .config

echo "✅ 前置环境准备完毕！"
