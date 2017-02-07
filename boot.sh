#!/bin/bash
if [ ! -f /root/ready ]; then
	apt-get install stunnel4 -y
	cat > /etc/stunnel/stunnel.conf <<END
[ssh]
accept = 443
connect = 127.0.0.1:22
cert = /etc/stunnel/stunnel.pem
END
	openssl genrsa -out key.pem 2048
	yes "" | openssl req -new -x509 -key key.pem -out cert.pem -days 1095
	cat key.pem cert.pem >> /etc/stunnel/stunnel.pem
	sed -i -e 's/ENABLED=0/ENABLED=1/' /etc/default/stunnel4
	/etc/init.d/stunnel4 restart

	#useradd -m jump
	#sudo -u jump mkdir ~jump/.ssh
	#sudo -u jump echo 'SSHKEY' > ~jump/.ssh/authorized_keys	
	touch /root/ready;
fi
