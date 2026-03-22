#!/bin/bash
echo "🚀 开始执行 XDR6088 (2410 低运存极简版) 编译前置任务..."

# 1. 修改默认 IP 为 51.1 (防冲突)
sed -i 's/192.168.1.1/192.168.51.1/g' package/base-files/files/bin/config_generate
sed -i 's/192.168.6.1/192.168.51.1/g' package/base-files/files/bin/config_generate

# 2. 加入预编译 Rust 保底防线 (虽然不用 SSR-Plus，但 HomeProxy 偶尔会用到极少量 Rust 组件，加上这句防报错)
echo "CONFIG_RUST_USE_PREBUILT_HOST=y" >> .config

# 3. 开启全局编译缓存 (极其重要！)
echo "📦 正在开启全局 Ccache 编译缓存..."
echo "CONFIG_CCACHE=y" >> .config

echo "✅ 前置环境准备完毕，极简版底盘移交编译引擎！"
