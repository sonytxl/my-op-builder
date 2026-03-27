#!/bin/bash
echo "🚀 开始执行 MTK 7981/7986 (23.05 分支) 编译前置任务..."

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

# 6. 开启全局编译缓存
echo "⚡ 开启全局 Ccache 编译缓存..."
echo "CONFIG_CCACHE=y" >> .config

# 7. 注入开机自动配置脚本 (核心：密码与WiFi统一)
echo "📜 正在注入开机自动配置脚本 (后台密码与WiFi设定)..."
mkdir -p package/base-files/files/etc/uci-defaults
cat << "EOF" > package/base-files/files/etc/uci-defaults/999-custom-settings
#!/bin/sh

# (1) 设置路由器默认登录密码为 password (写入加密后的 Hash 值)
sed -i 's/^\(root:\)[^:]*:/\1$1$V4UetPzk$CYXluq41wU.F4HnvQ.6hX.:/' /etc/shadow

# (2) 设置所有 WiFi 频段名称为 mywifi，密码为 password
# 等待系统自动生成默认 WiFi 配置文件后执行拦截修改
sleep 3
if [ -f /etc/config/wireless ]; then
    # 遍历并修改所有无线接口 (自动兼容 2.4G 和 5G)
    for iface in $(uci show wireless | grep "=wifi-iface" | cut -d'.' -f2 | cut -d'=' -f1); do
        uci set wireless.${iface}.ssid='mywifi'
        uci set wireless.${iface}.encryption='psk2'
        uci set wireless.${iface}.key='password'
    done
    
    # 遍历并强制开启所有物理无线网卡
    for radio in $(uci show wireless | grep "=wifi-device" | cut -d'.' -f2 | cut -d'=' -f1); do
        uci set wireless.${radio}.disabled='0'
    done
    
    uci commit wireless
    wifi reload
fi

# 脚本运行一次后自我删除，防止每次开机都重置
rm -f /etc/uci-defaults/999-custom-settings
exit 0
EOF

echo "✅ 前置环境及自动化脚本注入完毕！"
