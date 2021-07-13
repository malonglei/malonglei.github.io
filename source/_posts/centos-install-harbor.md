---
title: CentOS安装Harbor
tags: 
  - Linux
  - Harbor
categories: 
  - Linux
---
Harbor是一个开源的容器管理项目，用于存储、签名和扫描容器。Harbor具备安全性、身份和管理功能来管理Docker容器。Harbor支持在服务之间复制映像，还提供高级安全功能，如用户管理、访问控制和活动审核。

## 安装Docker

安装过程请查看另一篇文章[CentOS安装Docker](https://www.mllweb.com/archives/93)来进行安装

安装完启动docker

## 安装docker-compose

运行以下命令下载Docker Compose的当前稳定版本：

```
sudo curl -L "https://github.com/docker/compose/releases/download/1.28.5/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
```

二进制文件添加执行权限

```
sudo chmod +x /usr/local/bin/docker-compose
```

## 安装Harbor

### 下载

前往[https://github.com/goharbor/harbor/releases](https://github.com/goharbor/harbor/releases)下载harbor的文件

harbor分为离线安装和在线安装，选择离线安装即可

```
wget https://github.com/goharbor/harbor/releases/download/v2.1.4/harbor-offline-installer-v2.1.4.tgz
```

解压后文件列表如下

```
common.sh
harbor.v2.1.4.tar.gz
harbor.yml.tmpl
install.sh
LICENSE
prepare
```

### 配置信息

harbor提供了配置的模版文件，我们复制一份

```
cp harbor.yml.tmpl cp harbor.yml
```

我们需要修改一下**harbor.yml.tmpl**配置信息，将**hostname**修改为本机当前IP地址

```
#The IP address or hostname to access admin UI and registry service.
#DO NOT use localhost or 127.0.0.1, because Harbor needs to be accessed by external clients.
hostname: 192.168.8.197
```

harbor默认开启了https访问，如果你有https证书可以配置一下，如果没有证书则可以注释掉相关配置信息

```
#https related config
#https:
  # https port for harbor, default is 443
  # port: 443
  # The path of cert and key files for nginx
  # certificate: /your/certificate/path
  # private_key: /your/private/key/path
```

harbor默认的登陆密码是**Harbor12345**，如果需要更换，可以在配置信息中修改

```
# The initial password of Harbor admin
# It only works in first time to install harbor
# Remember Change the admin password from UI after launching Harbor.
harbor_admin_password: Harbor12345
```

### 安装

修改完配置信息以后，执行**install.sh**安装脚本

```
./install.sh
```

![](https://image.mllweb.com/wp-content/uploads/2021/03/image-10.png)


出现以上内容说明Harbor已经成功安装

## 访问

harbor默认的登陆账号是**admin**，密码是**Harbor12345**

默认端口是80，我们直接在浏览器输入ip地址进行访问就可以

## 上传测试

修改 **/etc/hosts **将本机ip映射到 harbor.custom.com 下 ,然后将本机已有的镜像push到仓库进行测试

![](https://image.mllweb.com/wp-content/uploads/2021/03/image-11.png)

说明镜像已经成功推送到harbor仓库，至此，我们的harbor搭建完成。
