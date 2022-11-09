#!bin/bash

set -x

#-----------------------------------------------------------------------------------------------------------------------------
# Declaración de variables locales

# Variable para phpMyAdmin
PHPMYADMIN_APP_PASSWORD=phpmyadmin_password

# Variables para creación de base de datos con usuario y contraseña
database_prestashop=DB_PrestaShop
database_user=Usuario_PrestaShop
database_password=Password_PrestaShop


#-----------------------------------------------------------------------------------------------------------------------------
# Instalación de Unzip para descomprimir en formato .zip
apt-get install unzip -y


#-----------------------------------------------------------------------------------------------------------------------------
# Preconfiguración e instalación de phpMyAdmin

# Configuración de las respuestas de instalación desatendida de phpMyAdmin
echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2" | debconf-set-selections
echo "phpmyadmin phpmyadmin/dbconfig-install boolean true" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/app-pass password $PHPMYADMIN_APP_PASSWORD" | debconf-set-selections
echo "phpmyadmin phpmyadmin/app-password-confirm password $PHPMYADMIN_APP_PASSWORD" | debconf-set-selections

# Instalación de phpMyAdmin
apt install phpmyadmin -y


#-----------------------------------------------------------------------------------------------------------------------------
# Creación de la base de datos con usuario y contraseña para PrestaShop
echo "DROP DATABASE IF EXISTS $database_prestashop;" | mysql -u root
echo "CREATE DATABASE $database_prestashop CHARSET utf8mb4;" | mysql -u root
echo "USE $database_prestashop;" | mysql -u root

echo "CREATE USER IF NOT EXISTS '$database_user'@'%' IDENTIFIED BY '$database_password';" | mysql -u root
echo "GRANT ALL PRIVILEGES ON $database_prestashop.* TO '$database_user'@'%';" | mysql -u root


#-----------------------------------------------------------------------------------------------------------------------------
# Descarga de archivos de PrestaShop

# Creación de directorio para PrestaShop
mkdir -p /var/www/prestashop

# Creación de directorio en el directorio temporal para almacenar los archivos que se generen en la descarga y descompresión
mkdir -p /tmp/prestashop

# Cambio del directorio que sirve por defecto los sitios web de Apache
sed -i 's|DocumentRoot /var/www/html|DocumentRoot /var/www/prestashop|' /etc/apache2/sites-available/000-default.conf

# Descarga del paquete completo de PrestaShop en /tmp/prestashop
wget -P /tmp/prestashop https://github.com/PrestaShop/PrestaShop/releases/download/8.0.0/prestashop_8.0.0.zip

# Descompresión de PrestaShop en el mismo directorio
unzip /tmp/prestashop/prestashop_8.0.0.zip -d /tmp/prestashop

# Descompresión de los archivos necesarios de PrestaShop en /var/www/html usando el modificador -d
unzip /tmp/prestashop/prestashop.zip -d /var/www/prestashop

# Borrado de todos los archivos y directorios que se han descomprimido en /tmp/prestashop
rm -rf /tmp/prestashop


#-----------------------------------------------------------------------------------------------------------------------------
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


#----------------------------------------------------------------------------------------------------------------------
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
