# Usa una imagen base con PHP y extensiones necesarias
FROM php:7.3-fpm

# Instala dependencias y extensiones PHP necesarias
RUN apt-get update && \
    apt-get install -y libpng-dev libjpeg-dev libfreetype6-dev libzip-dev git unzip libonig-dev && \
    docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ && \
    docker-php-ext-install gd zip pdo pdo_mysql

# Instala Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Configura el directorio de trabajo
WORKDIR /var/www/html

# Copia todos los archivos del proyecto al contenedor
COPY . .

# Instala Node.js 14.x y una versión compatible de npm
RUN curl -fsSL https://deb.nodesource.com/setup_14.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g npm@6

# Instala las dependencias de PHP usando Composer
RUN composer install --no-scripts --no-autoloader

# Instala las dependencias de JavaScript usando npm
RUN npm install

# Instala Xdebug 2.8.x compatible con PHP 7.3
RUN pecl channel-update pecl.php.net && \
    pecl install xdebug-2.8.1 && \
    docker-php-ext-enable xdebug

# Ejecuta la construcción de assets de Laravel
RUN npm run prod

# Expone el puerto 9000 para PHP-FPM
EXPOSE 9000

# Comando para ejecutar el servidor PHP-FPM
CMD ["php-fpm"]
