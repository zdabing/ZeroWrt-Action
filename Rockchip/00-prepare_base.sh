#!/bin/bash
#========================================================================================================================
# https://github.com/oppen321/ZeroWrt-Action
# Description: Automatically Build OpenWrt for Rockchip
# Function: Diy script (Before Update feeds, Modify the default IP, hostname, theme, add/remove software packages, etc.)
# Source code repository: https://github.com/immortalwrt/immortalwrt / Branch: openwrt-24.10
#========================================================================================================================

# default LAN IP
sed -i "s/192.168.1.1/$LAN/g" package/base-files/files/bin/config_generate

# 修改名称
sed -i 's/ImmortalWrt/ZeroWrt/' package/base-files/files/bin/config_generate

# init-settings.sh
mkdir -p files/etc/uci-defaults
curl -s $mirror/Rockchip/files/etc/uci-defaults/99-init-settings > files/etc/uci-defaults/99-init-settings

# TTYD
sed -i 's/services/system/g' feeds/luci/applications/luci-app-ttyd/root/usr/share/luci/menu.d/luci-app-ttyd.json
sed -i '3 a\\t\t"order": 50,' feeds/luci/applications/luci-app-ttyd/root/usr/share/luci/menu.d/luci-app-ttyd.json
sed -i 's/procd_set_param stdout 1/procd_set_param stdout 0/g' feeds/packages/utils/ttyd/files/ttyd.init
sed -i 's/procd_set_param stderr 1/procd_set_param stderr 0/g' feeds/packages/utils/ttyd/files/ttyd.init

# rockchip
curl -o ./target/linux/rockchip/patches-6.6/014-rockchip-add-pwm-fan-controller-for-nanopi-r2s-r4s.patch $mirror/patch/rockchip/014-rockchip-add-pwm-fan-controller-for-nanopi-r2s-r4s.patch
curl -o ./target/linux/rockchip/patches-6.6/702-general-rk3328-dtsi-trb-ent-quirk.patch $mirror/patch/rockchip/702-general-rk3328-dtsi-trb-ent-quirk.patch
curl -o ./target/linux/rockchip/patches-6.6/703-rk3399-enable-dwc3-xhci-usb-trb-quirk.patch $mirror/patch/rockchip/703-rk3399-enable-dwc3-xhci-usb-trb-quirk.patch

# luci
pushd feeds/luci
    curl -s $mirror/patch/luci/0001-luci-mod-status-firewall-disable-legacy-firewall-rul.patch | patch -p1
popd

# 移除 SNAPSHOT 标签
sed -i 's,-SNAPSHOT,,g' include/version.mk
sed -i 's,-SNAPSHOT,,g' package/base-files/image-config.in
sed -i '/CONFIG_BUILDBOT/d' include/feeds.mk
sed -i 's/;)\s*\\/; \\/' include/feeds.mk
