#!/bin/bash

# 检查是否以 root 身份运行脚本
if [ "$EUID" -ne 0 ]; then
  echo "请使用 sudo 或者以 root 身份运行该脚本"
  exit 1
fi

# 安装必要的软件包
echo "更新软件包列表并安装必要的软件包..."
apt update
apt install -y apt-transport-https curl

# 添加 Cloudflare 的 APT 源
echo "添加 Cloudflare 的 APT 源..."
curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg | tee /usr/share/keyrings/cloudflare-main.gpg >/dev/null
echo "deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/ $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/cloudflare-client.list

# 安装 cloudflared
echo "安装 cloudflared..."
apt update
apt install -y cloudflared

# 创建 cloudflared 配置文件
echo "配置 cloudflared..."
mkdir -p /etc/cloudflared
cat << EOF > /etc/cloudflared/config.yml
proxy-dns: true
proxy-dns-port: 5053
proxy-dns-upstream:
  - https://1.1.1.1/dns-query
  - https://1.0.0.1/dns-query
EOF

# 启动并启用 cloudflared 服务
echo "启用 cloudflared 服务..."
systemctl enable cloudflared
systemctl start cloudflared

# 检查 cloudflared 服务状态
echo "检查 cloudflared 服务状态..."
systemctl status cloudflared --no-pager

# 修改 systemd-resolved 配置
echo "配置 systemd-resolved..."
sed -i 's/^#DNS=/DNS=127.0.0.1:5053/' /etc/systemd/resolved.conf
sed -i 's/^#DNSStubListener=yes/DNSStubListener=no/' /etc/systemd/resolved.conf

# 重启 systemd-resolved 服务
echo "重启 systemd-resolved 服务..."
systemctl restart systemd-resolved

# 显示 DNS 状态
echo "DNS 配置已完成，当前 DNS 设置如下："
resolvectl status

echo "Cloudflare DNS over HTTPS 配置已完成！"
