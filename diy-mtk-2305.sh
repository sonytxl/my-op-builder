#!/bin/bash
echo "🚀 开始执行 MTK 7981 (23.05 分支) 编译前置任务..."

# 1. 修改默认 IP (目标改为 192.168.51.1)
echo "🔧 正在修改默认 IP 地址..."
sed -i 's/192.168.1.1/192.168.51.1/g' package/base-files/files/bin/config_generate
sed -i 's/192.168.6.1/192.168.51.1/g' package/base-files/files/bin/config_generate

# 2. 修改默认主机名 (可选，让你的固件看起来更专业)
echo "🏷️ 正在修改默认主机名..."
sed -i 's/ImmortalWrt/EComRouter/g' package/base-files/files/bin/config_generate

# 3. 拉取 Tailscale 图形界面源码 (如果需要，取消下面两行的注释即可)
# echo "📦 正在注入 luci-app-tailscale 源码..."
# git clone https://github.com/asvow/luci-app-tailscale.git package/luci-app-tailscale

# 4. 加入预编译 Rust 保底防线 (保留这个好习惯)
echo "🛡️ 注入 Rust 预编译防线..."
echo "CONFIG_RUST_USE_PREBUILT_HOST=y" >> .config

echo "✅ 前置环境准备完毕！依靠 23.05 原生源，告别依赖地狱！"
