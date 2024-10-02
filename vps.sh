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
    echo -e "${GREEN}=== VPS 管理工具 ===${RESET}"
    echo "1. 安装 Xray"
    echo "2. 安装 Naïve"
    echo "3. 安装 Snell"
    echo "4. 安装 Mieru"
    echo "5. 安装 Hysteria"
    echo "6. 安装 sing-box"
    echo "7. 开放 VPS 端口"
    echo "8. 修改 root登录"
    echo "9. 开启 BBR 优化"
    echo "0. 退出"    
    echo -e "${GREEN}====================${RESET}"
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
            bash <(curl -fsSL https://gitlab.com/passeway/Xray/raw/main/Xray.sh)
            ;;
        2)
            echo -e "${CYAN}正在进入 Naïve${RESET}"
            bash <(curl -fsSL https://gitlab.com/passeway/naiveproxy/raw/main/naive.sh)
            ;;
        3)
            echo -e "${CYAN}正在进入 Snell${RESET}"
            bash <(curl -fsSL https://gitlab.com/passeway/Snell/raw/main/Snell.sh)
            ;;
        4)
            echo -e "${CYAN}正在进入 Mieru${RESET}"
            bash <(curl -fsSL https://gitlab.com/passeway/mieru/raw/main/mieru.sh)
            ;;
        5)
            echo -e "${CYAN}正在进入 Hysteria${RESET}"
            bash <(curl -fsSL https://gitlab.com/passeway/Hysteria/raw/main/Hysteria.sh)
            ;;
        6)
            echo -e "${CYAN}正在进入 sing-box${RESET}"
            bash <(curl -fsSL https://gitlab.com/passeway/sing-box/raw/main/sing-box.sh)
            ;;
        7)
            echo -e "${CYAN}正在开放 VPS 端口${RESET}"
            curl -sS -o ufw.sh https://gitlab.com/passeway/ufw/raw/main/ufw.sh && chmod +x ufw.sh && ./ufw.sh
            ;;
        8)
            echo -e "${CYAN}正在修改 root 登录${RESET}"
            curl -sS -o root.sh https://gitlab.com/passeway/root/raw/main/root.sh && chmod +x root.sh && ./root.sh
            ;;
        9)
            echo -e "${CYAN}正在开启 BBR 优化${RESET}"
            curl -sS -o bbr.sh https://gitlab.com/passeway/bbr/raw/main/bbr.sh && chmod +x bbr.sh && ./bbr.sh
            ;;
        *)
            echo -e "${RED}无效的选项${RESET}"
            ;;
    esac
    read -p "按 enter 键继续..."
done
