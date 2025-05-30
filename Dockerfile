# Use the official PHP 8.3 image with Apache
FROM php:8.4-apache

## Set working directory
WORKDIR /var/www/html

## Install dependencies and enable necessary Apache modules in a single RUN command
RUN apt-get update && apt-get install -y \
    libpng-dev \
    zip \
    unzip \
    git \
    && docker-php-ext-install pdo pdo_mysql mysqli \
    && a2enmod rewrite \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Copy the application files to the working directory
COPY ./app .

# Install PHP dependencies using Composer
RUN composer install --no-dev --optimize-autoloader --no-interaction

# Set the correct permissions for the web server
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

# Expose port 80
EXPOSE 80

# Start Apache in the foreground
CMD ["apache2-foreground"]