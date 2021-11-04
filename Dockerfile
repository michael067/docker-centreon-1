FROM centos:centos8
MAINTAINER michael <michael067@orange.fr>

# Update CentOS
RUN dnf update -y

# Install Centreon Repository
RUN dnf install -y https://yum.centreon.com/standard/21.10/el8/stable/noarch/RPMS/centreon-release-21.10-2.el8.noarch.rpm
RUN dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
RUN dnf config-manager --set-enabled 'powertools'
RUN dnf update -y

# Install centreon
RUN dnf install -y centreon centreon-database

# Install Widgets
RUN dnf install -y centreon-widget\*

RUN systemctl daemon-reload
RUN systemctl restart mariadb
RUN hostnamectl set-hostname centreon
RUN echo "date.timezone = Europe/Paris" >> /etc/php.d/50-centreon.ini
RUN systemctl restart php-fpm
RUN systemctl enable php-fpm httpd mariadb centreon cbd centengine gorgoned snmptrapd centreontrapd snmpd
RUN systemctl start httpd
