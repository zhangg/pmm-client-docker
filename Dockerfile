FROM centos:latest

ENV MONIT_VERSION=5.25.2

# Compile and install monit
RUN yum -y install make gcc curl zlib-devel openssl-devel file \
    && cd /tmp \
    && curl -sS https://mmonit.com/monit/dist/monit-${MONIT_VERSION}.tar.gz | gunzip -c - | tar -xf - \
    && cd monit-${MONIT_VERSION} \
    && ./configure --without-pam \
    && make \
    && make install


FROM centos:latest
RUN yum -y install iproute https://s3-us-west-2.amazonaws.com/percona-tmp/pmm-client-1.14.0-1.el7.x86_64.rpm \
    && chown -R nobody:nobody /usr/local/percona \
    && rm -rf /var/cache/yum

COPY --from=0 /usr/local/bin/monit /usr/bin/monit
ADD --chown=nobody:nobody monitrc /etc/monitrc
RUN install -d -o nobody -g nobody /etc/monit.d /var/lib/monit /var/lib/monit/eventqueue /run /var/log /etc/rc.d/init.d

ADD service /usr/bin/service
ADD entrypoint.sh /entrypoint.sh

USER nobody
ENTRYPOINT ["/entrypoint.sh"]
