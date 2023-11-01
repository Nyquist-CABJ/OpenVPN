#!/bin/bash
number_of_clients=$(tail -n +2 /etc/openvpn/server/easy-rsa/pki/index.txt | grep -c "^V")
if [[ "$number_of_clients" = 0 ]]; then
        echo
        echo "No existen clientes!"
        exit
fi
echo
echo "Seleccione el cliente a eliminar:"
tail -n +2 /etc/openvpn/server/easy-rsa/pki/index.txt | grep "^V" | cut -d '=' -f 2 | nl -s ') '
read -p "Cliente: " client_number
until [[ "$client_number" =~ ^[0-9]+$ && "$client_number" -le "$number_of_clients" ]]; do
        echo "$client_number: Seleccion invalida."
        read -p "Cliente: " client_number
done
client=$(tail -n +2 /etc/openvpn/server/easy-rsa/pki/index.txt | grep "^V" | cut -d '=' -f 2 | sed -n "$client_number"p)
echo
read -p "Desea continuar con la eliminacion de $client? [y/N]: " revoke
until [[ "$revoke" =~ ^[yYnN]*$ ]]; do
        echo "$revoke: Seleccion Invalida."
        read -p "Confirmar la revocacion de $client? [y/N]: " revoke
done
if [[ "$revoke" =~ ^[yY]$ ]]; then
        cd /etc/openvpn/server/easy-rsa/
        ./easyrsa --batch revoke "$client"
        ./easyrsa --batch --days=3650 gen-crl
        rm -f /etc/openvpn/server/crl.pem
        cp /etc/openvpn/server/easy-rsa/pki/crl.pem /etc/openvpn/server/crl.pem
        chown nobody:"$group_name" /etc/openvpn/server/crl.pem
        echo
        echo "$client Eliminado!"
else
        echo
        echo "$client revocacion abortada!"
fi
rm /etc/openvpn/client/"$client".ovpn
exit
