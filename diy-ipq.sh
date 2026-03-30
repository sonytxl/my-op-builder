#!/bin/bash
echo "🚀 开始执行 JDCloud AX1800 Pro 纯净量产版编译前置任务..."

# 1. 修改默认 IP
sed -i 's/192.168.1.1/192.168.61.1/g' package/base-files/files/bin/config_generate

# 2. 防爆内存与高通提速核心编译参数
echo "📦 注入防爆内存与 Ccache 全局编译缓存优化..."
echo "CONFIG_RUST_USE_PREBUILT_HOST=y" >> .config
echo "CONFIG_DEVEL=y" >> .config
echo "CONFIG_CCACHE=y" >> .config

# 3. 终极大招：用动态注入脚本一并接管 主机名、时区 和 WiFi
echo "🛠️ 正在写入底层硬件配置脚本 (Hostname, Timezone, WiFi)..."
mkdir -p package/base-files/files/etc/uci-defaults

# 写入合并版的 99-ecom-gateway-setup 脚本
cat << "EOF" > package/base-files/files/etc/uci-defaults/99-ecom-gateway-setup
#!/bin/sh

# [A] 强行夺取主机名和时区控制权 (完美解决 sed 替换失效问题)
uci set system.@system[0].hostname='Ecom-Gateway'
uci set system.@system[0].timezone='CST-8'
uci set system.@system[0].zonename='Asia/Shanghai'
uci commit system

# [B] 动态接管并重写所有底层 WiFi 配置
if [ -f /etc/config/wireless ]; then
    # 修改 SSID 和密码
    for iface in $(uci show wireless | grep "=wifi-iface" | cut -d'.' -f2 | cut -d'=' -f1); do
        uci set wireless.${iface}.ssid='Ecom-WiFi'
        uci set wireless.${iface}.encryption='psk2'
        uci set wireless.${iface}.key='password'
    done
    # 激活所有被禁用的 WiFi 天线
    for radio in $(uci show wireless | grep "=wifi-device" | cut -d'.' -f2 | cut -d'=' -f1); do
        uci set wireless.${radio}.disabled='0'
    done
    uci commit wireless
    wifi reload
fi

# [C] 功成身退，自杀销毁 (保证只在刚刷机开机时执行一次)
rm -f /etc/uci-defaults/99-ecom-gateway-setup
exit 0
EOF

echo "✅ 纯净底层环境准备完毕，完美对接官方 HomeProxy + Passwall 双引擎！"
