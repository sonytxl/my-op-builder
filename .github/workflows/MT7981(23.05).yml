#!/bin/bash
BJ_TIME=$(TZ='Asia/Shanghai' date +'%Y-%m-%d %H:%M:%S')
echo "🚀 开始执行 MTK 7981 终极量产白金版 (sbwml 稳定版) - 当前北京时间: $BJ_TIME"

# 1. 修改默认 IP 与主机名
sed -i 's/192.168.1.1/192.168.51.1/g' package/base-files/files/bin/config_generate
sed -i 's/192.168.6.1/192.168.51.1/g' package/base-files/files/bin/config_generate
sed -i 's/ImmortalWrt/Ecom-Gateway/g' package/base-files/files/bin/config_generate

# ==================== ☢️ 核心换源破局 (终极核打击) ☢️ ====================
echo "🧹 执行 sbwml 官方推荐的终极清理大法：全盘搜索并彻底摧毁冲突的 Makefile！"
# 只有这样才能彻底斩断官方 feeds 里错综复杂的旧依赖连结，防止“走错门一秒暴毙”
find ./ | grep Makefile | grep v2ray-geodata | xargs rm -f
find ./ | grep Makefile | grep mosdns | xargs rm -f
find ./ | grep Makefile | grep v2dat | xargs rm -f
find ./ | grep Makefile | grep sing-box | xargs rm -f
find ./ | grep Makefile | grep xray-core | xargs rm -f

echo "📦 正在拉取 sbwml 极稳版全家桶..."
# (1) 核心代理组件
rm -rf package/helloworld
git clone --depth=1 -b v5 https://github.com/sbwml/openwrt_helloworld package/helloworld

# (2) MosDNS 和 v2dat
git clone --depth=1 -b v5 https://github.com/sbwml/luci-app-mosdns package/mosdns

# (3) v2ray-geodata
git clone --depth=1 https://github.com/sbwml/v2ray-geodata package/v2ray-geodata

# ==================== ⚙️ 核心编译器升级 ⚙️ ====================
echo "🔄 正在替换底层 Go 编译器版本为 1.23 (sbwml 强制要求)..."
rm -rf feeds/packages/lang/golang
git clone https://github.com/sbwml/packages_lang_golang -b 23.x feeds/packages/lang/golang

# ==================== 防爆内存补丁 ====================
echo "🛡️ 注入防爆内存与全局缓存..."
echo "CONFIG_RUST_USE_PREBUILT_HOST=y" >> .config
echo "CONFIG_CCACHE=y" >> .config

# ==================== 自动化量产注入 ====================
echo "📜 正在注入开机自动配置脚本 (ZeroTier + Moon + WiFi + 密码)..."
mkdir -p package/base-files/files/etc/uci-defaults
cat << "EOF" > package/base-files/files/etc/uci-defaults/999-custom-settings
#!/bin/sh
sed -i 's/^\(root:\)[^:]*:/\1$1$V4UetPzk$CYXluq41wU.F4HnvQ.6hX.:/' /etc/shadow

ZT_NET_ID="41207907b477904b"
while uci -q delete zerotier.@zerotier[0]; do :; done
uci set zerotier.default_setup=zerotier
uci set zerotier.default_setup.enabled='1'
uci add_list zerotier.default_setup.join="$ZT_NET_ID"
uci set zerotier.default_setup.secret='generate'
uci commit zerotier

/etc/init.d/zerotier enable
/etc/init.d/zerotier start

(
    sleep 15
    zerotier-cli orbit 41207907b4 41207907b4
) &

sleep 3
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
