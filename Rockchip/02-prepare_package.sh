#!/bin/bash
#========================================================================================================================
# https://github.com/oppen321/ZeroWrt-Action
# Description: Automatically Build OpenWrt
# Function: Diy script (After Update feeds, Modify the default IP, hostname, theme, add/remove software packages, etc.)
# Source code repository: https://github.com/immortalwrt/immortalwrt / Branch: openwrt-24.10
#========================================================================================================================

# 替换软件包
rm -rf feeds/packages/lang/golang
rm -rf feeds/packages/utils/coremark
rm -rf feeds/luci/applications/luci-app-alist
rm -rf feeds/packages/net/{alist,zerotier,xray-core,v2ray-core,v2ray-geodata,sing-box}

# golong1.24依赖
git clone --depth=1 -b 24.x https://github.com/sbwml/packages_lang_golang feeds/packages/lang/golang

# helloworld
git clone --depth=1 -b helloworld https://github.com/oppen321/openwrt-package package/helloworld

# 加载软件源
git clone --depth=1 https://github.com/oppen321/openwrt-package package/openwrt-package

# 自定义设置
sed -i "s/DISTRIB_DESCRIPTION='*.*'/DISTRIB_DESCRIPTION='ZeroWrt-$date'/g"  package/base-files/files/etc/openwrt_release
sed -i "s/DISTRIB_REVISION='*.*'/DISTRIB_REVISION=' By OPPEN321'/g" package/base-files/files/etc/openwrt_release
sed -i 's/services/network/' package/openwrt-package/OpenAppFilter/luci-app-oaf/luasrc/controller/appfilter.lua
curl -s $mirror/images/bg1.jpg package/openwrt-package/luci-theme-argon/htdocs/luci-static/argon/img/bg1.jpg
sed -i 's/bing/none/' package/openwrt-package/luci-app-argon-config/root/etc/config/argon


# update feeds
./scripts/feeds update -a
./scripts/feeds install -a
