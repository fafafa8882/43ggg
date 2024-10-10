import socket
import threading
import dns.resolver
import http.client
import json

# Cloudflare DoH服务器地址
DOH_SERVER = 'cloudflare-dns.com'
DOH_PATH = '/dns-query'

class Socks5Server:
    def __init__(self, host='0.0.0.0', port=1080):
        self.host = host
        self.port = port

    def start(self):
        server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        server.bind((self.host, self.port))
        server.listen(5)
        print(f"SOCKS5 server started on {self.host}:{self.port}")

        while True:
            client_socket, addr = server.accept()
            print(f"Connection from {addr}")
            threading.Thread(target=self.handle_client, args=(client_socket,)).start()

    def handle_client(self, client_socket):
        client_socket.recv(262)
        client_socket.sendall(b'\x05\x00')  # No authentication required

        # Receive request from client
        request = client_socket.recv(4)
        cmd = request[1]
        
        if cmd == 1:  # CONNECT command
            address_type = request[3]
            if address_type == 1:  # IPv4
                address = socket.inet_ntoa(client_socket.recv(4))
                port = int.from_bytes(client_socket.recv(2), 'big')
            elif address_type == 3:  # DOMAINNAME
                domain_length = client_socket.recv(1)[0]
                domain = client_socket.recv(domain_length).decode()
                port = int.from_bytes(client_socket.recv(2), 'big')
                # Resolve the domain using DoH
                address = self.resolve_domain(domain)
            else:
                client_socket.close()
                return

            if address:
                print(f"Connecting to {address}:{port}")
                try:
                    remote_socket = socket.create_connection((address, port))
                    client_socket.sendall(b'\x05\x00\x00\x01' + socket.inet_aton(address) + port.to_bytes(2, 'big'))
                    self.forward_data(client_socket, remote_socket)
                except Exception as e:
                    print(f"Connection failed: {e}")
                    client_socket.close()
            else:
                client_socket.close()
    
    def resolve_domain(self, domain):
        # 使用Cloudflare DoH解析域名
        headers = {'Content-Type': 'application/dns-json'}
        conn = http.client.HTTPSConnection(DOH_SERVER)
        conn.request("GET", DOH_PATH + "?name=" + domain + "&type=A", headers=headers)
        response = conn.getresponse()
        data = response.read()
        json_response = json.loads(data)
        
        if json_response['Answer']:
            ip = json_response['Answer'][0]['data']
            return ip
        return None

    def forward_data(self, client_socket, remote_socket):
        while True:
            # Forward data from client to remote server
            r, w, e = select.select([client_socket, remote_socket], [], [])
            if client_socket in r:
                data = client_socket.recv(4096)
                if len(data) == 0:
                    break
                remote_socket.sendall(data)

            if remote_socket in r:
                data = remote_socket.recv(4096)
                if len(data) == 0:
                    break
                client_socket.sendall(data)

        client_socket.close()
        remote_socket.close()

if __name__ == "__main__":
    server = Socks5Server()
    server.start()
