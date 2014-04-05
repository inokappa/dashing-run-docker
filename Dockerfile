FROM centos
MAINTAINER Yohei Kawahara "inokara@gmail.com"
#
RUN yum -y install gcc zlib-devel openssl-devel sqlite sqlite-devel gcc-c++ openssh-server sudo
RUN cd /usr/local/src && wget http://cache.ruby-lang.org/pub/ruby/2.1/ruby-2.1.1.tar.gz
RUN cd /usr/local/src && tar zxvf ruby-2.1.1.tar.gz && cd ruby-2.1.1 && ./configure && make && make install
RUN gem install dashing --no-ri --no-rdoc -V
RUN gem install bundler --no-ri --no-rdoc -V
#
RUN rpm -ivh http://ftp.riken.jp/Linux/fedora/epel/6/x86_64/epel-release-6-8.noarch.rpm
RUN yum install -y nodejs npm --enablerepo=epel
#
RUN yum install -y http://pkgs.repoforge.org/monit/monit-5.5-1.el6.rf.x86_64.rpm
RUN echo "NETWORKING=yes" >/etc/sysconfig/network
#
#
RUN cd / && dashing new dashing
RUN cd /dashing && bundle
#
ADD dashing-start /root/
RUN chmod 755 /root/dashing-start
RUN chown root:root /root/dashing-start
ADD monit.conf /etc/
RUN chmod 600 /etc/monit.conf && chown root:root /etc/monit.conf
ADD dashing.conf.monit /etc/monit.d/dashing.conf
ADD sshd.conf.monit /etc/monit.d/sshd.conf
RUN chmod 600 /etc/monit.d/* && chown root:root /etc/monit.d/*
#
RUN useradd -d /home/sandbox -m -s /bin/bash sandbox
RUN echo sandbox:sandbox | chpasswd
RUN echo 'sandbox ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
RUN sed -i 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config
RUN sed -i 's/#UsePAM no/UsePAM no/g' /etc/ssh/sshd_config
## for dashing
EXPOSE 3030
# for ssh
EXPOSE 22
# for monit
EXPOSE 2812
#
CMD ["/usr/bin/monit", "-I", "-c", "/etc/monit.conf"]
