FROM nginx

COPY ./nginx.conf /etc/nginx/conf.d/reverse-proxy.conf

EXPOSE 80
