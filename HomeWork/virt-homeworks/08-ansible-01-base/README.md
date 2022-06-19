# Домашнее задание к занятию "08.01 Введение в Ansible"

## Подготовка к выполнению
1. Установите ansible версии 2.10 или выше.
2. Создайте свой собственный публичный репозиторий на github с произвольным именем.
3. Скачайте [playbook](./playbook/) из репозитория с домашним заданием и перенесите его в свой репозиторий.

---

***Установка ansible и проверка версии***

```
$ sudo apt update
$ sudo apt install software-properties-common
$ sudo apt-add-repository --yes --update ppa:ansible/ansible
$ sudo apt install ansible
```

```bash
user@user-VPCSB2X9R:~/HW/ansible-homeworks$ ansible --version
ansible 2.9.6
  config file = /etc/ansible/ansible.cfg
  configured module search path = ['/home/user/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/lib/python3/dist-packages/ansible
  executable location = /usr/bin/ansible
  python version = 3.8.10 (default, Mar 15 2022, 12:22:08) [GCC 9.4.0]
```

---


## Основная часть
1. Попробуйте запустить playbook на окружении из `test.yml`, зафиксируйте какое значение имеет факт `some_fact` для указанного хоста при выполнении playbook'a.

***Решение:***

```bash
user@user-VPCSB2X9R:~/HW/ansible-homeworks/08-ansible-01-base/playbook$ ansible-playbook site.yml -i inventory/test.yml

PLAY [Print os facts] **********************************************************

TASK [Gathering Facts] *********************************************************
ok: [localhost]

TASK [Print OS] ****************************************************************
ok: [localhost] => {
    "msg": "Ubuntu"
}

TASK [Print fact] **************************************************************
ok: [localhost] => {
    "msg": 12
}

PLAY RECAP *********************************************************************
localhost                  : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0    
```

*В данном случае `some_fact`=12*

---

2. Найдите файл с переменными (group_vars) в котором задаётся найденное в первом пункте значение и поменяйте его на 'all default fact'.

***Решение:***

*Изменяем переменную в файле 'group_vars/all/examp.yml'*

```bash
user@user-VPCSB2X9R:~/HW/ansible-homeworks/08-ansible-01-base/playbook$ ansible-playbook site.yml -i inventory/test.yml

PLAY [Print os facts] **********************************************************

TASK [Gathering Facts] *********************************************************
ok: [localhost]

TASK [Print OS] ****************************************************************
ok: [localhost] => {
    "msg": "Ubuntu"
}

TASK [Print fact] **************************************************************
ok: [localhost] => {
    "msg": "all default fact"
}

PLAY RECAP *********************************************************************
localhost                  : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0 
```

---

3. Воспользуйтесь подготовленным (используется `docker`) или создайте собственное окружение для проведения дальнейших испытаний.

***Решение:***

Подготавливаем и запускаем контейнеры.  
Используемый [docker-compose.yml](/08-ansible-01-base/docker-compose.yml)

```bash
user@user-VPCSB2X9R:~/HW/ansible-homeworks/08-ansible-01-base/playbook$ sudo docker-compose up
user@user-VPCSB2X9R:~/HW/ansible-homeworks/08-ansible-01-base/playbook$ sudo docker ps
[sudo] пароль для user: 
CONTAINER ID   IMAGE                      COMMAND                  CREATED          STATUS              PORTS                                       NAMES
3b41c804c670   pycontribs/ubuntu:latest   "sleep infinity"         1 minutes ago    Up About a minute                                               ubuntu
9f4297b37617   pycontribs/centos:7        "sleep infinity"         1 minutes ago    Up About a minute                                               centos7
94bb518cec3b   postgres:13-alpine         "docker-entrypoint.s…"   2 months ago     Up 54 minutes       0.0.0.0:5432->5432/tcp, :::5432->5432/tcp   postgres13
```

---

4. Проведите запуск playbook на окружении из `prod.yml`. Зафиксируйте полученные значения `some_fact` для каждого из `managed host`.

***Решение:***

```bash
user@user-VPCSB2X9R:~/HW/ansible-homeworks/08-ansible-01-base/playbook$ sudo ansible-playbook site.yml -i inventory/prod.yml

PLAY [Print os facts] **********************************************************

TASK [Gathering Facts] *********************************************************

ok: [ubuntu]
ok: [centos7]

TASK [Print OS] ****************************************************************
ok: [centos7] => {
    "msg": "CentOS"
}
ok: [ubuntu] => {
    "msg": "Ubuntu"
}

TASK [Print fact] **************************************************************
ok: [centos7] => {
    "msg": "el"
}
ok: [ubuntu] => {
    "msg": "deb"
}

PLAY RECAP *********************************************************************
centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
ubuntu                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```

*Значения в файле 'inventory/prod.yml' `some_fact`:*  

*Для `Centos` - `el`*  
*Для `Ubuntu` - `deb`*

---

5. Добавьте факты в `group_vars` каждой из групп хостов так, чтобы для `some_fact` получились следующие значения: для `deb` - 'deb default fact', для `el` - 'el default fact'.

***Решение:***

*Для `group_vars/deb/examp.yml`*

```bash
---
some_fact: "deb default fact"
```

*Для `group_vars/el/examp.yml`*

```bash
---
some_fact: "el default fact"
```

---

6.  Повторите запуск playbook на окружении `prod.yml`. Убедитесь, что выдаются корректные значения для всех хостов.

***Решение:***

```bash
user@user-VPCSB2X9R:~/HW/ansible-homeworks/08-ansible-01-base/playbook$ sudo ansible-playbook site.yml -i inventory/prod.yml

PLAY [Print os facts] **********************************************************

TASK [Gathering Facts] *********************************************************

ok: [ubuntu]
ok: [centos7]

TASK [Print OS] ****************************************************************
ok: [centos7] => {
    "msg": "CentOS"
}
ok: [ubuntu] => {
    "msg": "Ubuntu"
}

TASK [Print fact] **************************************************************
ok: [centos7] => {
    "msg": "el default fact"
}
ok: [ubuntu] => {
    "msg": "deb default fact"
}

PLAY RECAP *********************************************************************
centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
ubuntu                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```

---

7. При помощи `ansible-vault` зашифруйте факты в `group_vars/deb` и `group_vars/el` с паролем `netology`.

***Решение:***

```bash
user@user-VPCSB2X9R:~/HW/ansible-homeworks/08-ansible-01-base/playbook$ sudo ansible-vault encrypt group_vars/deb/examp.yml group_vars/el/examp.yml
New Vault password: 
Confirm New Vault password: 
Encryption successful
```

```bash
user@user-VPCSB2X9R:~/HW/ansible-homeworks/08-ansible-01-base/playbook$ sudo cat group_vars/deb/examp.yml
$ANSIBLE_VAULT;1.1;AES256
36343762393863303966376336326362346235613131346266303339396636373038646136303738
3233373762663638373237636336326235393062626264340a373734326137376264373733646233
32306631613037626531383663656365623265376537303231313635343065303461643630303536
6666306232353163370a643735366233376433633066376536393231616262353864666539653463
61623334316462333631626138373534353430303432613863316239396364613664316336616233
6532313335663263643731343335313365666661343164656632
```

```bash
user@user-VPCSB2X9R:~/HW/ansible-homeworks/08-ansible-01-base/playbook$ sudo cat group_vars/el/examp.yml
$ANSIBLE_VAULT;1.1;AES256
37393339393662383462396435386439616531663061643963316436616634333539393531373938
3331383530623830626566386263656336633139653366300a643763323830383834613333656135
64373363333830386361626563326631363735386462353633396362656364333539333964636331
3336633565336462630a363865343865623232316231646538383462633935376339333563353563
63356637356133393865636163613133666465616234623762666164313166373838316639643037
3037356332343262373435613539653038623662666565666237
```

---

8. Запустите playbook на окружении `prod.yml`. При запуске `ansible` должен запросить у вас пароль. Убедитесь в работоспособности.

***Решение:***

```bash
user@user-VPCSB2X9R:~/HW/ansible-homeworks/08-ansible-01-base/playbook$ sudo ansible-playbook site.yml -i inventory/prod.yml --ask-vault-pass
Vault password: 

PLAY [Print os facts] **********************************************************

TASK [Gathering Facts] *********************************************************
k: [ubuntu]
ok: [centos7]

TASK [Print OS] ****************************************************************
ok: [centos7] => {
    "msg": "CentOS"
}
ok: [ubuntu] => {
    "msg": "Ubuntu"
}

TASK [Print fact] **************************************************************
ok: [centos7] => {
    "msg": "el default fact"
}
ok: [ubuntu] => {
    "msg": "deb default fact"
}

PLAY RECAP *********************************************************************
centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
ubuntu                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0 
```

---

9. Посмотрите при помощи `ansible-doc` список плагинов для подключения. Выберите подходящий для работы на `control node`.

***Решение:***

```bash
user@user-VPCSB2X9R:~/HW/ansible-homeworks/08-ansible-01-base/playbook$ sudo ansible-doc --type=connection -l
buildah      Interact with an existing buildah container                   
chroot       Interact with local chroot                                    
docker       Run tasks in docker containers                                
funcd        Use funcd to connect to target                                
httpapi      Use httpapi to run command on network appliances              
iocage       Run tasks in iocage jails                                     
jail         Run tasks in jails                                            
kubectl      Execute tasks in pods running on Kubernetes                   
libvirt_lxc  Run tasks in lxc containers via libvirt                       
local        execute on controller                                         
lxc          Run tasks in lxc containers via lxc python library            
lxd          Run tasks in lxc containers via lxc CLI                       
napalm       Provides persistent connection using NAPALM                   
netconf      Provides a persistent connection using the netconf protocol   
network_cli  Use network_cli to run command on network appliances          
oc           Execute tasks in pods running on OpenShift                    
paramiko_ssh Run tasks via python ssh (paramiko)                           
persistent   Use a persistent unix socket for connection                   
podman       Interact with an existing podman container                    
psrp         Run tasks over Microsoft PowerShell Remoting Protocol         
qubes        Interact with an existing QubesOS AppVM                       
saltstack    Allow ansible to piggyback on salt minions                    
ssh          connect via ssh client binary                                 
:...skipping...
buildah      Interact with an existing buildah container                   
chroot       Interact with local chroot                                    
docker       Run tasks in docker containers                                
funcd        Use funcd to connect to target                                
httpapi      Use httpapi to run command on network appliances              
iocage       Run tasks in iocage jails                                     
jail         Run tasks in jails                                            
kubectl      Execute tasks in pods running on Kubernetes                   
libvirt_lxc  Run tasks in lxc containers via libvirt                       
local        execute on controller                                         
lxc          Run tasks in lxc containers via lxc python library            
lxd          Run tasks in lxc containers via lxc CLI                       
napalm       Provides persistent connection using NAPALM                   
netconf      Provides a persistent connection using the netconf protocol   
network_cli  Use network_cli to run command on network appliances          
oc           Execute tasks in pods running on OpenShift                    
paramiko_ssh Run tasks via python ssh (paramiko)                           
persistent   Use a persistent unix socket for connection                   
podman       Interact with an existing podman container                    
psrp         Run tasks over Microsoft PowerShell Remoting Protocol         
qubes        Interact with an existing QubesOS AppVM                       
saltstack    Allow ansible to piggyback on salt minions                    
ssh          connect via ssh client binary                                 
vmware_tools Execute tasks inside a VM via VMware Tools                    
winrm        Run tasks over Microsoft's WinRM                              
zone         Run tasks in a zone instance 
```

*Нас интересует `execute on controller`.*

---

10. В `prod.yml` добавьте новую группу хостов с именем  `local`, в ней разместите localhost с необходимым типом подключения.

***Решение:***

```
---
  el:
    hosts:
      centos7:
        ansible_connection: docker
  deb:
    hosts:
      ubuntu:
        ansible_connection: docker
  local:
    hosts:
      localhost:
        ansible_connection: local
```

---

11. Запустите playbook на окружении `prod.yml`. При запуске `ansible` должен запросить у вас пароль. Убедитесь что факты `some_fact` для каждого из хостов определены из верных `group_vars`.

***Решение:***

```bash
user@user-VPCSB2X9R:~/HW/ansible-homeworks/08-ansible-01-base/playbook$ sudo ansible-playbook site.yml -i inventory/prod.yml --ask-vault-pass
Vault password: 

PLAY [Print os facts] ********************************************************************************************************************************

TASK [Gathering Facts] *******************************************************************************************************************************
ok: [localhost]
[DEPRECATION WARNING]: Distribution Ubuntu 18.04 on host ubuntu should use /usr/bin/python3, but is using /usr/bin/python for backward compatibility 
with prior Ansible releases. A future Ansible release will default to using the discovered platform python for this host. See 
https://docs.ansible.com/ansible/2.9/reference_appendices/interpreter_discovery.html for more information. This feature will be removed in version 
2.12. Deprecation warnings can be disabled by setting deprecation_warnings=False in ansible.cfg.
ok: [ubuntu]
ok: [centos7]

TASK [Print OS] **************************************************************************************************************************************
ok: [localhost] => {
    "msg": "Ubuntu"
}
ok: [centos7] => {
    "msg": "CentOS"
}
ok: [ubuntu] => {
    "msg": "Ubuntu"
}

TASK [Print fact] ************************************************************************************************************************************
ok: [localhost] => {
    "msg": "all default fact"
}
ok: [centos7] => {
    "msg": "el default fact"
}
ok: [ubuntu] => {
    "msg": "deb default fact"
}

PLAY RECAP *******************************************************************************************************************************************
centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
localhost                  : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
ubuntu                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```

---

12. Заполните `README.md` ответами на вопросы. Сделайте `git push` в ветку `main`. В ответе отправьте ссылку на ваш открытый репозиторий с изменённым `playbook` и заполненным `README.md`.

***Решение:***

[Заполненый `README.md`](https://github.com/shagovid/ansible-homeworks/blob/main/08-ansible-01-base/playbook/README.md)

Ссылка на репозиторий с изменённым ansible playbook: [https://github.com/shagovid/ansible-homeworks/tree/main/08-ansible-01-base/playbook)

---

## Необязательная часть

1. При помощи `ansible-vault` расшифруйте все зашифрованные файлы с переменными.
2. Зашифруйте отдельное значение `PaSSw0rd` для переменной `some_fact` паролем `netology`. Добавьте полученное значение в `group_vars/all/exmp.yml`.
3. Запустите `playbook`, убедитесь, что для нужных хостов применился новый `fact`.
4. Добавьте новую группу хостов `fedora`, самостоятельно придумайте для неё переменную. В качестве образа можно использовать [этот](https://hub.docker.com/r/pycontribs/fedora).
5. Напишите скрипт на bash: автоматизируйте поднятие необходимых контейнеров, запуск ansible-playbook и остановку контейнеров.
6. Все изменения должны быть зафиксированы и отправлены в вашей личный репозиторий.