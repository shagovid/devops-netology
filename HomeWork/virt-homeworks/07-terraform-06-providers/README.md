# Домашнее задание к занятию "7.6. Написание собственных провайдеров для Terraform."

Бывает, что 
* общедоступная документация по терраформ ресурсам не всегда достоверна,
* в документации не хватает каких-нибудь правил валидации или неточно описаны параметры,
* понадобиться использовать провайдер без официальной документации,
* может возникнуть необходимость написать свой провайдер для системы используемой в ваших проектах.   

## Задача 1. 
Давайте потренируемся читать исходный код AWS провайдера, который можно склонировать от сюда: 
[https://github.com/hashicorp/terraform-provider-aws.git](https://github.com/hashicorp/terraform-provider-aws.git).
Просто найдите нужные ресурсы в исходном коде и ответы на вопросы станут понятны.  


1. Найдите, где перечислены все доступные `resource` и `data_source`, приложите ссылку на эти строки в коде на 
гитхабе.   
1. Для создания очереди сообщений SQS используется ресурс `aws_sqs_queue` у которого есть параметр `name`. 
    * С каким другим параметром конфликтует `name`? Приложите строчку кода, в которой это указано.
    * Какая максимальная длина имени? 
    * Какому регулярному выражению должно подчиняться имя? 

### Решение:
1. `resource` перечисленны в файле [provider.go перечисленны со строки 868](https://github.com/hashicorp/terraform-provider-aws/blob/de6bf7541dd8a5c81d0471e7e8cb76eb76578e66/internal/provider/provider.go#L868)  
   `data_source` файл тот же [provider.go начиная со строки 412](https://github.com/hashicorp/terraform-provider-aws/blob/de6bf7541dd8a5c81d0471e7e8cb76eb76578e66/internal/provider/provider.go#L412)

2. Для создания очереди сообщений SQS используется ресурс `aws_sqs_queue` у которого есть параметр `name`.
 
* С каким другим параметром конфликтует `name`? Приложите строчку кода, в которой это указано:
```shell
ConflictsWith: []string{"name_prefix"},
```

* Какая максимальная длина имени?: 
```shell
не более 80 символов
errors = append(errors, fmt.Errorf("%q cannot be longer than 80 characters", k))
```

* Какому регулярному выражению должно подчиняться имя?:
```shell
`^[0-9A-Za-z-_]+(\.fifo)?$`
```