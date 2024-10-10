#!/bin/bash

# 安装必要的工具
sudo apt install -y python3-pip dnscrypt-proxy wget

# 安装 Shadowsocks
pip3 install shadowsocks

# 创建 Shadowsocks 配置文件
cat <<EOL > ~/.shadowsocks.json
{
    "server": "127.0.0.1",
    "server_port": 1080,
    "local_address": "127.0.0.1",
    "local_port": 1080,
    "password": "meizu",  # 请将 your_password 替换为你想要的密码
    "timeout": 300,
    "method": "aes-256-gcm"
}
EOL

# 启动 Shadowsocks 代理
sslocal -c ~/.shadowsocks.json &

# 配置 dnscrypt-proxy
sudo sed -i "s/#server_names = \['2.dnscrypt-cert.dns.cloudflare.com'\]/server_names = \['cloudflare'\]/g" /etc/dnscrypt-proxy/dnscrypt-proxy.toml
sudo sed -i "s/#listen_addresses = \['127.0.0.1:53'\]/listen_addresses = \['127.0.0.1:5353'\]/g" /etc/dnscrypt-proxy/dnscrypt-proxy.toml

# 启动 dnscrypt-proxy
sudo systemctl start dnscrypt-proxy
sudo systemctl enable dnscrypt-proxy

# 配置系统 DNS
echo "nameserver 127.0.0.1" | sudo tee /etc/resolv.conf > /dev/null

# 安装 proxychains
sudo apt install -y proxychains

# 配置 proxychains
echo "socks5 127.0.0.1 1080" | sudo tee -a /etc/proxychains.conf > /dev/null

# 提示用户
echo "安装完成！请确保你将 ~/.shadowsocks.json 中的 'your_password' 替换为你想要的密码。"
echo "使用示例：proxychains curl http://example.com"
#!/bin/bash

# 更新系统
sudo apt update && sudo apt upgrade -y

# 安装必要的工具
sudo apt install -y python3-pip dnscrypt-proxy wget

# 安装 Shadowsocks
pip3 install shadowsocks

# 创建 Shadowsocks 配置文件
cat <<EOL > ~/.shadowsocks.json
{
    "server": "127.0.0.1",
    "server_port": 1080,
    "local_address": "127.0.0.1",
    "local_port": 1080,
    "password": "meizu",  # 请将 your_password 替换为你想要的密码
    "timeout": 300,
    "method": "aes-256-gcm"
}
EOL

# 启动 Shadowsocks 代理
sslocal -c ~/.shadowsocks.json &

# 配置 dnscrypt-proxy
sudo sed -i "s/#server_names = \['2.dnscrypt-cert.dns.cloudflare.com'\]/server_names = \['cloudflare'\]/g" /etc/dnscrypt-proxy/dnscrypt-proxy.toml
sudo sed -i "s/#listen_addresses = \['127.0.0.1:53'\]/listen_addresses = \['127.0.0.1:5353'\]/g" /etc/dnscrypt-proxy/dnscrypt-proxy.toml

# 启动 dnscrypt-proxy
sudo systemctl start dnscrypt-proxy
sudo systemctl enable dnscrypt-proxy

# 配置系统 DNS
echo "nameserver 127.0.0.1" | sudo tee /etc/resolv.conf > /dev/null

# 安装 proxychains
sudo apt install -y proxychains

# 配置 proxychains
echo "socks5 127.0.0.1 1080" | sudo tee -a /etc/proxychains.conf > /dev/null

# 提示用户
echo "安装完成！请确保你将 ~/.shadowsocks.json 中的 'your_password' 替换为你想要的密码。"
echo "使用示例：proxychains curl http://example.com"
