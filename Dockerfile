FROM dockerhub.cisco.com/mobile-cnat-docker-dev/mobile-cnat-infrastructure/releases/ubuntu-base/18.04.1/ubuntu-base:18.04.1

RUN apt-get-update && \
    apt-get install --no-install-recommends --allow-unauthenticated -y apache2 sudo ldap-utils \
    libapache2-mod-authnz-external pwauth libapache2-mod-authz-unixgroup apache2-utils && \
    apt-get install -y --no-install-recommends curl libssl1.0.0 libc6 libgcc1 python-pip  python-setuptools && \
    pip install envtpl pyyaml && \
    apt-cleanup && \
    a2enmod authnz_external authz_unixgroup proxy_http proxy proxy_balancer lbmethod_byrequests proxy_html && \
    a2enmod authn_socache xml2enc && \
    a2enmod socache_shmcb && \
    groupmod -g 110 www-data && \
    usermod -u 110 www-data && \
    usermod --groups sudo www-data

RUN mkdir -p /var/lock/apache2  && chown www-data:www-data /var/lock/apache2

ADD scripts/pwauth /usr/sbin/pwauth

COPY config/apache.conf /etc/apache2/apache2.conf

COPY scripts/apache-init /usr/local/bin/apache-init

COPY config/kibana-proxy.conf /etc/apache2/mods-enabled/kibana-proxy.conf

COPY config/sudoers /etc/sudoers
RUN chmod 755 /etc/sudoers

ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_PID_FILE /var/run/apache2/apache
ENV APACHE_RUN_DIR /var/run/apache2

ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data

CMD ["/usr/local/bin/apache-init"]
