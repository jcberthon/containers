FROM centos:7

RUN yum -y install epel-release less vim && yum clean all

RUN yum -y makecache fast && yum -y install \
      monitorix \
      iptables \
      net-tools \
      ntp \
      pango \
    && yum clean all

#RUN yum -y install supervisor && yum clean all

#COPY supervisord.conf /etc/supervisord.d/supervisord.ini

#CMD ["/usr/bin/supervisord"]

EXPOSE 8080

VOLUME ["/var/lib/monitorix/", "/var/lib/monitorix/www"]

CMD ["/usr/bin/monitorix", "-n", "-c", "/etc/monitorix/monitorix.conf", "-p", "/run/monitorix.pid"]
