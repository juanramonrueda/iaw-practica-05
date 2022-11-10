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
# Instalación de Certbot y obtención de TLS

# Instalación de snapd
snap install core

# Actualización de snapd
snap refresh core

# Desinstalación de Certbot por si hubiese uno de antes
apt-get remove certbot

# Instalación de cliente de Certbot
snap install --classic certbot

# Creación de alias para Certbot
ln -s /snap/bin/certbot /usr/bin/certbot


#-----------------------------------------------------------------------------------------------------------------------------
# Creación de directorio para alojar PrestaShop
mkdir -p /var/www/prestashop