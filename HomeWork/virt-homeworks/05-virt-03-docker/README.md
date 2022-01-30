### Домашнее задание к занятию "5.3. Введение. Экосистема. Архитектура. Жизненный цикл Docker контейнера"

#### Задача 1

Сценарий выполнения задачи:

- создайте свой репозиторий на https://hub.docker.com;
- выберете любой образ, который содержит веб-сервер Nginx;
- создайте свой fork образа;
- реализуйте функциональность:
запуск веб-сервера в фоне с индекс-страницей, содержащей HTML-код ниже:
```
<html>
<head>
Hey, Netology
</head>
<body>
<h1>I’m DevOps Engineer!</h1>
</body>
</html>
```
Опубликуйте созданный форк в своем репозитории и предоставьте ответ в виде ссылки на https://hub.docker.com/username_repo.

### Ответ

```bash
root@user-VPCSB2X9R:/home/user/test# docker images

REPOSITORY              TAG       IMAGE ID       CREATED       SIZE
shagovid/devops-nginx   latest    2a3fb114f7d3   2 hours ago   142MB

root@user-VPCSB2X9R:/home/user/test# curl 172.17.0.2

<html>
<head>
Hey, Netology
</head>
<body>
<h1>I'm DevOps Engineer!</h1>
<h2>ShagovID</h2>
</body>
```

https://hub.docker.com/r/shagovid/devops-nginx


#### Задача 2

Посмотрите на сценарий ниже и ответьте на вопрос:
"Подходит ли в этом сценарии использование Docker контейнеров или лучше подойдет виртуальная машина, физическая машина? Может быть возможны разные варианты?"

Детально опишите и обоснуйте свой выбор.

--

Сценарий:

- Высоконагруженное монолитное java веб-приложение;
```
Физический сервер или VM предпочтительнее, т.к. монолитное и на микросервисы сложно разбить. К тому же высоконагруженное - 
необходим прямой доступ к ресурсам.
```
- Nodejs веб-приложение;
```
Подойдет Docker, так как это веб-платформа с подключаемыми внешними библиотеками
```
- Мобильное приложение c версиями для Android и iOS;
```
Необходим GUI, так что подойдет виртуалка.
```
- Шина данных на базе Apache Kafka;
```
Если среда рабочая и полнота данных критична, то лучше использовать VM; если среда тестовая и потеря данных некритична,
можно использовать Docker.
```
- Elasticsearch кластер для реализации логирования продуктивного веб-приложения - три ноды elasticsearch, два logstash и
две ноды kibana;
```
Elasticsearvh лучше на VM, отказоустойчивость решается на уровне кластера, kibana и logstash можно вынести в Docker.
```
- Мониторинг-стек на базе Prometheus и Grafana;
```
Подойдет Docker, так как данные не хранятся, и масштабировать легко.
```
- MongoDB, как основное хранилище данных для java-приложения;
```
Зависит от нагрузки на DB. Если нагрузка большая, то физический сервер, если нет – VM.
```
- Gitlab сервер для реализации CI/CD процессов и приватный (закрытый) Docker Registry.
```
Подойдет VM для DB и фалового хранилища, Docker для сервисов
```

#### Задача 3

- Запустите первый контейнер из образа ***centos*** c любым тэгом в фоновом режиме, подключив папку ```/data``` из текущей рабочей директории на хостовой машине в ```/data``` контейнера;
- Запустите второй контейнер из образа ***debian*** в фоновом режиме, подключив папку ```/data``` из текущей рабочей директории на хостовой машине в ```/data``` контейнера;
- Подключитесь к первому контейнеру с помощью ```docker exec``` и создайте текстовый файл любого содержания в ```/data```;
- Добавьте еще один файл в папку ```/data``` на хостовой машине;
- Подключитесь во второй контейнер и отобразите листинг и содержание файлов в ```/data``` контейнера.

### Решение

```bash
root@user-VPCSB2X9R:/home/user# docker run -it --rm -d --name centos -v $(pwd)/data:/data centos:latest
Unable to find image 'centos:latest' locally
latest: Pulling from library/centos
a1d0c7532777: Pull complete 
Digest: sha256:a27fd8080b517143cbbbab9dfb7c8571c40d67d534bbdee55bd6c473f432b177
Status: Downloaded newer image for centos:latest
b6eb3fc254ed4593af575d62b059c60d820dcf21a0533a0afb69d07f75eab173
```

```bash
root@user-VPCSB2X9R:/home/user# docker run -it --rm -d --name debian -v $(pwd)/data:/data debian:latest
Unable to find image 'debian:latest' locally
latest: Pulling from library/debian
0c6b8ff8c37e: Pull complete 
Digest: sha256:fb45fd4e25abe55a656ca69a7bef70e62099b8bb42a279a5e0ea4ae1ab410e0d
Status: Downloaded newer image for debian:latest
f934d711e3f424ed108f04c8e36a487afeaa0c085ed6d231687eb5ad74376c61
```

```bash
root@user-VPCSB2X9R:/home/user# docker exec -it centos bash
[root@b6eb3fc254ed /]# echo "This file is written to docker CentOS" >> /data/centos.txt
[root@b6eb3fc254ed /]# exit
exit
```

```bash
root@user-VPCSB2X9R:/home/user# echo "This file is written to host" >> data/host.txt
```

```bash
root@user-VPCSB2X9R:/home/user# docker exec -it debian bash
root@f934d711e3f4:/# ls data/
centos.txt  host.txt
root@f934d711e3f4:/# exit
exit
```

#### Задача 4 (*)

Воспроизвести практическую часть лекции самостоятельно.

Соберите Docker образ с Ansible, загрузите на Docker Hub и пришлите ссылку вместе с остальными ответами к задачам.

### Ответ

```
https://hub.docker.com/r/shagovid/devops-ansible
```
