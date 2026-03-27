#!/bin/bash
echo "🚀 开始执行 MTK 7986 (XDR6088) 终极量产版编译前置任务..."

# 1. 修改默认 IP
echo "🔧 正在修改默认 IP 地址为 192.168.51.1..."
sed -i 's/192.168.1.1/192.168.51.1/g' package/base-files/files/bin/config_generate

# 2. 修改默认主机名
echo "🏷️ 正在修改默认主机名为 Ecom-Gateway..."
sed -i 's/ImmortalWrt/Ecom-7986-Pro/g' package/base-files/files/bin/config_generate

# 3. 注入 SSR-Plus 源码
echo "📦 正在拉取 luci-app-ssr-plus 源码..."
git clone --depth=1 https://github.com/fw876/helloworld.git package/helloworld

# 4. 【核心修复】解决 xray-core 编译失败问题
echo "🛠️ 正在执行 xray-core 编译优化策略..."
# (A) 物理删除官方 feeds 里的 xray-core，防止它和 helloworld 里的版本冲突
rm -rf feeds/packages/net/xray-core
# (B) 确保保留 helloworld 里的 xray-core，不要执行 rm 操作
# (C) 清理其他不需要的组件
rm -rf package/helloworld/sing-box
rm -rf package/helloworld/shadowsocks-rust
rm -rf package/helloworld/shadow-tls
rm -rf package/helloworld/tuic-client
rm -rf package/helloworld/hysteria
rm -rf package/helloworld/trojan
rm -rf package/helloworld/naiveproxy

# 5. 加入预编译 Rust 保底防线 (已删除导致报错的 Go 环境强制指定)
echo "🛡️ 注入 Rust 预编译防线..."
echo "CONFIG_RUST_USE_PREBUILT_HOST=y" >> .config

# 6. 开启全局编译缓存
echo "⚡ 开启全局 Ccache 编译缓存..."
echo "CONFIG_CCACHE=y" >> .config

# 7. 注入开机自动配置脚本 (ZeroTier + Moon + WiFi + 密码)
echo "📜 正在注入自动化量产脚本..."
mkdir -p package/base-files/files/etc/uci-defaults
cat << "EOF" > package/base-files/files/etc/uci-defaults/999-custom-settings
#!/bin/sh

# (1) 设置默认密码为 password
sed -i 's/^\(root:\)[^:]*:/\1$1$V4UetPzk$CYXluq41wU.F4HnvQ.6hX.:/' /etc/shadow

# (2) ZeroTier 自动化配置
ZT_NET_ID="41207907b477904b"
while uci -q delete zerotier.@zerotier[0]; do :; done
uci set zerotier.default_setup=zerotier
uci set zerotier.default_setup.enabled='1'
uci add_list zerotier.default_setup.join="$ZT_NET_ID"
uci set zerotier.default_setup.secret='generate'
uci commit zerotier

/etc/init.d/zerotier enable
/etc/init.d/zerotier start

# 等待 15 秒挂载搬瓦工 Moon 卫星加速 (ID: 41207907b4)
(
    sleep 15
    zerotier-cli orbit 41207907b4 41207907b4
) &

# (3) 统一 WiFi 名字与密码 (SSID: Ecom-WiFi-Pro)
sleep 3
if [ -f /etc/config/wireless ]; then
    for iface in $(uci show wireless | grep "=wifi-iface" | cut -d'.' -f2 | cut -d'=' -f1); do
        uci set wireless.${iface}.ssid='Ecom-WiFi-Pro'
        uci set wireless.${iface}.encryption='psk2'
        uci set wireless.${iface}.key='password'
    done
    for radio in $(uci show wireless | grep "=wifi-device" | cut -d'.' -f2 | cut -d'=' -f1); do
        uci set wireless.${radio}.disabled='0'
    done
    uci commit wireless
    wifi reload
fi

rm -f /etc/uci-defaults/999-custom-settings
exit 0
EOF

echo "✅ 7986 终极优化版注入完毕！"
