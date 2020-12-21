FROM centos:centos7
MAINTAINER pmietlicki <pmietlicki@gmail.com>

# Update CentOS
RUN yum -y update

# Install Centreon Repository
RUN yum install -y centos-release-scl
RUN yum install -y http://yum.centreon.com/standard/20.10/el7/stable/noarch/RPMS/centreon-release-20.10-2.el7.centos.noarch.rpm

# Install centreon
RUN yum -y install centreon centreon-database centreon-base-config-centreon-engine centreon-installed centreon-clapi 

# Install Widgets
RUN yum -y install centreon-widget-graph-monitoring centreon-widget-host-monitoring centreon-widget-service-monitoring centreon-widget-hostgroup-monitoring centreon-widget-servicegroup-monitoring

# Fix pass in db
ADD scripts/cbmod.sql /tmp/cbmod.sql
RUN /usr/bin/mysqld_safe --datadir=/var/lib/mysql && sleep 5 
RUN mysql centreon < /tmp/cbmod.sql && /usr/bin/centreon -u admin -p centreon -a POLLERGENERATE -v 1 && /usr/bin/centreon -u admin -p centreon -a CFGMOVE -v 1 
RUN /usr/bin/mysqladmin shutdown

# Set rights for setuid
RUN chown root:centreon-engine /usr/lib/nagios/plugins/check_icmp
RUN chmod -w /usr/lib/nagios/plugins/check_icmp
RUN chmod u+s /usr/lib/nagios/plugins/check_icmp

# Install and configure supervisor
RUN yum -y install python3-setuptools
RUN easy_install-3.6 supervisor

# Todo better split file
ADD scripts/supervisord.conf /etc/supervisord.conf

# Expose 80 for the httpd service.
EXPOSE 80

# Make them easier to snapshot and backup.
VOLUME ["/usr/share/centreon/", "/usr/lib/nagios/plugins/", "/var/lib/mysql"]

# Must use double quotes for json formatting.
CMD ["/usr/bin/supervisord", "--configuration=/etc/supervisord.conf"]
