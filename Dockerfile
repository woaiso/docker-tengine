# Tengine Dockerfile

# Pull Base image.
FROM debian:jessie
LABEL Name="docker-tengine"
LABEL Version = "2.0.0"
LABEL MAINTAINER = "小富 <woaiso@woaiso.com>"

# Let the conatiner know that there is no tty
ENV DEBIAN_FRONTEND noninteractive
#Declare tengine version environment variable
ENV TENGINE_VERSION=2.3.2
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
    apt-get clean && \
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
    --group=nginx_http_group && \
    make && \
    make install && \
    # echo "\ndaemon off;">>/etc/nginx/nginx.conf && \
    chown -R nginx_http_user /etc/nginx && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

#WORKDIR /etc/nginx/sbin/
COPY ./etc/nginx/nginx.conf /etc/nginx/
COPY docker-entrypoint.sh /usr/local/bin/
RUN ln -s usr/local/bin/docker-entrypoint.sh /entrypoint.sh # backwards compat
# ADD Nginx site config and wwwroot
RUN mkdir -p /data/www /data/logs  && \
    chmod -R +x /data/www /data/logs && \
    chown -R nginx_http_user /data/www /data/logs && \
    chmod +x /usr/local/bin/docker-entrypoint.sh

VOLUME ["/data", "/etc/nginx/sites-enabled", "/etc/nginx/key"]

ENTRYPOINT ["docker-entrypoint.sh"]
EXPOSE 80 443
CMD ["nginx", "-g", "daemon off;"]