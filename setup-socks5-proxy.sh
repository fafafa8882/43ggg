#!/bin/bash

# 检查是否以 root 身份运行脚本
if [ "$EUID" -ne 0 ]; then
  echo "请使用 sudo 或者以 root 身份运行该脚本"
  exit 1
fi

echo "更新软件包列表并安装 dante-server..."
apt update
apt install -y dante-server

echo "配置 dante-server..."

# 备份原有的配置文件
cp /etc/danted.conf /etc/danted.conf.bak

# 获取服务器的公网 IP
SERVER_IP=$(hostname -I | awk '{print $1}')

# 创建新的配置文件
cat << EOF > /etc/danted.conf
logoutput: syslog
internal: $SERVER_IP port = 1291
external: $SERVER_IP
method: username none
user.privileged: root
user.notprivileged: nobody
clientmethod: none
client pass {
    from: 0.0.0.0/0 to: 0.0.0.0/0
    log: error
}
socks pass {
    from: 0.0.0.0/0 to: 0.0.0.0/0
    protocol: tcp udp
    log: error
    # 添加这一行来指定 DNS 解析
    resolveprotocol: fake
    route { to: 0.0.0.0/0 via: 127.0.0.1 port = 5053 }
}
EOF

echo "创建代理认证用户..."

# 创建一个名为 'proxyuser' 的用户，并设置密码
USERNAME="meizu"
PASSWORD="meizu"  # 请替换为你的密码

# 检查用户是否已存在
if id "$USERNAME" &>/dev/null; then
    echo "用户 $USERNAME 已存在，跳过创建。"
else
    useradd -m -s /usr/sbin/nologin "$USERNAME"
    echo "$USERNAME:$PASSWORD" | chpasswd
    echo "用户 $USERNAME 创建完成。"
fi

echo "重启 dante-server 服务..."
systemctl restart danted
systemctl enable danted

echo "配置完成！你的 SOCKS5 代理服务器已在端口 1291 上运行。"

echo "代理服务器信息："
echo "IP 地址：$SERVER_IP"
echo "端口：1291"
echo "用户名：$USERNAME"
echo "密码：$PASSWORD"

echo "请务必更改默认密码，并确保服务器的防火墙允许端口 1080 的连接。"
