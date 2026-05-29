FROM php:8.3-fpm-alpine

# Instala extensões necessárias
RUN apk add --no-cache \
    postgresql-dev \
    libpq \
    && docker-php-ext-install pdo pdo_pgsql \
    && docker-php-ext-enable pdo_pgsql

# Configura PHP para produção
RUN cp "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini" \
    && sed -i 's/display_errors = On/display_errors = Off/' "$PHP_INI_DIR/php.ini" \
    && sed -i 's/expose_php = On/expose_php = Off/' "$PHP_INI_DIR/php.ini"

# Instala o Composer v2 globalmente
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Diretório de trabalho
WORKDIR /var/www/html

# Copia código
COPY . .

# Cria diretório de logs e ajusta permissões antes de mudar de usuário
RUN mkdir -p /var/log/hotel \
    && chown -R www-data:www-data /var/log/hotel /var/www/html

# Garante a instalação/atualização das dependências automaticamente ao iniciar o container
CMD sh -c "composer install --no-dev --optimize-autoloader --no-interaction && php-fpm"

USER www-data

EXPOSE 9000