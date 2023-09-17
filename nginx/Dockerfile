FROM nginx:alpine

ENV CLIENT_MAX_BODY_SIZE=20M
ENV PHP_FPM_HOST=127.0.0.1:9000

# install certbot
RUN apk add certbot certbot-nginx

RUN rm -rf /etc/nginx/conf.d/default.conf
RUN rm -rf /etc/nginx/sites-enabled/default
RUN rm -rf /etc/nginx/sites-available/default

COPY ./nginx/nginx.conf /etc/nginx/nginx.conf

WORKDIR /var/www

EXPOSE 80

COPY ./nginx/entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

CMD ["nginx", "-g", "daemon off;"]
