#!bin/bash

set -x


#----------------------------------------------------------------------------------------------------------------------
# Variables para PrestaShop
prestashop_language=es
prestashop_shop_name="Tienda PrestaShop JRRL"
prestashop_activity=7
country_code=es
ssl_state=1
admin_firstname="Juan Ramón"
admin_lastname="Rueda Lao"
admin_email_back_office=tetz_dqhwr17@yutep.com
admin_password_back_office=@Admin123#
database_mysql_server=127.0.0.1
database_name=DB_PrestaShop
database_user=Usuario_PrestaShop
database_password=Password_PrestaShop
database_prefix=P_S_
ip_address_domain=practicasiawjrrl.ddns.net


#----------------------------------------------------------------------------------------------------------------------
# Instalación de PrestaShop mediante CLI

# Desplazamiento al directorio que contiene la instalación de PrestaShop
cd /var/www/prestashop/install

# Ejecución de la instalación de PrestaShop
php index_cli.php \
    --language=$prestashop_language \
    --name=$prestashop_shop_name \
    --activity=$prestashop_activity \
    --country=$country_code \
    --ssl=$ssl_state \
    --firstname=$admin_firstname \
    --lastname=$admin_lastname \
    --email=$admin_email_back_office \
    --password=$admin_password_back_office \
    --db_server=$database_mysql_server \
    --db_name=$database_name \
    --db_user=$database_user \
    --db_password=$database_password \
    --prefix=$database_prefix \
    --domain=$ip_address_domain


#----------------------------------------------------------------------------------------------------------------------
# Borrado de directorio install y phppsinfo.php dentro de /var/www/prestashop
rm -rf /var/www/prestashop/phppsinfo.php

rm -rf /var/www/prestashop/install
