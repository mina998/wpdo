FROM php:8.3-fpm-alpine

# 构建参数和环境变量
ARG TZ="Asia/Shanghai"
ARG PHP_EXTENSIONS="pdo_mysql mysqli"
ARG ALPINE_MIRROR="dl-cdn.alpinelinux.org"

WORKDIR /wwwroot

# 系统配置和扩展安装
RUN set -ex \
    && sed -i "s/dl-cdn.alpinelinux.org/${ALPINE_MIRROR}/g" /etc/apk/repositories \
    && apk --no-cache update \
    && apk add --no-cache tzdata curl \
    && cp /usr/share/zoneinfo/${TZ} /etc/localtime \
    && echo "${TZ}" > /etc/timezone \
    && curl -sSLf -o /usr/local/bin/install-php-extensions https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions \
    && chmod +x /usr/local/bin/install-php-extensions \
    && install-php-extensions ${PHP_EXTENSIONS} \
    && curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp \
    && chmod +x /usr/local/bin/wp \
    && apk del tzdata \
    && rm -rf /var/cache/apk/* /tmp/* /usr/share/man

