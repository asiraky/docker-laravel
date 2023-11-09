#!/bin/sh

set -e

TASK=/etc/nginx/conf.d/default.conf
touch $TASK
cat > "$TASK" <<EOF
server {

    listen 80 default_server;
    listen [::]:80 default_server;

    root /var/www/apps/api/public;
    index index.php index.html index.htm;

    client_max_body_size $CLIENT_MAX_BODY_SIZE;

    location / {
        try_files \$uri \$uri/ /index.php\$is_args\$args;
    }

    # theoretically i should be turning off all forms of output buffering here (and in php)
    # as this nginx server is reverse proxied by a local ningx instance, and buffering 
    # should be done once there, as it is the last nginx instance in the chain that then 
    # speaks to theoritically slow clients (the browsers). having buffering between fast
    # nginx instances seems like its a waste of memory and cpu cycles and would hinder performance
    location ~ \.php$ {
        try_files \$uri /index.php =404;
        fastcgi_pass $PHP_FPM_HOST;
        fastcgi_buffers 16 16k;
        fastcgi_buffer_size 32k;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        fastcgi_pass_header 'X-Accel-Buffering';
    }

    location ~ /\.ht { 
        deny all; 
    }

    # this include block allows adding extra config into this server block
    include /etc/nginx/server.d/*.conf;
}
EOF

exec "$@"
