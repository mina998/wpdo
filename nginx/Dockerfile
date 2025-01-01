FROM nginx:1.26-alpine

WORKDIR /wwwroot

# 拷贝 SSL 证书文件到容器的 /etc 目录
COPY example.crt /etc/
COPY example.key /etc/
COPY phpMyAdmin.conf /etc/nginx/phpMyAdmin.conf

