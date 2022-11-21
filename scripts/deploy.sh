#!bin/bash

set -x


#----------------------------------------------------------------------------------------------------------------------------
# Declaración de variables locales

email_certbot_prestashop=tetz_dqhwr17@yutep.com
address_domain=practicasiawjrrl.ddns.net

prestashop_language_country=es
prestashop_shop_name="Tienda PrestaShop JRRL"
prestashop_activity=7
ssl_state=1
admin_firstname="Juan Ramón"
admin_lastname="Rueda Lao"
admin_password_back_office=@Admin123#
database_mysql_server=127.0.0.1
database_name=DB_PrestaShop
database_user=Usuario_PrestaShop
database_password=Password_PrestaShop
database_prefix=P_S_


#----------------------------------------------------------------------------------------------------------------------------
# Obtención de TLS
certbot --apache -m $email_certbot_prestashop --agree-tos --no-eff-email -d $address_domain


#----------------------------------------------------------------------------------------------------------------------------
# Preparación y descarga de archivos de PrestaShop


# Cambio del directorio que sirve por defecto los sitios web de Apache
sed -i 's|DocumentRoot /var/www/html|DocumentRoot /var/www/prestashop|' /etc/apache2/sites-available/000-default.conf

# Cambio del directorio que sirve por defecto los sitios web de Apache mediante TLS
sed -i 's|DocumentRoot /var/www/html|DocumentRoot /var/www/prestashop|' /etc/apache2/sites-available/000-default-le-ssl.conf

# Creación de directorio en el directorio temporal para almacenar los archivos que se generen en la descarga y descompresión
mkdir -p /tmp/prestashop

# Descarga del paquete completo de PrestaShop en /tmp/prestashop
wget -P /tmp/prestashop https://github.com/PrestaShop/PrestaShop/releases/download/8.0.0/prestashop_8.0.0.zip

# Descompresión de PrestaShop en el mismo directorio
unzip /tmp/prestashop/prestashop_8.0.0.zip -d /tmp/prestashop

# Descompresión de los archivos necesarios de PrestaShop en /var/www/html usando el modificador -d
unzip /tmp/prestashop/prestashop.zip -d /var/www/prestashop

# Cambio de propietario y grupo para /var/www/html
chown -R www-data:www-data /var/www/prestashop

# Renicio de Apache
systemctl restart apache2

# Borrado de todos los archivos y directorios que se han descomprimido en /tmp/prestashop
rm -rf /tmp/prestashop


#----------------------------------------------------------------------------------------------------------------------------
# Instalación de PrestaShop mediante CLI

# Desplazamiento al directorio que contiene la instalación de PrestaShop
cd /var/www/prestashop/install

# Ejecución de la instalación de PrestaShop
php index_cli.php \
    --language=$prestashop_language_country \
    --name=$prestashop_shop_name \
    --activity=$prestashop_activity \
    --country=$prestashop_language_country \
    --ssl=$ssl_state \
    --firstname=$admin_firstname \
    --lastname=$admin_lastname \
    --email=$email_certbot_prestashop \
    --password=$admin_password_back_office \
    --db_server=$database_mysql_server \
    --db_name=$database_name \
    --db_user=$database_user \
    --db_password=$database_password \
    --prefix=$database_prefix \
    --domain=$address_domain


#----------------------------------------------------------------------------------------------------------------------------
# Borrado de directorio install y phppsinfo.php dentro de /var/www/prestashop
rm -rf /var/www/prestashop/phppsinfo.php

rm -rf /var/www/prestashop/install
