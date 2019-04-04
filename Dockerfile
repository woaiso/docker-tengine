# Tengine Dockerfile

# Pull Base image.
FROM debian:jessie
LABEL MAINTAINER = "小富 <woaiso@woaiso.com>"

# Let the conatiner know that there is no tty
ENV DEBIAN_FRONTEND noninteractive
#Declare tengine version environment variable
ENV TENGINE_VERSION=2.3.0
# 使用阿里云的apt镜像
RUN mv /etc/apt/sources.list /etc/apt/sources.list.bak && \
    echo "deb http://mirrors.aliyun.com/debian stretch main contrib non-free" >/etc/apt/sources.list && \
    echo "deb http://mirrors.aliyun.com/debian stretch-proposed-updates main contrib non-free" >>/etc/apt/sources.list && \
    echo "deb http://mirrors.aliyun.com/debian stretch-updates main contrib non-free" >>/etc/apt/sources.list && \
    echo "deb-src http://mirrors.aliyun.com/debian stretch main contrib non-free" >>/etc/apt/sources.list && \
    echo "deb-src http://mirrors.aliyun.com/debian stretch-proposed-updates main contrib non-free" >>/etc/apt/sources.list && \
    echo "deb-src http://mirrors.aliyun.com/debian stretch-updates main contrib non-free" >>/etc/apt/sources.list && \
    echo "deb http://mirrors.aliyun.com/debian-security/ stretch/updates main non-free contrib" >>/etc/apt/sources.list && \
    echo "deb-src http://mirrors.aliyun.com/debian-security/ stretch/updates main non-free contrib" >>/etc/apt/sources.list

#Install basic requirements
RUN apt-get update -y && \
    apt-get install -y apt-utils wget gcc libssl-dev libpcre3-dev zlib1g-dev curl vim make && \
    #Create nginx_http_user for nginx
    adduser \
    --disabled-login \
    --no-create-home \
    --gecos 'Tengine_Http_User' \
    nginx_http_user


WORKDIR /tmp/
#Download tengine and 
RUN wget http://tengine.taobao.org/download/tengine-$TENGINE_VERSION.tar.gz && \
    tar zxvf tengine-$TENGINE_VERSION.tar.gz && \
    rm tengine-$TENGINE_VERSION.tar.gz


WORKDIR /tmp/tengine-$TENGINE_VERSION

RUN ./configure \
    --prefix=/etc/nginx \
    --with-http_ssl_module  \
    --with-http_v2_module  \
    --conf-path=/etc/nginx/nginx.conf \
    --sbin-path=/usr/bin/nginx \
    --user=nginx_http_user \
    --group=nginx_http_user && \
    make && \
    make install && \
    # echo "\ndaemon off;">>/etc/nginx/nginx.conf && \
    chown -R nginx_http_user /etc/nginx && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

#WORKDIR /etc/nginx/sbin/
ADD ./etc/nginx/nginx.conf /etc/nginx/
# ADD Nginx site config and wwwroot
RUN mkdir -p /data/www /data/sites_conf /data/ssl && \
    chmod -R +x /data/www /data/sites_conf /data/ssl && \
    chown -R nginx_http_user /data/www /data/sites_conf /data/ssl

COPY data/ /data/

EXPOSE 80 443

VOLUME ["/data"]

CMD ["nginx"]
