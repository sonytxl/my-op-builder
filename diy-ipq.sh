#!/bin/bash
echo "🚀 开始执行 JDCloud AX1800 Pro 终极量产编译前置任务..."

# 1. 修改默认 IP
sed -i 's/192.168.1.1/192.168.61.1/g' package/base-files/files/bin/config_generate

# 2. 修改默认主机名
# 暴力正则替换，无视原有名字是什么
sed -i "s/hostname='.*'/hostname='Ecom-Gateway'/g" package/base-files/files/bin/config_generate

# 3. 核心大招：拉取 SSR-Plus 源码供 .config 读取！
echo "📦 正在拉取 luci-app-ssr-plus 源码..."
git clone --depth=1 https://github.com/fw876/helloworld.git package/helloworld

# 4. 物理清除 SSR-Plus 中极易报错的 Rust/高耗时组件
echo "🧹 物理清除容易报错的组件..."
rm -rf package/helloworld/shadowsocks-rust
rm -rf package/helloworld/tuic-client
rm -rf package/helloworld/hysteria
rm -rf package/helloworld/trojan
rm -rf package/helloworld/naiveproxy

# 5. 加入预编译 Rust 保底防线
echo "CONFIG_RUST_USE_PREBUILT_HOST=y" >> .config

# 6. 开启全局编译缓存 (高通提速核心！)
echo "📦 正在开启高通全局 Ccache 编译缓存..."
echo "CONFIG_DEVEL=y" >> .config
echo "CONFIG_CCACHE=y" >> .config


# 7. WiFi 配置使用 uci-defaults 动态注入 (因涉及硬件底层识别)
mkdir -p package/base-files/files/etc/uci-defaults
cat << "EOF" > package/base-files/files/etc/uci-defaults/99-custom-wifi
#!/bin/sh
if [ -f /etc/config/wireless ]; then
    for iface in $(uci show wireless | grep "=wifi-iface" | cut -d'.' -f2 | cut -d'=' -f1); do
        uci set wireless.${iface}.ssid='Ecom-WiFi'
        uci set wireless.${iface}.encryption='psk2'
        uci set wireless.${iface}.key='password'
    done
    for radio in $(uci show wireless | grep "=wifi-device" | cut -d'.' -f2 | cut -d'=' -f1); do
        uci set wireless.${radio}.disabled='0'
    done
    uci commit wireless
    wifi reload
fi
rm -f /etc/uci-defaults/99-custom-wifi
exit 0
EOF



echo "✅ 高通前置环境准备完毕，完美底盘移交编译引擎！"
