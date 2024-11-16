#!/bin/bash

# 定义颜色代码
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
RESET='\033[0m'

# 显示菜单
show_menu() {
    clear
    echo -e "${GREEN}========= VPS 管理工具 =========${RESET}"
    echo -e "1. 安装 Xray           2. 安装 Naïve"
    echo -e "3. 安装 Snell          4. 安装 Mieru"
    echo -e "5. 安装 Hysteria       6. 安装 sing-box"
    echo -e "7. 开放 VPS 端口       8. 修改 root 登录"
    echo -e "9. 开启 BBR 优化       0. 退出"
    echo -e "${GREEN}================================${RESET}"
    echo ""
    read -p "请输入选项编号: " choice
    echo ""
}

# 捕获 Ctrl+C 信号
trap 'echo -e "${RED}已取消操作${RESET}"; exit' INT

# 主循环
while true; do
    show_menu
    case "$choice" in
        0)
            echo -e "${GREEN}已退出 VPS 管理工具${RESET}"
            exit 0
            ;;
        1)
            echo -e "${CYAN}正在进入 Xray${RESET}"
            bash <(curl -fsSL xray-bay.vercel.app)
            ;;
        2)
            echo -e "${CYAN}正在进入 Naïve${RESET}"
            bash <(curl -fsSL naiveproxy-sigma.vercel.app)
            ;;
        3)
            echo -e "${CYAN}正在进入 Snell${RESET}"
            bash <(curl -fsSL snell-ten.vercel.app)
            ;;
        4)
            echo -e "${CYAN}正在进入 Mieru${RESET}"
            bash <(curl -fsSL mieru-ten.vercel.app)
            ;;
        5)
            echo -e "${CYAN}正在进入 Hysteria${RESET}"
            bash <(curl -fsSL hysteria-eight.vercel.app)
            ;;
        6)
            echo -e "${CYAN}正在进入 sing-box${RESET}"
            bash <(curl -fsSL sing-box-sigma.vercel.app)
            ;;
        7)
            echo -e "${CYAN}正在开放 VPS 端口${RESET}"
            bash <(curl -fsSL ufw-liart.vercel.app)
            ;;
        8)
            echo -e "${CYAN}正在修改 root 登录${RESET}"
            bash <(curl -fsSL root-silk.vercel.app)
            ;;
        9)
            echo -e "${CYAN}正在开启 BBR 优化${RESET}"
            bash <(curl -fsSL bbr-pi.vercel.app)
            ;;
        *)
            echo -e "${RED}无效的选项${RESET}"
            ;;
    esac
    read -p "按 enter 键继续..."
done
