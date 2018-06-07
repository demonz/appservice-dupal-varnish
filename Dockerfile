FROM wodby/drupal-varnish:4.1

# CUSTOM
# Add ssh server for access via Azure portal
# Customise init_container.sh to start sshd and

MAINTAINER Demonz Media <hello@demonzmedia.com>

# install and prepare sshd and stunnel
# change root password to allow login via azure portal
RUN set -ex; \
    \
    apk add --no-cache \
      openssh-server stunnel vim; \
    \
    # generate keys
    ssh-keygen -f /etc/ssh/ssh_host_rsa_key -N '' -t rsa; \
    ssh-keygen -f /etc/ssh/ssh_host_dsa_key -N '' -t dsa; \
    ssh-keygen -f /etc/ssh/ssh_host_ecdsa_key -N '' -t ecdsa; \
    ssh-keygen -f /etc/ssh/ssh_host_ed25519_key -N '' -t ed25519; \
    \
    # prepare run dir
    mkdir -p /var/run/sshd; \
    \
    # change root password to allow login via azure portal
    echo "root:Docker!" | chpasswd;


# override upstream default.vcl.tpl
COPY default.vcl.tpl /etc/gotpl/

COPY init_container.sh /bin/
COPY sshd_config /etc/ssh/
COPY stunnel.conf /etc/stunnel/


RUN set -ex; \
    chmod 755 /bin/init_container.sh


ENV VARNISH_BACKEND_HOST='127.0.0.1' \
  VARNISH_BACKEND_PORT='80'


WORKDIR /home

EXPOSE 2222 6081

ENTRYPOINT ["/bin/init_container.sh"]
CMD ["/etc/init.d/varnishd"]
