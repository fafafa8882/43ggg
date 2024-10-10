#!/bin/bash

# 更新系统并安装所需软件
sudo apt update
sudo apt install -y dante-server dnscrypt-proxy

# 配置 Dante
cat <<EOL | sudo tee /etc/danted.conf
logoutput: syslog

# 允许的用户
user.privileged: root
user.unprivileged: nobody

# 监听的地址和端口
internal: 0.0.0.0 port = 1080
external: $(curl -s ifconfig.me)

# 允许的网络访问
client pass {
    from: 0.0.0.0/0 to: 0.0.0.0/0
    log: connect disconnect
}

# 代理的网络访问
socks pass {
    from: 0.0.0.0/0 to: 0.0.0.0/0
    log: connect disconnect
}
EOL

# 配置 dnscrypt-proxy
sudo sed -i 's/^#server_names = .*/server_names = ["cloudflare"]/' /etc/dnscrypt-proxy/dnscrypt-proxy.toml

# 确保 dnscrypt-proxy 使用本地端口 53
sudo sed -i 's/^#listen_addresses = .*/listen_addresses = ["127.0.0.1:53"]/' /etc/dnscrypt-proxy/dnscrypt-proxy.toml

# 修改 resolv.conf
echo "nameserver 127.0.0.1" | sudo tee /etc/resolv.conf

# 启动 dnscrypt-proxy 和 danted 服务
sudo systemctl start dnscrypt-proxy
sudo systemctl enable dnscrypt-proxy
sudo systemctl start danted
sudo systemctl enable danted

# 显示服务状态
echo "Dante SOCKS5 Proxy 和 DNSCrypt Proxy 已成功安装并启动。"
sudo systemctl status danted
sudo systemctl status dnscrypt-proxy
