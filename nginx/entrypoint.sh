#!/bin/sh

set -e

TASK=/etc/nginx/conf.d/default.conf
touch $TASK
cat > "$TASK" <<EOF
server {

    listen 80 default_server;
    listen [::]:80 default_server;

    root /var/www/public;
    index index.php index.html index.htm;

    client_max_body_size $CLIENT_MAX_BODY_SIZE;

    location / {
        try_files $uri $uri/ /index.php$is_args$args;
    }

    location ~ \.php$ {
        try_files $uri /index.php =404;
        fastcgi_pass $PHP_FPM_HOST;
        fastcgi_buffers 16 16k;
        fastcgi_buffer_size 32k;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    }

    location ~ /\.ht { 
        deny all; 
    }

    # this include block allows adding extra config into this server block
    inlude /etc/nginx/server.d/*.conf;
}
EOF

exec "$@"
