# 构建阶段
FROM alpine:3.20 AS builder

# 创建必要的目录
RUN mkdir -p /etc/nginx /usr/lib/nginx/modules /var/cache/nginx /var/log/nginx /var/run/nginx /wwwroot \ 
    && apk add --no-cache git \
    && git clone -b nginx https://github.com/mina998/wpdo.git wwwroot \
    && cd wwwroot \
    && mv docker-entrypoint.sh /docker-entrypoint.sh \
    && mv docker-entrypoint.d/ /docker-entrypoint.d/ \
    && tar -zxvf nginx-1.26.2.tar.gz \
    && cd nginx-1.26.2 \
    && apk add --no-cache --virtual .build-deps build-base pcre-dev zlib-dev openssl-dev perl linux-headers \
    && ./configure \
    --prefix=/etc/nginx \
    --sbin-path=/usr/sbin/nginx \
    --modules-path=/usr/lib/nginx/modules \
    --conf-path=/etc/nginx/nginx.conf \
    --error-log-path=/var/log/nginx/error.log \
    --http-log-path=/var/log/nginx/access.log \
    --pid-path=/var/run/nginx.pid \
    --lock-path=/var/run/nginx.lock \
    --http-client-body-temp-path=/var/cache/nginx/client_temp \
    --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
    --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
    --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
    --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
    --with-perl_modules_path=/usr/lib/perl5/vendor_perl \
    --user=nginx \
    --group=nginx \
    --with-compat \
    --with-threads \
    --with-http_addition_module \
    --with-http_auth_request_module \
    --with-http_dav_module \
    --with-http_flv_module \
    --with-http_gunzip_module \
    --with-http_gzip_static_module \
    --with-http_mp4_module \
    --with-http_random_index_module \
    --with-http_realip_module \
    --with-http_secure_link_module \
    --with-http_slice_module \
    --with-http_ssl_module \
    --with-http_stub_status_module \
    --with-http_sub_module \
    --with-http_v2_module \
    --with-http_v3_module \
    --with-stream \
    --with-stream_realip_module \
    --with-stream_ssl_module \
    --with-stream_ssl_preread_module \
    --with-cc-opt='-Os -fstack-clash-protection -Wformat -Werror=format-security -fno-plt -g' \
    --with-ld-opt='-Wl,--as-needed,-O1,--sort-common -Wl,-z,pack-relative-relocs' \
    && make -j$(nproc) \
    && make install \
    # 清理构建文件
    && rm -rf /build/* \
    && apk del .build-deps \
    && cd .. && rm -rf ./*

# 最终镜像
FROM alpine:3.20
# 创建必要目录并安装运行时依赖
RUN mkdir -p /etc/nginx /usr/lib/nginx/modules /var/cache/nginx /var/log/nginx /var/run/nginx /wwwroot \ 
    && apk add --no-cache pcre zlib openssl \
    && addgroup -S nginx \
    && adduser -S nginx -G nginx \
    && chown -R nginx:nginx /etc/nginx /var/cache/nginx /var/log/nginx /var/run/nginx 


# 从构建阶段复制编译好的文件
COPY --from=builder /etc/nginx /etc/nginx \
                    /usr/sbin/nginx /usr/sbin/nginx \
                    /usr/lib/nginx/modules /usr/lib/nginx/modules

WORKDIR /wwwroot

ENTRYPOINT ["/docker-entrypoint.sh"]
EXPOSE 80 443
STOPSIGNAL SIGQUIT
CMD ["nginx", "-g", "daemon off;"]
