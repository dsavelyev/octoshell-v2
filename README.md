# README
Base application for modular version of Octoshell.


## Installation and starting

1. install rbenv (e.g. `curl https://raw.githubusercontent.com/fesplugas/rbenv-installer/master/bin/rbenv-installer | bash`)
1. install jdk (oracle is better).
1. install jruby-9.0.5.0 (`rbenv install jruby-9.0.5.0`; `rbenv local jruby-9.0.5.0`)
1. `gem install bundler`
1. `bundle install`
1. install redis
1. install postgresql
1. `git clone`
1. add database user octo: `sudo -u postgres createuser -s octo`
1. set database password: `sudo -u postgres psql` then enter `\password octo` and enter password. Exit with `\q`.
1. fill database password in `config/database.yml`
1. `bin/rake db:setup`
1. optional run tests: `bin/rspec .`
1. After "seeds" example cluster will be created. You should login to your cluster as root, create new user 'octo'. Login as `admin@octoshell.ru` in web-application. Go to "Admin/Cluster control" and edit "Test cluster". Copy `octo` public key from web to /home/octo/.ssh/authorized_keys.
1. Start sidekiq: `./run-sidekiq`
1. Start server: `./run`
1. Enter as admin with login `admin@octoshell.ru` and password `12345`

## Deploy

1. Prepare deploy server (1-10 from above)
1. Make sure you can ssh to deploy server without password
1. `git clone`
1. Rename `deploy_env.sample` to `deploy_env` and fill right environment
1. `./do_deploy_setup`
1. `./do_deploy`
1. `./deploy_copy_files`
1. `./do_after_1_deploy`
1. ssh to deploy server and start all by `systemctl start octoshell`

All deploys after this can be done by `git fetch; ./do_deploy`, and then on deploy server `systemctl restart octoshell`.

# README
Базовое приложение для модульной версии octoshell.

## Установка и запуск

1. установить rbenv (например `curl https://raw.githubusercontent.com/fesplugas/rbenv-installer/master/bin/rbenv-installer | bash`)
1. установить jdk (желательно oracle).
1. установить jruby-9.0.5.0 (`rbenv install jruby-9.0.5.0`; `rbenv local jruby-9.0.5.0`)
1. `gem install bundler`
1. `bundle install`
1. установить redis
1. установить postgresql
1. `git clone`
1. добавить пользователя БД octo: `sudo -u postgres createuser -s octo`
1. установить пароль для пользоватедя БД: `sudo -u postgres psql` then enter `\password octo` and enter password. Exit with `\q`.
1. прописать пароль в `config/database.yml`
1. `bin/rake db:setup`
1. запустить тесты (по желанию): `bin/rspec .`
1. После прогона сидов создастся тестовый «кластер». Для синхронизации с ним необходимо доступ на него под пользователем root. Затем залогиниться в приложение как администратор `admin@octoshell.ru`. В «Админке проектов» зайти в раздел «Управление кластерами» и открыть Тестовый кластер. Скопировать публичный ключ админа кластера (по умолчанию `octo`) в /home/octo/.ssh/authorized_keys.
1. Запустить sidekiq: `./run-sidekiq`
1. Запустить сервер: `./run`
1. Войти по адресу `http://localhost:3000/` с логином `admin@octoshell.ru` и паролем `12345`

## Деплой

1. Подготовьте сервер деплоя (пп. 1-10 из раздела "Установка...")
1. Убедитесь, что вы можете входить на сервер деплоя по ssh без пароля
1. `git clone`
1. Переименовать `deploy_env.sample` в `deploy_env` и внесите нужные правки
1. `./do_deploy_setup`
1. `./do_deploy`
1. `./deploy_copy_files`
1. `./do_after_1_deploy`
1. Войдите на сервер деплоя и запустите сервисы `systemctl start octoshell`

Последующие деплои можно выполнять командой `git fetch; ./do_deploy` и последующим перезапуском сервиса на сервере `systemctl restart octoshell`.


