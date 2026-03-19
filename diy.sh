

echo "🚀 开始运行自定义注入脚本..."

# ================= 1. 拉取额外插件源码 =================
echo "📦 正在拉取 luci-app-ssr-plus 源码..."
# 将 helloworld (包含 ssr-plus) 拉取到 package/helloworld 目录下
git clone --depth=1 https://github.com/fw876/helloworld.git package/helloworld

# 如果你以后还发现缺什么别的插件，都可以用这种方式 git clone 到 package/ 目录下
# git clone https://github.com/xxx/xxx.git package/xxx


# ================= 2. 基础个性化设置 =================
# 修改默认 IP 地址
sed -i 's/192.168.1.1/192.168.61.1/g' package/base-files/files/bin/config_generate
echo "✅ 默认 IP 已修改为 192.168.61.1"

# 修改默认主题
# sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile
# echo "✅ 默认主题已设置为 Argon"


# ================= 3. 核心插件选择区 =================
# 将你需要编译进固件的插件保持 =y

cat >> .config <<EOF

# 在 diy.sh 中把 =y 替换成 is not set，就能强行卸载底盘自带的插件
# sed -i 's/CONFIG_PACKAGE_luci-app-samba4=y/# CONFIG_PACKAGE_luci-app-samba4 is not set/g' .config

# --- 基础实用工具 ---
CONFIG_PACKAGE_luci-app-autoreboot=y
CONFIG_PACKAGE_luci-app-ddns=y
CONFIG_PACKAGE_luci-app-upnp=y
# CONFIG_PACKAGE_luci-app-wol=y
# CONFIG_PACKAGE_luci-app-samba4=y 

# --- 科学上网核心 ---
# 我们刚刚在上面拉取了源码，现在这里设为 y 就会生效了！
# CONFIG_PACKAGE_luci-app-ssr-plus=y

# CONFIG_PACKAGE_luci-app-homeproxy=y
# CONFIG_PACKAGE_luci-app-openclash=y
# CONFIG_PACKAGE_luci-app-passwall=y

# --- 异地组网 / 虚拟局域网 ---
CONFIG_PACKAGE_luci-app-wireguard=y
CONFIG_PACKAGE_luci-app-zerotier=y
# CONFIG_PACKAGE_luci-app-tailscale=y

# --- UI 主题包 ---
# CONFIG_PACKAGE_luci-theme-argon=y

EOF

echo "✅ 插件配置及依赖指令已成功注入 .config！"
