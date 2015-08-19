FROM debian:latest

MAINTAINER Thomas Mitchell

## Install Nginx, git, PDF generator, supervisor, and Openresty
RUN export DEBIAN_FRONTEND=noninteractive && \
    echo "deb http://nginx.org/packages/ubuntu/ trusty nginx" > /etc/apt/sources.list.d/nginx.list && \
    echo "deb-src http://nginx.org/packages/ubuntu/ trusty nginx" >> /etc/apt/sources.list.d/nginx.list && \
    apt-key adv --fetch-keys "http://nginx.org/keys/nginx_signing.key" &&  \
    apt-get update && \
    apt-get -y install nginx wget git php5 supervisor wkhtmltopdf xvfb

## variable for your domain name, example: mysite.com (do no include the www.)
ENV NGINX_DOMAIN localhost

## template options: modern, blockish, unstyled, readable, swissen - defaults to readable
ENV TEMPLATE readable

## option for google analytics tag
ENV ANALYTICS UA-00000000-1

## configure wkhtmltopdf to work without running X, only important for generating PDFs.
RUN printf '#!/bin/bash\nxvfb-run --server-args="-screen 0, 1024x768x24" /usr/bin/wkhtmltopdf $*' > /usr/bin/wkhtmltopdf.sh && \
    chmod a+x /usr/bin/wkhtmltopdf.sh && \
    ln -s /usr/bin/wkhtmltopdf.sh /usr/local/bin/wkhtmltopdf

## clone Craig Davis's markdown to html scripts
RUN git clone https://github.com/there4/markdown-resume.git

EXPOSE 80

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY run.sh /run.sh

CMD ["/usr/bin/supervisord"]
