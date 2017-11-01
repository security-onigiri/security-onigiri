---
layout: post
title: Rails on Ubuntu
author: bananaapple
tags:
  - ruby on rails
categories:
  - computer science
date: 2017-06-22 12:39:00
---
# Introduction

簡單記錄一下 Ruby on Rails server setup
這裡用的是最新版的 Ubuntu 17.04 server 版
這篇會教你設定

- nginx
- passenger
- Let's Encrypt(https)
- postfix(mail server)

因為要設定 Let's Encrypt 和 postfix，所以要有一個 DNS 的 A Record 指向你的 ip 位置

## Passenger

這裡主要有三種方法可以選

詳細內容可以參考[這篇](https://www.phusionpassenger.com/library/indepth/integration_modes.html)

1. Standalone mode

只有 passenger

2. Nginx integration mode

passenger 和 nginx 整合

3. Apache integration mode

passenger 和 apache 整合

這裡選用的是第二種方法

因為 nginx 的效能比 apache 好

接著就開始安裝 nginx + passenger，大部分的步驟都跟[這篇](https://www.phusionpassenger.com/library/install/nginx/install/oss/xenial/)一樣

稍微要注意一下 ubuntu 的 code name，像是 17.04 的 code name 是 Zesty
在加 apt 的 repo 的時候要稍微改一下 code name

### Install passenger packages

`deb https://oss-binaries.phusionpassenger.com/apt/passenger xenial main` =>
`deb https://oss-binaries.phusionpassenger.com/apt/passenger zesty main`

```bash
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 561F9B9CAC40B2F7
sudo apt-get install -y apt-transport-https ca-certificates

# Add our APT repository
sudo sh -c 'echo deb https://oss-binaries.phusionpassenger.com/apt/passenger zesty main > /etc/apt/sources.list.d/passenger.list'
sudo apt-get update

# Install Passenger + Nginx
sudo apt-get install -y nginx-extras passenger
```

### Enable the passenger nginx module and restart nginx

修改 `/etc/nginx/nginx.conf` 檔案 將 `# include /etc/nginx/passenger.conf` 取消註解

重啟 nginx

```bash
sudo service nginx restart
```
### Notice

另外網路上還有另一種裝 passenger 和 nginx 的方法

是自行下載下來編譯，所有的套件最後會放在 /opt 資料夾底下

我自己是不推薦這種方法，因為還要自己去設定 service script

## Let's Encrypt

詳細可以參考[這篇](https://www.digitalocean.com/community/tutorials/how-to-secure-nginx-with-let-s-encrypt-on-ubuntu-16-04)

## Postfix

設定好 Let's Encrypt 後就會有 ssh key 了

### Install postfix package

```bash
sudo apt install -y postfix
```

### Configure postfix

修改 `/etc/postfix/main.cf`

原本應該是

```bash
# TLS parameters
smtpd_tls_cert_file=/etc/ssl/certs/ssl-cert-snakeoil.pem
smtpd_tls_key_file=/etc/ssl/private/ssl-cert-snakeoil.key
```

修改成

```bash
# TLS parameters
smtpd_tls_cert_file=/etc/letsencrypt/live/bamboofox.nctucs.net/fullchain.pem
smtpd_tls_key_file=/etc/letsencrypt/live/bamboofox.nctucs.net/privkey.pem
smtp_tls_security_level=may
smtpd_tls_security_level=may
```
我的 domain name 是 `bamboofox.nctucs.net`，這裡要修改成自己的 domain name

`smtp_tls_security_level=may` 和 `smtpd_tls_security_level=may` 是讓 email 寄信和收信加密

將自己的 ip 也加進 relay 的 list

修改 `/etc/postfix/main.cf`

```bash
mynetworks = 127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128
```

修改成

```bash
mynetworks = 127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128 140.113.209.18 
```

這邊很重要因為之後用 `devise` 寄信的時候會有 `certification` 的問題

### Restart postfix

```bash
sudo service postfix restart
```

## Deploy ruby on rails project

參考[這篇](https://gorails.com/deploy/ubuntu/16.04)

直接從創 `deploy` 帳號開始做

### Create deploy user

```bash
sudo adduser deploy
sudo adduser deploy sudo
su deploy
```

### Install rvm

```bash
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
\curl -sSL https://get.rvm.io | bash -s stable
echo "source ~/.rvm/scripts/rvm" >> .bashrc
source ~/.rvm/scripts/rvm
rvm install 2.4.0
rvm use 2.4.0 --default
```
### Install basic gems

```bash
gem install bundler
gem install rails
```

### Show passenger config

執行指令

```bash
passenger-config about ruby-command
```

會得到

```bash
passenger-config was invoked through the following Ruby interpreter:
  Command: /home/deploy/.rvm/gems/ruby-2.4.0/wrappers/ruby
  Version: ruby 2.4.0p0 (2016-12-24 revision 57164) [x86_64-linux]
  To use in Apache: PassengerRuby /home/deploy/.rvm/gems/ruby-2.4.0/wrappers/ruby
  To use in Nginx : passenger_ruby /home/deploy/.rvm/gems/ruby-2.4.0/wrappers/ruby
  To use with Standalone: /home/deploy/.rvm/gems/ruby-2.4.0/wrappers/ruby /usr/bin/passenger start
```

這要用在等下的 nginx config

### Install nvm

```bash
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.2/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" # This loads nvm
nvm install stable
```

### Install yarn

```bash
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt-get update && sudo apt-get install yarn
```

### Create basic app

```bash
rails new myapp --webpack=react
```

### Deploy on nginx

修改 myapp 裡的 `config/secrets.yml`

這裡 secret 可以使用 `rake secret` 產生

```bash
production:
  secret_key_base: d7913c3e87fadd4312ee1c5c1b13320caeecc72548f20b9122e2a1bf9ccdf0e9ecb86675168e578b5b3e960a81daa967c0081f69b082eb0c0e5df4b5810d71a9
```

修改 `/etc/nginx/sites-available/default`

```bash
server {

        # SSL configuration
        #
        listen 443 ssl http2 default_server;
        listen [::]:443 ssl http2 default_server;
        include snippets/ssl-bamboofox.nctucs.net.conf;
        include snippets/ssl-params.conf;
		
        # Add these three lines
        
        passenger_enabled on;
        server_name bamboofox.nctucs.net;
        root /home/deploy/myapp/public;
}
```

重啟 nginx

```bash
sudo service nginx restart
```
