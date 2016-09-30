FROM centos:7

RUN yum -y install epel-release less vim && yum clean all

RUN yum -y makecache fast && yum -y install \
      monitorix \
      iptables \
      net-tools \
    && yum clean all

RUN yum -y install supervisor && yum clean all

#COPY supervisord.conf /etc/supervisord.d/supervisord.ini

COPY fs.conf /etc/monitorix/conf.d/fs.conf

#CMD ["/usr/bin/supervisord"]

CMD ["/usr/bin/monitorix", "-n", "-c", "/etc/monitorix/monitorix.conf", "-p", "/run/monitorix.pid"]
