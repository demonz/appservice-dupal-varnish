FROM wodby/drupal-varnish:4.1

MAINTAINER Demonz Media <hello@demonzmedia.com>


RUN apk add --update --no-cache --virtual .varnish-rundeps \
  openssh-server vim wget stunnel


COPY init_container.sh /bin/
COPY sshd_config /etc/ssh/
COPY stunnel.conf /etc/stunnel/


RUN echo "root:Docker!" | chpasswd \
  && chmod 755 /bin/init_container.sh


EXPOSE 2222 6081

ENTRYPOINT ["/bin/init_container.sh"]
CMD ["/etc/init.d/varnishd"]
