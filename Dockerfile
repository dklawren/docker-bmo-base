FROM centos:6.7
MAINTAINER Dylan William Hardison <dylan@mozilla.com>

ADD https://dev.mysql.com/get/mysql-community-release-el6-5.noarch.rpm \
    /mysql-community-release-el6-5.noarch.rpm

ADD https://raw.githubusercontent.com/miyagawa/cpanminus/master/cpanm /usr/local/bin/cpanm
RUN chmod 755 /usr/local/bin/cpanm

RUN yum -y install /mysql-community-release-el6-5.noarch.rpm

COPY rpm_list /rpm_list
RUN rpm -qa --queryformat '/^%{NAME}$/ d\n' > rpm_fix.sed && \
    sed -f rpm_fix.sed /rpm_list > /rpm_list.clean

RUN yum -y install epel-release && \
    yum -y install `cat /rpm_list.clean` && \
    yum clean all

RUN wget -q https://s3.amazonaws.com/moz-devservices-bmocartons/bmo/vendor.tar.gz && \
    tar -C /opt -zxvf /vendor.tar.gz bmo/vendor/ bmo/cpanfile bmo/cpanfile.snapshot && \
    rm /vendor.tar.gz

RUN cpanm --notest --quiet Apache2::SizeLimit
WORKDIR /opt/bmo
RUN ./vendor/bin/carton install --cached --deployment
ENV PERL5LIB /opt/bmo/local/lib/perl5
