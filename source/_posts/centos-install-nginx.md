---
title: CentOS安装Nginx
tags: 
  - Linux
  - Nginx
categories: 
  - Linux
---
Nginx是一款轻量级的Web服务器/反向代理服务器及电子邮件（IMAP/POP3）代理服务器，在BSD-like 协议下发行。其特点是占有内存少，并发能力强。

通常的安装方式有两种：yum安装/源码安装

**yum安装** 优点：安装快捷方便，缺点：无法指定特殊版本、无法指定扩展功能

**源码安装** 优点：可完全定制化扩展，缺点：相当于yum安装繁琐一些

## yum安装

安装准备条件

```
sudo yum -y install yum-utils
```

配置仓库

```
cat << EOF > /etc/yum.repos.d/nginx.repo
[nginx-stable]
name=nginx stable repo
baseurl=http://nginx.org/packages/centos/\$releasever/\$basearch/
gpgcheck=1
enabled=1
gpgkey=https://nginx.org/keys/nginx_signing.key
module_hotfixes=true
[nginx-mainline]
name=nginx mainline repo
baseurl=http://nginx.org/packages/mainline/centos/\$releasever/\$basearch/
gpgcheck=1
enabled=0
gpgkey=https://nginx.org/keys/nginx_signing.key
module_hotfixes=true
EOF
```

默认情况下，使用稳定的nginx软件包的存储库。如果要使用主线nginx软件包，请运行以下命令：

```
sudo yum-config-manager --enable nginx-mainline
```

安装

```
sudo yum -y install nginx
sudo systemctl enable --now nginx
```

## 源码安装

### 安装编译工具及库文件

```
yum -y install make zlib zlib-devel gcc-c++ libtool openssl openssl-devel
```

### 安装PCRE



前往[https://sourceforge.net/projects/pcre/files/pcre/](https://sourceforge.net/projects/pcre/files/pcre/)下载安装包

```
cd /usr/local/src/
wget https://sourceforge.net/projects/pcre/files/pcre/8.44/pcre-8.44.tar.gz
```

解压

```
tar zxvf pcre-8.44.tar.gz
cd pcre-8.44
```

编译安装

```
# 编译
./configure --prefix=/usr/local/pcre
# 安装
make &amp;&amp; make install
```

### 安装nginx

前往[http://nginx.org/en/download.html](http://nginx.org/en/download.html)下载对应版本的源码包

```
cd /usr/local/src/
wget http://nginx.org/download/nginx-1.19.8.tar.gz
```

解压

```
tar zxvf nginx-1.19.8.tar.gz
cd nginx-1.19.8
```

编译源文件

```
./configure \
      --prefix=/usr/local/nginx \
      --sbin-path=/usr/local/nginx/nginx \
      --conf-path=/usr/local/nginx/nginx.conf \
      --pid-path=/usr/local/nginx/nginx.pid \
      --with-http_ssl_module \
      --with-pcre=/usr/local/src/pcre-8.44
```


详细的配置信息请参考 [http://nginx.org/en/docs/configure.html](http://nginx.org/en/docs/configure.html) 和 [http://nginx.org/en/docs/](http://nginx.org/en/docs/)  -> **Modules reference**

安装

```
make && make install
```

启动

```
/usr/local/nginx/nginx
```
