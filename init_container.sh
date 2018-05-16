#!/bin/bash
cat >/etc/motd <<EOL

________ __________ ____ _____________  _____  .____
\______ \\______    \    |   \______   \/  _  \ |    |
 |    |  \|       _/    |   /|     ___/  /_\  \|    |
 |    \`   \    |   \    |  / |    |  /    |    \    |___
/_______  /____|_  /______/  |____|  \____|__  /_______ \\
        \/       \/                          \/        \/
                               .__       .__
    ___  _______ _______  ____ |__| _____|  |__
    \  \/ /\__  \\_  __ \/    \|  |/  ___/  |  \\
     \   /  / __ \|  | \/   |  \  |\___ \|   Y  \\
      \_/  (____  /__|  |___|  /__/____  >___|  /
                \/           \/        \/     \/

       A P P   S E R V I C E   O N   L I N U X

Documentation: http://aka.ms/webapp-linux


EOL
cat /etc/motd


# Get environment variables to show up in SSH session
eval $(printenv | awk -F= '{print "export " $1"="$2 }' >> /etc/profile)


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
