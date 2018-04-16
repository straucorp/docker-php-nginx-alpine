# Usaremos o container do Alpine que é considerávelmente
# menor do Debian ou Ubuntu
FROM alpine:3.7

# dizer aos outros quem é o mantenedor dela. No meu caso:
MAINTAINER Andre Straube

# Instalando os pacotes necessários
RUN apk --update add --no-cache \
        tzdata \
        nginx \
        curl \
        supervisor \
        gd \
        freetype \
        libpng \
        libjpeg-turbo \
        freetype-dev \
        libpng-dev \
        nodejs \
        git \
        php7 \
        php7-dom \
        php7-fpm \
        php7-mbstring \
        php7-mcrypt \
        php7-opcache \
        php7-pdo \
        php7-pdo_mysql \
        php7-pdo_pgsql \
        php7-pdo_sqlite \
        php7-tokenizer \
        php7-xml \
        php7-phar \
        php7-openssl \
        php7-json \
        php7-curl \
        php7-ctype \
        php7-session \
        php7-gd \
        php7-zlib

# Limpando o cache das instalações
RUN rm -Rf /var/cache/apk/*

# Configuring timezones
RUN cp /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
RUN echo "America/Sao_Paulo" >  /etc/timezone
RUN apk del tzdata && rm -rf /var/cache/apk/*

# Instalando composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer

# Configurando o Nginx
COPY config/nginx/nginx.conf /etc/nginx/nginx.conf
COPY config/nginx/default /etc/nginx/sites-enabled/default

# Configure PHP-FPM
COPY config/php/php.ini /etc/php7/php.ini
COPY config/php/www.conf /etc/php7/php-fpm.d/www.conf

# Configure supervisord
COPY config/supervisord.conf /etc/supervisord.conf

# Criando o diretório onde ficará a aplicação
RUN mkdir -p /app

# Definindo o diretório app como nosso diretório de trabalho
WORKDIR /app

# Coping PHP example files
COPY src/ /app/

# Set UID for www user to 1000
RUN addgroup -g 1000 -S www \
    && adduser -u 1000 -D -S -G www -h /app -g www www \
    && chown -R www:www /var/lib/nginx

# Dando permissões para a pasta do projeto
RUN chmod -R 755 /app

# Expondo as portas
EXPOSE 80 443

# Start Supervisord
ADD start.sh /start.sh
RUN chmod +x /start.sh

# Start Supervisord
CMD ["/start.sh"]
