#!/bin/bash

# Muestra los comandos que se van a ejecutar y poder depurar
set -x

# Actualización de los repositorios instalados
apt-get update

# Actualización los programas de los repositorios instalados, no funciona correctamente por eso está comentado
apt-get upgrade -y


#---------------------------------------------------------------------------------------------------------------
# Instalación de servidor web Apache2
apt-get install apache2 -y


#---------------------------------------------------------------------------------------------------------------
# Instalación del servidor MySQL
apt-get install mysql-server -y


#---------------------------------------------------------------------------------------------------------------
# Instalación de PHP y varios módulos que necesitamos
apt-get install php libapache2-mod-php php-mysql -y
