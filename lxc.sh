#!/bin/bash

# Имя контейнера
if [ -n "$1" ]
then
CONTAINER_NAME=$1
else
echo -e "\e[1;31m$0 Имя_контейнера [Дистрибутив] [Пакеты]\e[0m"
exit
fi

# Дистрибутив и версия
if [ -n "$2" ]
then
DISTRO=$2
else
echo -e "\e[1;31mВыбран дистрибутив по умолчанию: astralinux-se\e[0m"
DISTRO="astralinux-se"
fi
#RELEASE="1.7.5.16"

# Приложения для установки
if [ -n "$3" ]
then
APP=$3
else
echo -e "\e[1;31mВыбрано приложение по умолчанию: nginx\e[0m"
APP="nginx"
fi

# Шаг 1: Создание LXC-контейнера
echo -e "\e[1;31mСоздание LXC-контейнера...\e[0m"
lxc-create -n $CONTAINER_NAME -t $DISTRO

# Шаг 2: Parsec
echo "lxc.mount.entry = /parsecfs parsecfs none bind 0 0" | tee -a /var/lib/lxc/$CONTAINER_NAME/config

# Шаг 3: Запуск контейнера
echo -e "\e[1;31mЗапуск контейнера...\e[0m"
lxc-start -n $CONTAINER_NAME
sleep 8 # Ожидание для завершения запуска контейнера

# Шаг 4: Установка приложения внутри контейнера
echo -e "\e[1;31mУстановка $APP внутри контейнера...\e[0m"
lxc-attach -n $CONTAINER_NAME -- apt-get update
lxc-attach -n $CONTAINER_NAME -- apt-get install -y $APP

# Шаг 5: Выполнение дополнительных настроек (если необходимо)
echo -e "\e[1;31mДополнительные настройки...\e[0m"
# Пример дополнительной настройки: запуск Nginx при старте контейнера
if [ $APP = "nginx" ]
then
lxc-attach -n $CONTAINER_NAME -- systemctl enable $APP
fi

# Шаг 6: Перезапуск контейнера для применения настроек
echo -e "\e[1;31mПерезапуск контейнера...\e[0m"
lxc-stop -n $CONTAINER_NAME
lxc-start -n $CONTAINER_NAME

sleep 5
echo -e "\e[1;31mГотово! Контейнер $CONTAINER_NAME создан и настроен.\e[0m"
if [ $APP = "nginx" ]
then
echo "Попробуйте: http:"//$(sudo lxc-info -n $CONTAINER_NAME -iH)
fi
