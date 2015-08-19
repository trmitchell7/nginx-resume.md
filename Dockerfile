FROM debian:latest

MAINTAINER Thomas Mitchell

## Install Nginx, git, PDF generator, supervisor, and Openresty
RUN export DEBIAN_FRONTEND=noninteractive && \
    echo "deb http://nginx.org/packages/ubuntu/ trusty nginx" > /etc/apt/sources.list.d/nginx.list && \
    echo "deb-src http://nginx.org/packages/ubuntu/ trusty nginx" >> /etc/apt/sources.list.d/nginx.list && \
    apt-key adv --fetch-keys "http://nginx.org/keys/nginx_signing.key" &&  \
    apt-get update && \
    apt-get -y install nginx wget git php5 supervisor wkhtmltopdf xvfb libreadline-dev libncurses5-dev libpcre3-dev libssl-dev perl make build-essential

## Compile openresty from source.
RUN wget http://openresty.org/download/ngx_openresty-1.7.10.2.tar.gz && \
    tar -xzvf ngx_openresty-*.tar.gz && \
    rm -f ngx_openresty-*.tar.gz && \
    cd ngx_openresty-* && \
    ./configure --with-pcre-jit --with-ipv6 && \
    make && \
    make install && \
    make clean && \
    cd .. && \
    rm -rf ngx_openresty-*&& \
    ln -s /usr/local/openresty/nginx/sbin/nginx /usr/local/bin/nginx && \
    ldconfig

## variable for your domain name, example: mysite.com (do no include the www.)
ENV NGINX_DOMAIN localhost

## template options: modern, blockish, unstyled, readable, swissen - change here and rebuild container
ENV TEMPLATE readable

## option for google analytics tag
ENV ANALYTICS UA-00000000-1

## configure wkhtmltopdf to work without running X, only important for generating PDFs.
RUN printf '#!/bin/bash\nxvfb-run --server-args="-screen 0, 1024x768x24" /usr/bin/wkhtmltopdf $*' > /usr/bin/wkhtmltopdf.sh && \
    chmod a+x /usr/bin/wkhtmltopdf.sh && \
    ln -s /usr/bin/wkhtmltopdf.sh /usr/local/bin/wkhtmltopdf

## Thanks to Craig Davis for creating this!
RUN git clone https://github.com/there4/markdown-resume.git

EXPOSE 80

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY run.sh /run.sh

CMD ["/usr/bin/supervisord"]
