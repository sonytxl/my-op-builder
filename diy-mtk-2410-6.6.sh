#!/bin/bash
BJ_TIME=$(TZ='Asia/Shanghai' date +'%Y-%m-%d %H:%M:%S')
echo "🚀 开始执行 MT7981/7986 SSR-Plus 强行缝合版 (24.10-6.6) - $BJ_TIME"

# 1. 修改默认 IP 与主机名
sed -i 's/192.168.1.1/192.168.51.1/g' package/base-files/files/bin/config_generate
sed -i 's/192.168.6.1/192.168.51.1/g' package/base-files/files/bin/config_generate
sed -i 's/ImmortalWrt/Ecom-Gateway/g' package/base-files/files/bin/config_generate

# ==================== 核心手术区 ====================

# 2. 强行拉取 Lede 生态的 Helloworld 源码
echo "📦 正在拉取 FW876 原版 helloworld..."
git clone --depth=1 https://github.com/fw876/helloworld.git package/helloworld

# 3. 🔪 物理屠城：干掉 ImmortalWrt 官方的冲突组件
# 只要官方 feeds 里有这些，编译器就会串台，必须连根拔起！
echo "🧹 正在物理销毁官方冲突依赖..."
rm -rf feeds/packages/net/mosdns
rm -rf feeds/packages/net/xray-core
rm -rf feeds/packages/net/xray-plugin
rm -rf feeds/packages/net/shadowsocks-rust
rm -rf feeds/packages/net/v2ray-core
rm -rf feeds/packages/net/v2ray-geodata
rm -rf feeds/packages/net/v2ray-plugin

# 4. 🛡️ 双重保险：暴力删掉 .config 里的强制覆盖霸王条款
# (防止系统忽略我们的手术，强制去下载官方包)
sed -i '/CONFIG_OVERRIDE_PKGS/d' .config

# ==================== 基础配置区 ====================

# 5. 防爆内存编译参数 (ZRAM)
echo "CONFIG_RUST_USE_PREBUILT_HOST=y" >> .config
echo "CONFIG_CCACHE=y" >> .config

# 6. 无敌开机密码烙印 (防止被系统重置)
echo "📜 正在写入 uci-defaults 注入脚本..."
mkdir -p package/base-files/files/etc/uci-defaults
cat << "EOF" > package/base-files/files/etc/uci-defaults/99-zz-custom-setup
#!/bin/sh
echo -e "password\npassword" | passwd root
rm -f /etc/uci-defaults/99-zz-custom-setup
exit 0
EOF

# 7. WiFi 默认配置注入
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

echo "✅ Helloworld 终极缝合手术完成！"
