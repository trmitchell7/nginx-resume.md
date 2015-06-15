FROM debian:latest

MAINTAINER Thomas Mitchell

## Install Nginx, git, and markdown-resume tools
RUN export DEBIAN_FRONTEND=noninteractive && \
    echo "deb http://nginx.org/packages/ubuntu/ trusty nginx" > /etc/apt/sources.list.d/nginx.list && \
    echo "deb-src http://nginx.org/packages/ubuntu/ trusty nginx" >> /etc/apt/sources.list.d/nginx.list && \
    apt-key adv --fetch-keys "http://nginx.org/keys/nginx_signing.key" &&  \
    apt-get update && \
    apt-get -y install nginx git php5 wkhtmltopdf xvfb

## variable for your domain name, example: mysite.com (do no include the www.)
ENV NGINX_DOMAIN localhost

## template options: modern, blockish, unstyled, readable, swissen - defaults to readable
ENV TEMPLATE readable

## Configure nginx, copies default HTTP/html site to whatever domain is specified by NGINX_DOMAIN env. variable
RUN ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log && \
    mkdir -p /var/www/$NGINX_DOMAIN/html /etc/nginx/sites-available /etc/nginx/sites-enabled && \
    sed -i 's:include /etc/nginx/conf.d/.*$:include /etc/nginx/conf.d/*.conf;\n    include /etc/nginx/sites-enabled/*;:g' /etc/nginx/nginx.conf && \
    ln -s /etc/nginx/sites-available/$NGINX_DOMAIN.conf /etc/nginx/sites-enabled/$NGINX_DOMAIN.conf && \
    sed -i 's/index.html index.htm/resume.html/g' /etc/nginx/conf.d/default.conf && \
    sed -i "s/localhost/$NGINX_DOMAIN www.$NGINX_DOMAIN/g" /etc/nginx/conf.d/default.conf && \
    sed -i "0,/\/usr\/share\/nginx\/html/s//\/var\/www\/$NGINX_DOMAIN\/html/" /etc/nginx/conf.d/default.conf && \
    mv /etc/nginx/conf.d/default.conf /etc/nginx/sites-available/$NGINX_DOMAIN.conf

## configure wkhtmltopdf to work without running X, only important for generating PDFs.
RUN printf '#!/bin/bash\nxvfb-run --server-args="-screen 0, 1024x768x24" /usr/bin/wkhtmltopdf $*' > /usr/bin/wkhtmltopdf.sh && \
    chmod a+x /usr/bin/wkhtmltopdf.sh && \
    ln -s /usr/bin/wkhtmltopdf.sh /usr/local/bin/wkhtmltopdf

## Thanks to Craig Davis for creating this!
RUN git clone https://github.com/there4/markdown-resume.git

## copy in your resume.md file
COPY resume.md ./markdown-resume/examples/source/resume.md

## use Craig's tool to create the webpage and pdf
RUN ./markdown-resume/bin/md2resume html -t $TEMPLATE ./markdown-resume/examples/source/resume.md /var/www/$NGINX_DOMAIN/html && \
    ./markdown-resume/bin/md2resume pdf -t $TEMPLATE ./markdown-resume/examples/source/resume.md /var/www/$NGINX_DOMAIN/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
