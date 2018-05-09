#!/bin/bash
cat >/etc/motd <<EOL

   _____  ______________ ________________________
  /  _  \ \____    /    |   \______   \_   _____/
 /  /_\  \  /     /|    |   /|       _/|    __)_
/    |    \/     /_|    |  / |    |   \|        \\
\____|__  /_______ \______/  |____|_  /_______  /
        \/        \/                \/        \/

     A P P   S E R V I C E   O N   L I N U X

Documentation: http://aka.ms/webapp-linux


EOL
cat /etc/motd


# Get environment variables to show up in SSH session
eval $(printenv | awk -F= '{print "export " $1"="$2 }' >> /etc/profile)


# PREPARE AND START SSHD
# see https://github.com/danielguerra69/alpine-sshd/blob/master/docker-entrypoint.sh
if [ ! -f "/etc/ssh/ssh_host_rsa_key" ]; then
	# generate fresh rsa key
	ssh-keygen -f /etc/ssh/ssh_host_rsa_key -N '' -t rsa
fi
if [ ! -f "/etc/ssh/ssh_host_dsa_key" ]; then
	# generate fresh dsa key
	ssh-keygen -f /etc/ssh/ssh_host_dsa_key -N '' -t dsa
fi
if [ ! -f "/etc/ssh/ssh_host_ecdsa_key" ]; then
	# generate fresh ecdsa key
	ssh-keygen -f /etc/ssh/ssh_host_ecdsa_key -N '' -t ecdsa
fi
if [ ! -f "/etc/ssh/ssh_host_ed25519_key" ]; then
	# generate fresh ed25519 key
	ssh-keygen -f /etc/ssh/ssh_host_ed25519_key -N '' -t ed25519
fi


# prepare run dir
if [ ! -d "/var/run/sshd" ]; then
  mkdir -p /var/run/sshd
fi


# run sshd in background
/usr/sbin/sshd -D &



# PREPARE AND START STUNNEL
sed -i "s/{VARNISH_BACKEND_PORT}/${VARNISH_BACKEND_PORT}/g" /etc/stunnel/stunnel.conf
sed -i "s/{STUNNEL_BACKEND_HOST}/${STUNNEL_BACKEND_HOST}/g" /etc/stunnel/stunnel.conf
sed -i "s/{STUNNEL_BACKEND_PORT}/${STUNNEL_BACKEND_PORT}/g" /etc/stunnel/stunnel.conf
/usr/bin/stunnel /etc/stunnel/stunnel.conf



# PREPARE AND START VARNISH
# see https://github.com/wodby/varnish/blob/master/entrypoint.sh
function exec_tpl {
    if [[ -f "/etc/gotpl/$1" ]]; then
        gotpl "/etc/gotpl/$1" > "$2"
    fi
}

check_varnish_secret() {
    if [[ -z "${VARNISH_SECRET}" ]]; then
        export VARNISH_SECRET=$(pwgen -s 128 1)
        echo "Generated Varnish secret: ${VARNISH_SECRET}"
    fi
}

process_templates() {
    exec_tpl 'varnishd.init.d.tpl' '/etc/init.d/varnishd'
    exec_tpl 'secret.tpl' '/etc/varnish/secret'
    exec_tpl 'default.vcl.tpl' '/etc/varnish/default.vcl'
}

check_varnish_secret
process_templates

exec-init-scripts.sh


# execute CMD
exec "$@"
