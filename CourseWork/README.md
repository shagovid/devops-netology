# Курсовая работа по итогам модуля "DevOps и системное администрирование"

## Задание

1. Создайте виртуальную машину Linux.  
Создал виртуальную машину Ubuntu 20.04 в VK Cloud Solution, чтобы потом использовать эту машину при дальнейшем обучении и опытах.

2. Установите ufw и разрешите к этой машине сессии на порты 22 и 443, при этом трафик на интерфейсе localhost (lo) должен ходить свободно на все порты.  
Брандмауэр уже установлен в шаблоне, настроил ufw:
```bash
root@ubuntu-basic-1-2-30gb-net:/home/ubuntu# sudo apt install ufw
Reading package lists... Done
Building dependency tree
Reading state information... Done
ufw is already the newest version (0.36-6ubuntu1).
ufw set to manually installed.
0 upgraded, 0 newly installed, 0 to remove and 0 not upgraded.
root@ubuntu-basic-1-2-30gb-net:/home/ubuntu# sudo ufw allow 22
Rules updated
Rules updated (v6)
root@ubuntu-basic-1-2-30gb-net:/home/ubuntu# sudo ufw allow 443
Rules updated
Rules updated (v6)
root@ubuntu-basic-1-2-30gb-net:/home/ubuntu# sudo ufw enable
Command may disrupt existing ssh connections. Proceed with operation (y|n)? y
Firewall is active and enabled on system startup
root@ubuntu-basic-1-2-30gb-net:/home/ubuntu# sudo ufw status verbose
Status: active
Logging: on (low)
Default: deny (incoming), allow (outgoing), disabled (routed)
New profiles: skip

To                         Action      From
--                         ------      ----
22                         ALLOW IN    Anywhere
443                        ALLOW IN    Anywhere
22/tcp                     ALLOW IN    Anywhere
22 (v6)                    ALLOW IN    Anywhere (v6)
443 (v6)                   ALLOW IN    Anywhere (v6)
22/tcp (v6)                ALLOW IN    Anywhere (v6)
```

3. Устанавливаем hashicorp vault по инструкции ([инструкция по ссылке](https://learn.hashicorp.com/tutorials/vault/getting-started-install?in=vault/getting-started#install-vault)).
```bash
root@ubuntu-basic-1-2-30gb-net:/home/ubuntu# curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
OK
root@ubuntu-basic-1-2-30gb-net:/home/ubuntu# sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
Hit:1 http://dp1.clouds.archive.ubuntu.com/ubuntu focal InRelease
Get:2 https://apt.releases.hashicorp.com focal InRelease [9495 B]
Get:3 http://dp1.clouds.archive.ubuntu.com/ubuntu focal-updates InRelease [114 kB]
Get:4 https://apt.releases.hashicorp.com focal/main amd64 Packages [41.1 kB]
Get:5 http://dp1.clouds.archive.ubuntu.com/ubuntu focal-backports InRelease [108 kB]
Get:6 http://dp1.clouds.archive.ubuntu.com/ubuntu focal-updates/main amd64 Packages [1443 kB]
Get:7 http://dp1.clouds.archive.ubuntu.com/ubuntu focal-updates/restricted amd64 Packages [660 kB]
Get:8 http://dp1.clouds.archive.ubuntu.com/ubuntu focal-updates/universe amd64 Packages [892 kB]
Get:9 http://dp1.clouds.archive.ubuntu.com/ubuntu focal-backports/universe amd64 Packages [19.2 kB]
Fetched 3286 kB in 2s (1709 kB/s)
Reading package lists... Done
root@ubuntu-basic-1-2-30gb-net:/home/ubuntu# sudo apt-get update && sudo apt-get install vault
Hit:1 https://apt.releases.hashicorp.com focal InRelease
Hit:2 http://dp1.clouds.archive.ubuntu.com/ubuntu focal InRelease
Hit:3 http://dp1.clouds.archive.ubuntu.com/ubuntu focal-updates InRelease
Hit:4 http://dp1.clouds.archive.ubuntu.com/ubuntu focal-backports InRelease
Reading package lists... Done
Reading package lists... Done
Building dependency tree
Reading state information... Done
The following NEW packages will be installed:
  vault
0 upgraded, 1 newly installed, 0 to remove and 0 not upgraded.
Need to get 69.4 MB of archives.
After this operation, 188 MB of additional disk space will be used.
Get:1 https://apt.releases.hashicorp.com focal/main amd64 vault amd64 1.9.2 [69.4 MB]
Fetched 69.4 MB in 2s (43.6 MB/s)
Selecting previously unselected package vault.
(Reading database ... 49483 files and directories currently installed.)
Preparing to unpack .../archives/vault_1.9.2_amd64.deb ...
Unpacking vault (1.9.2) ...
Setting up vault (1.9.2) ...
Generating Vault TLS key and self-signed certificate...
Generating a RSA private key
.....................................................................................................................++++
.......................................++++
writing new private key to 'tls.key'
-----
Vault TLS key and self-signed certificate have been generated in '/opt/vault/tls'.
```

4. Cоздайте центр сертификации по инструкции ([ссылка](https://learn.hashicorp.com/tutorials/vault/pki-engine?in=vault/secrets-management)) и выпустите сертификат для использования его в настройке веб-сервера nginx (срок жизни сертификата - месяц).    

Для начала в другой сессии запускаем сервер Vault в режиме разработчика с root в качестве корневого токена:
```bash
root@ubuntu-basic-1-2-30gb-net:/home/ubuntu# vault server -dev -dev-root-token-id root
==> Vault server configuration:

             Api Address: http://127.0.0.1:8200
                     Cgo: disabled
         Cluster Address: https://127.0.0.1:8201
              Go Version: go1.17.5
              Listener 1: tcp (addr: "127.0.0.1:8200", cluster address: "127.0.0.1:8201", max_request_duration: "1m30s", max_request_size: "33554432", tls: "disabled")
               Log Level: info
                   Mlock: supported: true, enabled: false
           Recovery Mode: false
                 Storage: inmem
                 Version: Vault v1.9.2
             Version Sha: f4c6d873e2767c0d6853b5d9ffc77b0d297bfbd*

==> Vault server started! Log data will stream in below:

2022-01-07T10:28:29.517Z [INFO]  proxy environment: http_proxy="\"\"" https_proxy="\"\"" no_proxy="\"\""
2022-01-07T10:28:29.518Z [WARN]  no `api_addr` value specified in config or in VAULT_API_ADDR; falling back to detection if possible, but this value should be manually set
2022-01-07T10:28:29.518Z [INFO]  core: Initializing VersionTimestamps for core
2022-01-07T10:28:29.522Z [INFO]  core: security barrier not initialized
2022-01-07T10:28:29.522Z [INFO]  core: security barrier initialized: stored=1 shares=1 threshold=1
2022-01-07T10:28:29.523Z [INFO]  core: post-unseal setup starting
2022-01-07T10:28:29.525Z [INFO]  core: loaded wrapping token key
2022-01-07T10:28:29.525Z [INFO]  core: Recorded vault version: vault version=1.9.2 upgrade time="2022-01-07 10:28:29.525845872 +0000 UTC m=+0.067315635"
2022-01-07T10:28:29.526Z [INFO]  core: successfully setup plugin catalog: plugin-directory="\"\""
2022-01-07T10:28:29.526Z [INFO]  core: no mounts; adding default mount table
2022-01-07T10:28:29.531Z [INFO]  core: successfully mounted backend: type=cubbyhole path=cubbyhole/
2022-01-07T10:28:29.532Z [INFO]  core: successfully mounted backend: type=system path=sys/
2022-01-07T10:28:29.532Z [INFO]  core: successfully mounted backend: type=identity path=identity/
2022-01-07T10:28:29.534Z [INFO]  core: successfully enabled credential backend: type=token path=token/
2022-01-07T10:28:29.534Z [INFO]  core: restoring leases
2022-01-07T10:28:29.536Z [INFO]  expiration: lease restore complete
2022-01-07T10:28:29.536Z [INFO]  rollback: starting rollback manager
2022-01-07T10:28:29.536Z [INFO]  identity: entities restored
2022-01-07T10:28:29.536Z [INFO]  identity: groups restored
2022-01-07T10:28:29.536Z [INFO]  core: post-unseal setup complete
2022-01-07T10:28:29.536Z [INFO]  core: root token generated
2022-01-07T10:28:29.536Z [INFO]  core: pre-seal teardown starting
2022-01-07T10:28:29.536Z [INFO]  rollback: stopping rollback manager
2022-01-07T10:28:29.536Z [INFO]  core: pre-seal teardown complete
2022-01-07T10:28:29.537Z [INFO]  core.cluster-listener.tcp: starting listener: listener_address=127.0.0.1:8201
2022-01-07T10:28:29.537Z [INFO]  core.cluster-listener: serving cluster requests: cluster_listen_address=127.0.0.1:8201
2022-01-07T10:28:29.537Z [INFO]  core: post-unseal setup starting
2022-01-07T10:28:29.537Z [INFO]  core: loaded wrapping token key
2022-01-07T10:28:29.537Z [INFO]  core: successfully setup plugin catalog: plugin-directory="\"\""
2022-01-07T10:28:29.538Z [INFO]  core: successfully mounted backend: type=system path=sys/
2022-01-07T10:28:29.538Z [INFO]  core: successfully mounted backend: type=identity path=identity/
2022-01-07T10:28:29.538Z [INFO]  core: successfully mounted backend: type=cubbyhole path=cubbyhole/
2022-01-07T10:28:29.539Z [INFO]  core: successfully enabled credential backend: type=token path=token/
2022-01-07T10:28:29.539Z [INFO]  core: restoring leases
2022-01-07T10:28:29.540Z [INFO]  identity: entities restored
2022-01-07T10:28:29.540Z [INFO]  identity: groups restored
2022-01-07T10:28:29.540Z [INFO]  core: post-unseal setup complete
2022-01-07T10:28:29.540Z [INFO]  core: vault is unsealed
2022-01-07T10:28:29.544Z [INFO]  expiration: revoked lease: lease_id=auth/token/root/h7e2b85f990fe19e393b2968413bbb6db0c1b04798bf81c1002d33ec1cfdecfcf
2022-01-07T10:28:29.551Z [INFO]  core: successful mount: namespace="\"\"" path=secret/ type=kv
2022-01-07T10:28:29.556Z [INFO]  expiration: lease restore complete
2022-01-07T10:28:29.556Z [INFO]  secrets.kv.kv_a03ec17c: collecting keys to upgrade
2022-01-07T10:28:29.556Z [INFO]  secrets.kv.kv_a03ec17c: done collecting keys: num_keys=1
2022-01-07T10:28:29.556Z [INFO]  secrets.kv.kv_a03ec17c: upgrading keys finished
2022-01-07T10:28:29.557Z [INFO]  rollback: starting rollback manager
WARNING! dev mode is enabled! In this mode, Vault runs entirely in-memory
and starts unsealed with a single unseal key. The root token is already
authenticated to the CLI, so you can immediately begin using Vault.

You may need to set the following environment variable:

    $ export VAULT_ADDR='http://127.0.0.1:8200'

The unseal key and root token are displayed below in case you want to
seal/unseal the Vault or re-authenticate.

Unseal Key: LDy2FtEpFEPjhRczUmShQr72ucUOBwqyzFDbp4GJ***=
Root Token: root

Development mode should NOT be used in production installations!

2022-01-07T10:29:14.752Z [INFO]  core: successful mount: namespace="\"\"" path=pki/ type=pki
2022-01-07T10:29:35.256Z [INFO]  core: mount tuning of leases successful: path=pki/ 
```
Устанавим JSON. В том числе для Vault, чтобы следовать примерам, в которых используется этот инструмент.
```bash
root@ubuntu-basic-1-2-30gb-net:/home/ubuntu# sudo apt-get install jq
Reading package lists... Done
Building dependency tree
Reading state information... Done
The following additional packages will be installed:
  libjq1 libonig5
The following NEW packages will be installed:
  jq libjq1 libonig5
0 upgraded, 3 newly installed, 0 to remove and 246 not upgraded.
Need to get 313 kB of archives.
After this operation, 1062 kB of additional disk space will be used.
Do you want to continue? [Y/n] y
Get:1 http://dp1.clouds.archive.ubuntu.com/ubuntu focal/universe amd64 libonig5 amd64 6.9.4-1 [142 kB]
Get:2 http://dp1.clouds.archive.ubuntu.com/ubuntu focal-updates/universe amd64 libjq1 amd64 1.6-1ubuntu0.20.04.1 [121 kB]
Get:3 http://dp1.clouds.archive.ubuntu.com/ubuntu focal-updates/universe amd64 jq amd64 1.6-1ubuntu0.20.04.1 [50.2 kB]
Fetched 313 kB in 1s (301 kB/s)
Selecting previously unselected package libonig5:amd64.
(Reading database ... 42286 files and directories currently installed.)
Preparing to unpack .../libonig5_6.9.4-1_amd64.deb ...
Unpacking libonig5:amd64 (6.9.4-1) ...
Selecting previously unselected package libjq1:amd64.
Preparing to unpack .../libjq1_1.6-1ubuntu0.20.04.1_amd64.deb ...
Unpacking libjq1:amd64 (1.6-1ubuntu0.20.04.1) ...
Selecting previously unselected package jq.
Preparing to unpack .../jq_1.6-1ubuntu0.20.04.1_amd64.deb ...
Unpacking jq (1.6-1ubuntu0.20.04.1) ...
Setting up libonig5:amd64 (6.9.4-1) ...
Setting up libjq1:amd64 (1.6-1ubuntu0.20.04.1) ...
Setting up jq (1.6-1ubuntu0.20.04.1) ...
Processing triggers for man-db (2.9.1-1) ...
Processing triggers for libc-bin (2.31-0ubuntu9) ...
```
Теперь экспортируем переменную среды для vault CLI для адресации к серверу Vault и переменную среды для CLI хранилища для аутентификации на сервере Vault.
```bash
root@ubuntu-basic-1-2-30gb-net:/home/ubuntu# export VAULT_ADDR=http://127.0.0.1:8200
root@ubuntu-basic-1-2-30gb-net:/home/ubuntu# export VAULT_TOKEN=root
```
Включим и настроим механизм секретов pki для выдачи сертификатов. По заданию это месяц. 
```bash
root@ubuntu-basic-1-2-30gb-net:/home/ubuntu# vault secrets enable pki
Success! Enabled the pki secrets engine at: pki/
root@ubuntu-basic-1-2-30gb-net:/home/ubuntu# vault secrets tune -max-lease-ttl=730h pki
Success! Tuned the secrets engine at: pki/
```
Сгенерируем корневой сертификат и сохраним сертификат в CA_cert.crt:
```bash
root@ubuntu-basic-1-2-30gb-net:/home/ubuntu# vault write -field=certificate pki/root/generate/internal \
> common_name="example.com" \
> ttl=730h > CA_cert.crt
```
Конфигурируем CA и CRL ссылки(URLs):
```bash
root@ubuntu-basic-1-2-30gb-net:/home/ubuntu# vault write pki/config/urls \
> issuing_certificates="$VAULT_ADDR/v1/pki/ca" \
> crl_distribution_points="$VAULT_ADDR/v1/pki/crl"
Success! Data written to: pki/config/urls
```
Создадим роль:
```bash
root@ubuntu-basic-1-2-30gb-net:/home/ubuntu# vault write pki/roles/example-dot-com \
> allowed_domains="example.com" \
> allow_subdomains=true \
> allow_bare_domains=true \
> max_ttl="730h"
Success! Data written to: pki/roles/example-dot-com
```
Выпускаем сертификаты для сервера:
```bash
root@ubuntu-basic-1-2-30gb-net:/home/ubuntu# vault write pki/issue/example-dot-com common_name="test.example.com" ttl="24h"
Key                 Value
---                 -----
certificate         -----BEGIN CERTIFICATE-----
MIIDvzCCAqegAwIBAgIUeZvK03QvpjxluevVlBnFdmHXsawwDQYJKoZIhvcNAQEL
BQAwFjEUMBIGA1UEAxMLZXhhbXBsZS5jb20wHhcNMjIwMTA3MTA0MDQ4WhcNMjIw
MTA4MTA0MTE4WjAbMRkwFwYDVQQDExB0ZXN0LmV4YW1wbGUuY29tMIIBIjANBgkq
-----END CERTIFICATE-----
expiration          1641638478
issuing_ca          -----BEGIN CERTIFICATE-----
MIIDNTCCAh2gAwIBAgIUDc5B3Qrqq3PvehhI7NHJj2UtZK4wDQYJKoZIhvcNAQEL
BQAwFjEUMBIGA1UEAxMLZXhhbXBsZS5jb20wHhcNMjIwMTA3MTAyOTQ0WhcNMjIw
MjA2MjAzMDE0WjAWMRQwEgYDVQQDEwtleGFtcGxlLmNvbTCCASIwDQYJKoZIhvcN
-----END CERTIFICATE-----
private_key         -----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEAt5rpgS4+7FFXQNdrVk8vrX2qWCS0SQmrKlMOXGplxQuiiFbp
/Emqge1smGIezzTg3QmCkIk6wVXEk36IMJYKaDgEoCQuNIdDzvPYsu4Bed7l2d73
TqAGyJKuZW0bbEnsf7ObnPTFhX/ODj9j6RbGYBIQgLfqDe2V0UBIm1pSkyZdAsvm
-----END RSA PRIVATE KEY-----
private_key_type    rsa
serial_number       79:9b:ca:d3:74:2f:a6:3c:65:b9:eb:d5:94:19:c5:76:61:d7:b1:**
```

5. Установите корневой сертификат созданного центра сертификации в доверенные в хостовой системе.
В данный момент у меня хостовая система Windows 7, загружу сертификат с сервера через WinSCP и установлю в систему:
![img.png](img.png)
Сертификат
![img_2.png](img_2.png)

6. Установим nginx. Разрешим трафик в firewall и проверим работу службы:
```bash
root@ubuntu-basic-1-2-30gb-net:/home/ubuntu# sudo apt install nginx
Reading package lists... Done
Building dependency tree
Reading state information... Done
The following additional packages will be installed:
  fontconfig-config fonts-dejavu-core libfontconfig1 libgd3 libjbig0
  libjpeg-turbo8 libjpeg8 libnginx-mod-http-image-filter
  libnginx-mod-http-xslt-filter libnginx-mod-mail libnginx-mod-stream libtiff5
  libwebp6 libxpm4 nginx-common nginx-core
Suggested packages:
  libgd-tools fcgiwrap nginx-doc ssl-cert
The following NEW packages will be installed:
  fontconfig-config fonts-dejavu-core libfontconfig1 libgd3 libjbig0
  libjpeg-turbo8 libjpeg8 libnginx-mod-http-image-filter
  libnginx-mod-http-xslt-filter libnginx-mod-mail libnginx-mod-stream libtiff5
  libwebp6 libxpm4 nginx nginx-common nginx-core
0 upgraded, 17 newly installed, 0 to remove and 246 not upgraded.
Need to get 2432 kB of archives.
After this operation, 7891 kB of additional disk space will be used.
Do you want to continue? [Y/n] y
Get:1 http://dp1.clouds.archive.ubuntu.com/ubuntu focal/main amd64 fonts-dejavu-core all 2.37-1 [1041 kB]
Get:2 http://dp1.clouds.archive.ubuntu.com/ubuntu focal/main amd64 fontconfig-config all 2.13.1-2ubuntu3 [28.8 kB]
Get:3 http://dp1.clouds.archive.ubuntu.com/ubuntu focal/main amd64 libfontconfig1 amd64 2.13.1-2ubuntu3 [114 kB]
Get:4 http://dp1.clouds.archive.ubuntu.com/ubuntu focal-updates/main amd64 libjpeg-turbo8 amd64 2.0.3-0ubuntu1.20.04.1 [117 kB]
Get:5 http://dp1.clouds.archive.ubuntu.com/ubuntu focal/main amd64 libjpeg8 amd64 8c-2ubuntu8 [2194 B]
Get:6 http://dp1.clouds.archive.ubuntu.com/ubuntu focal/main amd64 libjbig0 amd64 2.1-3.1build1 [26.7 kB]
Get:7 http://dp1.clouds.archive.ubuntu.com/ubuntu focal-updates/main amd64 libwebp6 amd64 0.6.1-2ubuntu0.20.04.1 [185 kB]
Get:8 http://dp1.clouds.archive.ubuntu.com/ubuntu focal-updates/main amd64 libtiff5 amd64 4.1.0+git191117-2ubuntu0.20.04.2 [162 kB]
Get:9 http://dp1.clouds.archive.ubuntu.com/ubuntu focal/main amd64 libxpm4 amd64 1:3.5.12-1 [34.0 kB]
Get:10 http://dp1.clouds.archive.ubuntu.com/ubuntu focal-updates/main amd64 libgd3 amd64 2.2.5-5.2ubuntu2.1 [118 kB]
Get:11 http://dp1.clouds.archive.ubuntu.com/ubuntu focal-updates/main amd64 nginx-common all 1.18.0-0ubuntu1.2 [37.5 kB]
Get:12 http://dp1.clouds.archive.ubuntu.com/ubuntu focal-updates/main amd64 libnginx-mod-http-image-filter amd64 1.18.0-0ubuntu1.2 [14.4 kB]
Get:13 http://dp1.clouds.archive.ubuntu.com/ubuntu focal-updates/main amd64 libnginx-mod-http-xslt-filter amd64 1.18.0-0ubuntu1.2 [12.7 kB]
Get:14 http://dp1.clouds.archive.ubuntu.com/ubuntu focal-updates/main amd64 libnginx-mod-mail amd64 1.18.0-0ubuntu1.2 [42.5 kB]
Get:15 http://dp1.clouds.archive.ubuntu.com/ubuntu focal-updates/main amd64 libnginx-mod-stream amd64 1.18.0-0ubuntu1.2 [67.3 kB]
Get:16 http://dp1.clouds.archive.ubuntu.com/ubuntu focal-updates/main amd64 nginx-core amd64 1.18.0-0ubuntu1.2 [425 kB]
Get:17 http://dp1.clouds.archive.ubuntu.com/ubuntu focal-updates/main amd64 nginx all 1.18.0-0ubuntu1.2 [3620 B]
Fetched 2432 kB in 1s (4234 kB/s)
Preconfiguring packages ...
Selecting previously unselected package fonts-dejavu-core.
(Reading database ... 42303 files and directories currently installed.)
Preparing to unpack .../00-fonts-dejavu-core_2.37-1_all.deb ...
Unpacking fonts-dejavu-core (2.37-1) ...
Selecting previously unselected package fontconfig-config.
Preparing to unpack .../01-fontconfig-config_2.13.1-2ubuntu3_all.deb ...
Unpacking fontconfig-config (2.13.1-2ubuntu3) ...
Selecting previously unselected package libfontconfig1:amd64.
Preparing to unpack .../02-libfontconfig1_2.13.1-2ubuntu3_amd64.deb ...
Unpacking libfontconfig1:amd64 (2.13.1-2ubuntu3) ...
Selecting previously unselected package libjpeg-turbo8:amd64.
Preparing to unpack .../03-libjpeg-turbo8_2.0.3-0ubuntu1.20.04.1_amd64.deb ...
Unpacking libjpeg-turbo8:amd64 (2.0.3-0ubuntu1.20.04.1) ...
Selecting previously unselected package libjpeg8:amd64.
Preparing to unpack .../04-libjpeg8_8c-2ubuntu8_amd64.deb ...
Unpacking libjpeg8:amd64 (8c-2ubuntu8) ...
Selecting previously unselected package libjbig0:amd64.
Preparing to unpack .../05-libjbig0_2.1-3.1build1_amd64.deb ...
Unpacking libjbig0:amd64 (2.1-3.1build1) ...
Selecting previously unselected package libwebp6:amd64.
Preparing to unpack .../06-libwebp6_0.6.1-2ubuntu0.20.04.1_amd64.deb ...
Unpacking libwebp6:amd64 (0.6.1-2ubuntu0.20.04.1) ...
Selecting previously unselected package libtiff5:amd64.
Preparing to unpack .../07-libtiff5_4.1.0+git191117-2ubuntu0.20.04.2_amd64.deb ...
Unpacking libtiff5:amd64 (4.1.0+git191117-2ubuntu0.20.04.2) ...
Selecting previously unselected package libxpm4:amd64.
Preparing to unpack .../08-libxpm4_1%3a3.5.12-1_amd64.deb ...
Unpacking libxpm4:amd64 (1:3.5.12-1) ...
Selecting previously unselected package libgd3:amd64.
Preparing to unpack .../09-libgd3_2.2.5-5.2ubuntu2.1_amd64.deb ...
Unpacking libgd3:amd64 (2.2.5-5.2ubuntu2.1) ...
Selecting previously unselected package nginx-common.
Preparing to unpack .../10-nginx-common_1.18.0-0ubuntu1.2_all.deb ...
Unpacking nginx-common (1.18.0-0ubuntu1.2) ...
Selecting previously unselected package libnginx-mod-http-image-filter.
Preparing to unpack .../11-libnginx-mod-http-image-filter_1.18.0-0ubuntu1.2_amd64.deb ...
Unpacking libnginx-mod-http-image-filter (1.18.0-0ubuntu1.2) ...
Selecting previously unselected package libnginx-mod-http-xslt-filter.
Preparing to unpack .../12-libnginx-mod-http-xslt-filter_1.18.0-0ubuntu1.2_amd64.deb ...
Unpacking libnginx-mod-http-xslt-filter (1.18.0-0ubuntu1.2) ...
Selecting previously unselected package libnginx-mod-mail.
Preparing to unpack .../13-libnginx-mod-mail_1.18.0-0ubuntu1.2_amd64.deb ...
Unpacking libnginx-mod-mail (1.18.0-0ubuntu1.2) ...
Selecting previously unselected package libnginx-mod-stream.
Preparing to unpack .../14-libnginx-mod-stream_1.18.0-0ubuntu1.2_amd64.deb ...
Unpacking libnginx-mod-stream (1.18.0-0ubuntu1.2) ...
Selecting previously unselected package nginx-core.
Preparing to unpack .../15-nginx-core_1.18.0-0ubuntu1.2_amd64.deb ...
Unpacking nginx-core (1.18.0-0ubuntu1.2) ...
Selecting previously unselected package nginx.
Preparing to unpack .../16-nginx_1.18.0-0ubuntu1.2_all.deb ...
Unpacking nginx (1.18.0-0ubuntu1.2) ...
Setting up libxpm4:amd64 (1:3.5.12-1) ...
Setting up nginx-common (1.18.0-0ubuntu1.2) ...
Created symlink /etc/systemd/system/multi-user.target.wants/nginx.service → /lib/systemd/system/nginx.service.
Setting up libjbig0:amd64 (2.1-3.1build1) ...
Setting up libnginx-mod-http-xslt-filter (1.18.0-0ubuntu1.2) ...
Setting up libwebp6:amd64 (0.6.1-2ubuntu0.20.04.1) ...
Setting up fonts-dejavu-core (2.37-1) ...
Setting up libjpeg-turbo8:amd64 (2.0.3-0ubuntu1.20.04.1) ...
Setting up libjpeg8:amd64 (8c-2ubuntu8) ...
Setting up libnginx-mod-mail (1.18.0-0ubuntu1.2) ...
Setting up fontconfig-config (2.13.1-2ubuntu3) ...
Setting up libnginx-mod-stream (1.18.0-0ubuntu1.2) ...
Setting up libtiff5:amd64 (4.1.0+git191117-2ubuntu0.20.04.2) ...
Setting up libfontconfig1:amd64 (2.13.1-2ubuntu3) ...
Setting up libgd3:amd64 (2.2.5-5.2ubuntu2.1) ...
Setting up libnginx-mod-http-image-filter (1.18.0-0ubuntu1.2) ...
Setting up nginx-core (1.18.0-0ubuntu1.2) ...
Setting up nginx (1.18.0-0ubuntu1.2) ...
Processing triggers for ufw (0.36-6) ...
Processing triggers for systemd (245.4-4ubuntu3.2) ...
Processing triggers for man-db (2.9.1-1) ...
Processing triggers for libc-bin (2.31-0ubuntu9) ...

root@ubuntu-basic-1-2-30gb-net:/home/ubuntu# sudo ufw allow 'Nginx HTTP'
Rules updated
Rules updated (v6)

root@ubuntu-basic-1-2-30gb-net:/home/ubuntu# sudo ufw allow 'Nginx HTTPS'
Rules updated
Rules updated (v6)

root@ubuntu-basic-1-2-30gb-net:/home/ubuntu# systemctl status nginx
● nginx.service - A high performance web server and a reverse proxy server
     Loaded: loaded (/lib/systemd/system/nginx.service; enabled; vendor preset:>
     Active: active (running) since Fri 2022-01-07 12:08:53 UTC; 52s ago
       Docs: man:nginx(8)
   Main PID: 5781 (nginx)
      Tasks: 2 (limit: 2282)
     Memory: 3.6M
     CGroup: /system.slice/nginx.service
             ├─5781 nginx: master process /usr/sbin/nginx -g daemon on; master_>
             └─5785 nginx: worker process

Jan 07 12:08:53 ubuntu-basic-1-2-30gb-test2 systemd[1]: Starting A high perform>
Jan 07 12:08:53 ubuntu-basic-1-2-30gb-test2 systemd[1]: Started A high performa>
lines 1-13/13 (END)
● nginx.service - A high performance web server and a reverse proxy server
```
7. По инструкции настройм nginx на https, используя ранее подготовленный сертификат, будем использовать стандартную стартовую страницу nginx для демонстрации работы сервера.
Объединим три сертификата (сам SSL-сертификат, корневой и промежуточный сертификаты) в один файл website.crt и создим файл website.key и скопируем в него содержимое приватного ключа сертификата private_key.
```bash
root@ubuntu-basic-1-2-30gb-net:/home/ubuntu# vim website.crt
root@ubuntu-basic-1-2-30gb-net:/home/ubuntu# vim website.key
```
Скопируем файлы website.crt и website.key на сервер в директорию /etc/ssl/
```bash
root@ubuntu-basic-1-2-30gb-net:/home/ubuntu# sudo cp website.crt /etc/ssl
root@ubuntu-basic-1-2-30gb-net:/home/ubuntu# sudo cp website.key /etc/ssl
```
Откроем конфигурационный файл Nginx и добавим следующие строки в середине файла после поля SSL configuration:
```bash
root@ubuntu-basic-1-2-30gb-net:/etc/ssl# sudo vim /etc/nginx/sites-available/default

server {

        # SSL configuration
        #
        listen 443 ssl default_server;
        listen [::]:443 ssl default_server;
        ssl_certificate /etc/ssl/website.crt;
        ssl_certificate_key /etc/ssl/website.key;

}
```
Проведём тестирование, чтобы убедится в отсутствии ошибок синтаксиса в файлах Nginx:
```bash
sudo nginx -t

nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
```
Перезагрузим nginx:
```bash
root@ubuntu-basic-1-2-30gb-net:/home/ubuntu# sudo systemctl restart nginx
```
Проверим статус nginx:
```bash
root@ubuntu-basic-1-2-30gb-net:/home/ubuntu# sudo systemctl status nginx 

● nginx.service - A high performance web server and a reverse proxy server
     Loaded: loaded (/lib/systemd/system/nginx.service; enabled; vendor preset: en>
     Active: active (running) since Fri 2022-01-07 13:03:37 UTC; 10s ago
       Docs: man:nginx(8)
    Process: 6405 ExecStartPre=/usr/sbin/nginx -t -q -g daemon on; master_process >
    Process: 6414 ExecStart=/usr/sbin/nginx -g daemon on; master_process on; (code>
   Main PID: 6415 (nginx)
      Tasks: 2 (limit: 2282)
     Memory: 2.6M
     CGroup: /system.slice/nginx.service
             ├─6415 nginx: master process /usr/sbin/nginx -g daemon on; master_pro>
             └─6416 nginx: worker process
```

8. Откройте в браузере на хосте https адрес страницы, которую обслуживает сервер nginx.  
Мой сервер находится в облаке, я добавил себе на локальную машину с Windows соответствие test.example.com в файл hosts, после этого открыл сайт:
Сайт в браузере Google Chrome
![img_3.png](img_3.png)

9. Создайте скрипт, который будет генерировать новый сертификат в vault:
  - генерируем новый сертификат так, чтобы не переписывать конфиг nginx;
  - перезапускаем nginx для применения нового сертификата.
```bash
root@ubuntu-basic-1-2-30gb-net:/etc/ssl# vim newsert

#!/bin/bash

export VAULT_ADDR=http://127.0.0.1:8200
export VAULT_TOKEN=root

#creat role
vault write pki_int/roles/example-dot-com \
     allowed_domains="example.com" \
     allow_subdomains=true \
     max_ttl="730h"

#create certificate, 30 days
vault write -format=json pki/issue/example-dot-com common_name="test.example.com" ttl="730h" > /etc/ssl/website.crt

cat /etc/ssl/website.crt | jq -r .data.certificate > /etc/ssl/website.crt.pem
cat /etc/ssl/website.crt | jq -r .data.ca_chain[] >> /etc/ssl/website.crt.pem
cat /etc/ssl/website.crt | jq -r .data.private_key > /etc/ssl/website.key
#mv /home/ubuntu/website.crt.pem /etc/ssl/
#mv /home/ubuntu/website.key /etc/ssl/

nginx -t
if [[ $? -eq 0 ]]
then
    echo "Certificate was writed sussesfuly. Nginx will be restart"
sudo systemctl restart nginx
else
    echo "Error write cerificate"
fi

root@ubuntu-basic-1-2-30gb-net:/etc/ssl# chmod +x newsert
```
10. Поместите скрипт в crontab, чтобы сертификат обновлялся какого-то числа каждого месяца в удобное для вас время.  
Проверил сначала будет ли запускаться из под cron запуская его каждые 30 мин, сработало, поправил на удобное время:
```bash
root@ubuntu-basic-1-2-30gb-net:/etc/ssl# sudo crontab -e
no crontab for root - using an empty one

Select an editor.  To change later, run 'select-editor'.
  1. /bin/nano        <---- easiest
  2. /usr/bin/vim.basic
  3. /usr/bin/vim.tiny
  4. /bin/ed

Choose 1-4 [1]: 3

# Сделаем проверку работы с частотой срабатывания раз в месяц. Проверка будет 7 числа в 13:24 каждый месяц.
24 13 7 * * /etc/ssl/nesert

crontab: installing new crontab
```
Проверить работу можно командой:
```bash
root@ubuntu-basic-1-2-30gb-net:/etc/ssl# ls -l

total 41
drwxr-xr-x 2 root root 12288 Aug  4  2020 certs
-rwxr-xr-x 1 root root   847 Jan  7 13:14 newsert
-rw-r--r-- 1 root root 10909 Apr 20  2020 openssl.cnf
drwx------ 2 root root  4096 Apr 20  2020 private
-rw-r--r-- 1 root root  1784 Jan  7 13:24 website.key
-rw-r--r-- 1 root root  3703 Jan  7 13:24 website.crt
-rw-r--r-- 1 root root  2567 Jan  7 13:24 website.crt.pem
```

