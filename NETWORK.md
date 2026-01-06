# Acceso de las VM's desde toda la red

## Maquinas de la red
sudo ip route add 192.168.122.0/24 via 192.168.0.130




## Host de VM's
sudo sysctl -w net.ipv4.ip_forward=1
sudo iptables -I FORWARD -i enp3s0 -o virbr0 -j ACCEPT
sudo iptables -I FORWARD -i virbr0 -o enp3s0 -j ACCEPT
sudo iptables -t nat -I POSTROUTING -s 192.168.122.0/24 ! -d 192.168.122.0/24 -j MASQUERADE

sudo iptables -L FORWARD -n -v --line-numbers



# OLD
## Host de VM's
sudo sysctl -w net.ipv4.ip_forward=1
sudo iptables -A FORWARD -i enp3s0 -o virbr0 -j ACCEPT
sudo iptables -A FORWARD -i virbr0 -o enp3s0 -m state --state ESTABLISHED,RELATED -j ACCEPT
sudo iptables -I FORWARD 1 -i enp3s0 -o virbr0 -d 192.168.122.0/24 -j ACCEPT
sudo iptables -I FORWARD 2 -i virbr0 -o enp3s0 -j ACCEPT
sudo iptables -t nat -A POSTROUTING -o virbr0 -d 192.168.122.0/24 -j ACCEPT
sudo iptables -t nat -A POSTROUTING -s 192.168.122.0/24 -j MASQUERADE


sudo iptables -L FORWARD -n -v --line-numbers


