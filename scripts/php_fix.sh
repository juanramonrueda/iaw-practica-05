#!/bin/bash

set -x


#------------------------------------------------------------------------------------------------------------
# Comprobación de PHP para PrestaShop

# Creación de directorio para la descarga del comprobador de PHP
mkdir -p /tmp/php-ps-info

# Descarga de PHP PS Info en /tmp/php-ps-info
wget -P /tmp/php-ps-info https://github.com/PrestaShop/php-ps-info/archive/refs/tags/v1.1.zip

# Descompresión de la descarga de PHP PS Info en /tmp/php-ps-info
unzip /tmp/php-ps-info/v1.1.zip -d /tmp/php-ps-info

# Se mueve el archivo phppsinfo.php a /var/www/prestashop
mv /tmp/php-ps-info/php-ps-info-1.1/phppsinfo.php /var/www/prestashop

# Borrado del directorio que hemos creado en /tmp
rm -rf /tmp/php-ps-info


#------------------------------------------------------------------------------------------------------------
# Corrección de errores concretos de PHP para PrestaShop

# Correción de max_input_vars
sed -i "s/;max_input_vars = 1000/max_input_vars = 5000/" /etc/php/7.4/apache2/php.ini

# Correción de memory_limit
sed -i "s/memory_limit = 128M/memory_limit = 256M/" /etc/php/7.4/apache2/php.ini

# Correción de post_max_size
sed -i "s/post_max_size = 8M/post_max_size = 128M/" /etc/php/7.4/apache2/php.ini

# Corrección de upload_max_filesize
sed -i "s/upload_max_filesize = 2M/upload_max_filesize = 128M/" /etc/php/7.4/apache2/php.ini

# Módulos PHP necesarios para PrestaShop; el módulo php-imagick da problemas en instalación desatendida
apt install php-bcmath php-imagick php-intl php-memcached php-mbstring php-zip php-gd php-json php-curl -y

# Falta un directorio para PrestaShop
mkdir -p /var/www/prestashop/app/Resources/translations

# Módulo de Apache mod_rewrite
a2enmod rewrite

# Cambio de propietario y grupo para /var/www/html
chown -R www-data:www-data /var/www/prestashop

# Reinicio de Apache para que se apliquen los cambios anteriores
systemctl restart apache2
