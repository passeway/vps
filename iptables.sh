#!/bin/bash

# 启用 IPv4 转发
echo "启用 IPv4 转发..."
sudo sysctl -w net.ipv4.ip_forward=1

# 将 IP 转发设置持久化，以便重启后仍然生效
echo "将 IPv4 转发设置持久化..."
if ! grep -q "net.ipv4.ip_forward=1" /etc/sysctl.conf; then
    echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf
fi
sudo sysctl -p

# 添加 NAT 转发规则
echo "向 iptables 添加 NAT 规则..."
sudo iptables -t nat -A PREROUTING -p tcp --dport 30642 -j DNAT --to-destination 45.143.233.45:30642
sudo iptables -t nat -A PREROUTING -p udp --dport 30642 -j DNAT --to-destination 45.143.233.45:30642
sudo iptables -t nat -A POSTROUTING -j MASQUERADE

# 安装并配置 netfilter-persistent，以便保存 iptables 规则
echo "安装 netfilter-persistent 以保存 iptables 规则..."
sudo apt update
sudo apt install -y iptables-persistent netfilter-persistent

# 保存当前 iptables 配置
echo "保存当前 iptables 规则..."
sudo netfilter-persistent save

# 启用 netfilter-persistent 服务，确保在启动时应用规则
echo "启用 netfilter-persistent 服务..."
sudo systemctl enable netfilter-persistent
sudo systemctl start netfilter-persistent

# 验证配置是否成功
echo "配置完成，验证设置..."

# 检查 IP 转发状态
sysctl net.ipv4.ip_forward

# 检查 iptables NAT 规则
sudo iptables -t nat -L -v -n

echo "设置完成。NAT 规则和 IP 转发将会在重启后保持生效。"
