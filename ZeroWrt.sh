#!/bin/bash

# 彩色输出函数
color_output() {
    echo -e "\e[1;32m$1\e[0m"
}

# 打印脚本头部，增加美观
print_header() {
    clear
    color_output "====================================="
    color_output "  Welcome to the OpenWrt Setup Script  "
    color_output "====================================="
    color_output "        Version: 1.0.0                "
    color_output "        Author: Your Name             "
    color_output "        Date: $(date +'%Y-%m-%d')     "
    color_output "====================================="
    color_output "This script helps you to set up OpenWrt, "
    color_output "ImmortalWrt or Lede, and install Zero source."
    color_output "====================================="
}

# 打印 Zero OpenWrt 编译脚本信息
print_zero_info() {
    color_output "Zero OpenWrt 编译脚本信息:"
    color_output " - Zero源: https://github.com/oppen321/Zero-IPK"
    color_output " - 为了提高下载速度，脚本会自动添加Zero源"
    color_output "====================================="
}

# 检测并安装依赖
install_dependencies() {
    color_output "检测并安装依赖..."
    # 检查是否已安装依赖
    if dpkg-query -l | grep -q "curl"; then
        color_output "依赖已安装，执行下一步..."
    else
        sudo -E apt-get -y install $(curl -fsSL is.gd/depends_ubuntu_2204)
    fi
}

# 克隆源码
clone_source() {
    color_output "请选择要克隆的源码："
    echo "1. Lede"
    echo "2. OpenWrt"
    echo "3. ImmortalWrt"
    read -p "请输入选项 (1/2/3): " choice

    case $choice in
        1) 
            repo_url="https://github.com/coolsnowwolf/lede.git"
            branch="master"
            ;;
        2) 
            repo_url="https://github.com/openwrt/openwrt.git"
            echo "请选择分支："
            echo "1. master"
            echo "2. openwrt-23.05"
            echo "3. openwrt-24.10"
            read -p "请输入选项 (1/2/3): " branch_choice
            case $branch_choice in
                1) branch="master" ;;
                2) branch="openwrt-23.05" ;;
                3) branch="openwrt-24.10" ;;
                *) branch="master" ;;
            esac
            ;;
        3)
            repo_url="https://github.com/immortalwrt/immortalwrt.git"
            echo "请选择分支："
            echo "1. master"
            echo "2. openwrt-23.05"
            echo "3. openwrt-24.10"
            read -p "请输入选项 (1/2/3): " branch_choice
            case $branch_choice in
                1) branch="master" ;;
                2) branch="openwrt-23.05" ;;
                3) branch="openwrt-24.10" ;;
                *) branch="master" ;;
            esac
            ;;
        *)
            color_output "无效选择，退出脚本..."
            exit 1
            ;;
    esac

    # 检查是否已经有源码目录
    if [ -d "openwrt" ]; then
        color_output "检测到已有 openwrt 目录，是否更换源码？"
        echo "1. 是"
        echo "2. 否"
        read -p "请输入选项 (1/2): " replace_choice
        case $replace_choice in
            1)
                color_output "删除已有源码目录..."
                rm -rf openwrt
                ;;
            2)
                color_output "跳过克隆源码步骤..."
                return
                ;;
            *)
                color_output "无效选择，退出脚本..."
                exit 1
                ;;
        esac
    fi

    # 克隆源码
    git clone -b $branch $repo_url openwrt
    color_output "源码克隆完成"
}

# 是否加入 Zero 源
add_zero_source() {
    color_output "是否加入 Zero 源？"
    echo "1. 是"
    echo "2. 否"
    read -p "请输入选项 (1/2): " zero_choice
    case $zero_choice in
        1)
            echo -e "\nsrc-git Zero-IPK https://github.com/oppen321/Zero-IPK" >> openwrt/feeds.conf.default
            color_output "Zero源已添加"
            ;;
        2)
            color_output "跳过 Zero 源添加..."
            ;;
        *)
            color_output "无效选择，退出脚本..."
            exit 1
            ;;
    esac
}

# 更新和安装 Feeds
update_feeds() {
    color_output "更新和安装 Feeds..."
    cd openwrt
    ./scripts/feeds update -a
    ./scripts/feeds install -a
    color_output "Feeds 更新和安装完成"
}

# 编译
compile() {
    # 切换为普通用户
    if [ $(id -u) -eq 0 ]; then
        color_output "您当前是以 root 用户运行脚本，正在切换为普通用户..."
        sudo su - $(logname)
    fi

    color_output "请选择编译选项："
    echo "1. 单线程编译"
    echo "2. 多线程编译（最大线程数）"
    read -p "请输入选项 (1/2): " compile_choice
    case $compile_choice in
        1)
            color_output "开始单线程编译..."
            make V=s -j1
            ;;
        2)
            color_output "开始多线程编译..."
            make -j$(nproc)
            ;;
        *)
            color_output "无效选择，退出脚本..."
            exit 1
            ;;
    esac
}

# 显示主菜单
show_menu() {
    color_output "请选择您要执行的操作："
    echo "1. 安装依赖"
    echo "2. 克隆源码"
    echo "3. 加入 Zero 源"
    echo "4. 更新和安装 Feeds"
    echo "5. 编译源码"
    echo "6. 退出脚本"
    read -p "请输入选项 (1-6): " menu_choice

    case $menu_choice in
        1) install_dependencies ;;
        2) clone_source ;;
        3) add_zero_source ;;
        4) update_feeds ;;
        5) compile ;;
        6) color_output "退出脚本..."; exit 0 ;;
        *)
            color_output "无效选择，请重新选择..."
            show_menu
            ;;
    esac
}

# 主函数
main() {
    print_header
    print_zero_info
    while true; do
        show_menu
    done
}

# 执行主函数
main
