#!/bin/bash
BJ_TIME=$(TZ='Asia/Shanghai' date +'%Y-%m-%d %H:%M:%S')
echo "🚀 开始执行 MTK 7981 终极量产版 - $BJ_TIME"

sed -i 's/192.168.1.1/192.168.51.1/g' package/base-files/files/bin/config_generate
sed -i 's/192.168.6.1/192.168.51.1/g' package/base-files/files/bin/config_generate
sed -i 's/ImmortalWrt/Ecom-Gateway/g' package/base-files/files/bin/config_generate

echo "📦 拉取并清理外壳..."
rm -rf package/helloworld
git clone --depth=1 https://github.com/fw876/helloworld.git package/helloworld
rm -rf package/helloworld/mosdns package/helloworld/xray-core package/helloworld/xray-plugin package/helloworld/sing-box package/helloworld/shadowsocks-rust package/helloworld/v2ray-core package/helloworld/v2ray-geodata package/helloworld/v2ray-plugin

echo "CONFIG_RUST_USE_PREBUILT_HOST=y" >> .config
echo "CONFIG_CCACHE=y" >> .config

echo "📜 注入开机脚本..."
mkdir -p package/base-files/files/etc/uci-defaults
cat << "EOF" > package/base-files/files/etc/uci-defaults/999-custom-settings
#!/bin/sh

# (1) 🚀 正宗 OpenWrt 改密法：使用 chpasswd 绝对生效！
echo "root:password" | chpasswd

# (2) ZeroTier 基础配置注入
ZT_NET_ID="41207907b477904b"
while uci -q delete zerotier.@zerotier[0]; do :; done
uci set zerotier.default_setup=zerotier
uci set zerotier.default_setup.enabled='1'
uci add_list zerotier.default_setup.join="$ZT_NET_ID"
uci set zerotier.default_setup.secret='generate'
uci commit zerotier

# (3) 🚀 修复时序黑洞：把 Orbit 寻星指令写入开机启动项 (rc.local)，开机 30 秒后网络通畅时再执行！
sed -i '/exit 0/i \sleep 30 && zerotier-cli orbit 41207907b4 41207907b4 &' /etc/rc.local

# (4) 统一 WiFi 命名
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

rm -f /etc/uci-defaults/999-custom-settings
exit 0
EOF

echo "✅ 7981 终极量产环境注入完毕！"
