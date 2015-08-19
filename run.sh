#!/bin/bash
set -o nounset
set -o errexit

## log no-daemon to var/log
mkdir -p /var/www/resume/html /etc/nginx/sites-available /etc/nginx/sites-enabled /volume
ln -sf /dev/stdout /var/log/nginx/access.log
ln -sf /dev/stderr /var/log/nginx/error.log
ln -s /etc/nginx/sites-available/resume.conf /etc/nginx/sites-enabled/resume.conf

## modify default config to suit us
sed -i 's:include /etc/nginx/conf.d/.*$:include /etc/nginx/conf.d/*.conf;\n    include /etc/nginx/sites-enabled/*;:g' /etc/nginx/nginx.conf
sed -i 's/index.html index.htm/resume.html/g' /etc/nginx/conf.d/default.conf
sed -i "s>localhost>${NGINX_DOMAIN%/*} www.${NGINX_DOMAIN%/*}>g" /etc/nginx/conf.d/default.conf
sed -i "s>location />location /${NGINX_DOMAIN#*/}/>g" /etc/nginx/conf.d/default.conf
sed -i "0,/\/usr\/share\/nginx\/html/s//\/var\/www\/resume\/html/" /etc/nginx/conf.d/default.conf

cp /etc/nginx/conf.d/default.conf /etc/nginx/sites-available/resume.conf

## copy in your resume.md file to the volume
if [ -s /volume/resume.md ];
then
    cp /volume/resume.md /markdown-resume/examples/source/resume.md
else
    echo -e "WARNING: No resume.md file found on volume, using sample..."
    cp /volume/{sample,resume}.md
fi

## use Craig's tool to create the webpage and pdf
./markdown-resume/bin/md2resume html -t $TEMPLATE /volume/resume.md /var/www/resume/html
./markdown-resume/bin/md2resume pdf -t $TEMPLATE /volume/resume.md /var/www/resume/html

## Add google analytics
echo "<script>\n\t(function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){\n\t(i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),\n\tm=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)\n\t})(window,document,'script','//www.google-analytics.com/analytics.js','ga');\n\n\tga('create', '$ANALYTICS', 'auto');\n\tga('send', 'pageview');\n\n</script>" >> /var/www/resume/html/resume.html

## reload nginx to make sure that the config changes all made it in (required because supervisord starts them simultaneously)
sleep 2 && nginx -s reload

echo -e "Finished with run.sh"
