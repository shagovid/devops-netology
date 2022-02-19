# Домашнее задание к занятию "6.2. SQL"

1.  Используя docker поднял инстанс PostgreSQL (версию 12) c 2 volume, 
    в который будут складываться данные БД (data) и бэкапы(backup):
    ```shell
    sudo docker run -d --name inst-psql -p 5432:5432 -v ~/devops/docker/volume/postgres/data:/var/lib/postgresql/data -v ~/docker/volume/postgres/backup:/var/lib/postgresql/backup -e POSTGRES_PASSWORD=test postgres:12
    ```
---

2.  
    * Подключился к СУБД:
    ```shell
    sudo docker exec -it inst-psql psql --username=postgres --dbname=postgres
    ```
    * Создал пользователя test-admin-user и БД test_db
    ```shell
    create user "test-admin-user";
    create database test_db;
    ```
    * в БД test_db создал таблицы orders и clients в соответствии с спeцификацией таблиц ниже:

      - Таблица orders:
        - id (serial primary key)
        - наименование (string)
        - цена (integer)

    ```shell
      create table orders (
        id int primary key,
        description varchar(100), 
        cost int
      );
    ```
      - Таблица clients:
        - id (serial primary key)
        - фамилия (string)
        - страна проживания (string, index)
        - заказ (foreign key orders)

    ```shell
      create table clients (
        id int primary key, 
        surname varchar(100), 
        location varchar(100), 
        id_orders int references orders(id)
      );
    ```
    * предоставил привилегии на все операции пользователю test-admin-user на таблицы БД test_db
    ```shell
      alter role "test-admin-user" superuser nocreatedb nocreaterole noinherit login;
      grant SELECT, INSERT, UPDATE, DELETE on orders,clients to "test-admin-user";
      grant all privileges on database test_db to "test-admin-user";
    ```
    * создал пользователя test-simple-user
    ```shell
      create user "test-simple-user";
    ```
    * предоставил пользователю test-simple-user права на SELECT/INSERT/UPDATE/DELETE данных таблиц БД test_db
    ```shell
       alter role "test-simple-user" nosuperuser nocreatedb nocreaterole noinherit login;
       grant select,insert,update,delete on table orders to "test-simple-user";
       grant select,insert,update,delete on table clients to "test-simple-user";
    ```
    В БД из задачи 1 привёл:
    * итоговый список БД

    ```shell
       \list
    ```
    
      ![img1](/HomeWork/virt-homeworks/06-db-02-sql/img/img1.png) 
    * описание таблиц (describe)

    ```shell
       \dt
    ```
    
      ![img2](/HomeWork/virt-homeworks/06-db-02-sql/img/img2.png)) 

    * SQL-запрос для выдачи списка пользователей с правами над таблицами test_db

    ```shell
       select * from information_schema.table_privileges where grantee in ('test-admin-user', 'test-simple-user');
    ```
    
      ![img3](/HomeWork/virt-homeworks/06-db-02-sql/img/img3.png)

    * список пользователей с правами над таблицами test_db

    ```shell
       \du
    ```
    
      ![img4](/HomeWork/virt-homeworks/06-db-02-sql/img/img4.png) 

---
3. * Используя SQL синтаксис - наполнил таблицы следующими тестовыми данными:

Таблица orders

|Наименование|цена|
|------------|----|
|Шоколад| 10 |
|Принтер| 3000 |
|Книга| 500 |
|Монитор| 7000|
|Гитара| 4000|

Таблица clients

|ФИО|Страна проживания|
|------------|----|
|Иванов Иван Иванович| USA |
|Петров Петр Петрович| Canada |
|Иоганн Себастьян Бах| Japan |
|Ронни Джеймс Дио| Russia|
|Ritchie Blackmore| Russia|

   ```shell
      insert into orders values (1, 'Шоколад', 10), (2, 'Принтер', 3000), (3, 'Книга', 500), (4, 'Монитор', 7000), (5, 'Гитара', 4000);
      insert into clients values (1, 'Иванов Иван Иванович', 'USA'), (2, 'Петров Петр Петрович', 'Canada'), (3, 'Иоганн Себастьян Бах', 'Japan'), (4, 'Ронни Джеймс Дио', 'Russia'), (5, 'Ritchie Blackmore', 'Russia');
      select * from orders;
      select * from clients;
   ```
   * Используя SQL синтаксис:
     - вычислил количество записей для каждой таблицы:
   ```shell
      select count (*) from orders;
      select count (*) from clients;
   ```
   ![img5](/HomeWork/virt-homeworks/06-db-02-sql/img/img5.png)

---
4. * Часть пользователей из таблицы clients решили оформить заказы из таблицы orders. Используя foreign keys связал записи из таблиц, согласно таблице ниже:

|ФИО|Заказ|
|------------|----|
|Иванов Иван Иванович| Книга |
|Петров Петр Петрович| Монитор |
|Иоганн Себастьян Бах| Гитара |

   ```shell
      update clients set "id_orders" = (select id from orders where "description"='Книга') where "surname"='Иванов Иван Иванович';
      update clients set "id_orders" = (Select id from orders where "description"='Монитор') where "surname"='Петров Петр Петрович';
      update clients set "id_orders" = (Select id from orders where "description"='Гитара') where "surname"='Иоганн Себастьян Бах';
      select surname from clients inner join orders on clients.id_orders = orders.id;
   ```
   ![img6](/HomeWork/virt-homeworks/06-db-02-sql/img/img6.png)

---
5. Получил полную информацию по выполнению запроса выдачи всех пользователей из задачи 4 
(используя директиву EXPLAIN):
    ```shell
    explain select surname from clients inner join orders on clients.id_orders = orders.id;
    ```

     ![img7](/HomeWork/virt-homeworks/06-db-02-sql/img/img7.png)

 
    Вывод команды показывает детальный тип выполняемых операций и её параметры быстродействия. Используется для анализа и оптимизации запросов.
    **cost** - затраты на получение первой и  всех строк (как понимаю синтетический параметр)
    **rows** - количество возвращаемых строк при выполнении операции
    **width** - средний размер одной строки в байтах
    **Hash join** - используется для объединения двух наборов записей
    **Seq Scan** - последовательное чтение данных таблицы
    
---
6. 
    * Создал бэкап БД test_db и поместил его в volume, предназначенный для бэкапов (как в задаче 1).
    ```shell
    docker exec -it inst-psql /bin/bash
    pg_dump test_db > /var/lib/postgresql/backup/test_db.sql
    sudo docker exec -t inst-psql pg_dump -U postgres test_db -f /var/lib/postgresql/backup/test_db.dump
    ```
    * Остановил контейнер с PostgreSQL (без удаления volumes).
    ```shell
    docker stop
    ```
    * Создал новый пустой контейнер с PostgreSQL.
    ```shell
    sudo docker run -d --name inst-psql2 -p 5432:5432 -v ~/devops/docker/volume/postgres/data:/var/lib/postgresql/data -v ~/docker/volume/postgres/backup:/var/lib/postgresql/backup -e POSTGRES_PASSWORD=test postgres:12
    ```
    * Восстановил БД test_db в новом контейнере.
    ```shell
    sudo docker exec -i inst-psql2 pg_restore -U postgres -d test_db -f /var/lib/postgresql/backup/test_db_dump.sql
    ```
   
