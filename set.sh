source config
source colors

for n in $NODES
do
  ip=$(getIP "$n")
  sudo sed -i "/${n}$/c\\$ip ${n}" /etc/hosts
done
