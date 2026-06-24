#!/bin/bash
echo "🚀 开始执行 qualcomm IPQ50xx/60XX/80xx 纯净量产版编译前置任务..."

# =====================================================================
# 🔧 修正 1：编译核心参数注入区（集权管理）
# 所有的硬改内存寻址、Ccache 缓存开关以及硬件物理层补丁在这里统一追加！
# =====================================================================
echo "📦 注入高能硬改内存与 CCache 全局编译缓存优化..."
echo "CONFIG_RUST_USE_PREBUILT_HOST=y" >> .config
echo "CONFIG_DEVEL=y" >> .config
echo "CONFIG_CCACHE=y" >> .config

# 🩸 架构师核心增补：强行超度高通 60xx 家族内置硬盘物理层死锁，焊死亚瑟 USB 3.0 通信硬轨
# (注：此3行参数对不带硬盘的红米AX6、360v6在内核自动精简时完全无害、自动忽略)
echo "CONFIG_PACKAGE_kmod-usb-phy-qcom-dwc3=y" >> .config
echo "CONFIG_PACKAGE_kmod-usb-roles-qcom=y" >> .config
echo "CONFIG_PACKAGE_kmod-usb-ehci=y" >> .config

# =====================================================================
# 📂 基础基建修改区
# =====================================================================
# 1. 修改默认 IP（网段对齐 192.168.61.1）
sed -i 's/192.168.1.1/192.168.61.1/g' package/base-files/files/bin/config_generate

# 2. 终极放大招：动态注入脚本，完美接管客户工作室的主机名、时区和 WiFi 
echo "🛠️ 正在写入底层硬件配置脚本 (Hostname, Timezone, WiFi)..."
mkdir -p package/base-files/files/etc/uci-defaults

# 写入合并版的 99-ecom-gateway-setup 脚本
cat << "EOF" > package/base-files/files/etc/uci-defaults/99-ecom-gateway-setup
#!/bin/sh

# [A] 强行夺取主机名和时区控制权（完美解决原厂 sed 替换偶发性失效问题）
uci set system.@system[0].hostname='Ecom-Gateway'
uci set system.@system[0].timezone='CST-8'
uci set system.@system[0].zonename='Asia/Shanghai'
uci commit system

# [B] 动态接管并重写所有底层 WiFi 配置
if [ -f /etc/config/wireless ]; then
    # 修改 SSID 和密码（对齐工作室搞钱专用无线）
    for iface in $(uci show wireless | grep "=wifi-iface" | cut -d'.' -f2 | cut -d'=' -f1); do
        uci set wireless.${iface}.ssid='Ecom-WiFi'
        uci set wireless.${iface}.encryption='psk2'
        uci set wireless.${iface}.key='password'
    done
    
    # 强制激活所有被禁用的 WiFi 物理天线（解锁高通天线满血并发）
    for radio in $(uci show wireless | grep "=wifi-device" | cut -d'.' -f2 | cut -d'=' -f1); do
        uci set wireless.${radio}.disabled='0'
    done
    uci commit wireless
    wifi reload
fi

# [C] 功成身退，自杀销毁（保证只在刚刷机初次开机时执行一次，绝不内耗）
rm -f /etc/uci-defaults/99-ecom-gateway-setup
exit 0
EOF

echo "✅ 前置 DIY 底层注入圆满完成！"
