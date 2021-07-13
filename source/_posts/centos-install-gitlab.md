---
title: CentOS安装GitLab
tags: 
  - Linux
  - GitLab
categories: 
  - Linux
---
### 安装和配置

在CentOS中,以下命令将在系统防火墙中打开HTTP，HTTPS和SSH访问

```
sudo yum install -y curl policycoreutils-python openssh-server perl
sudo systemctl enable sshd
sudo systemctl start sshd
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo systemctl reload firewalld
```

接下来，安装Postfix用来发送通知电子邮件。如果要使用其他方式发送电子邮件，请跳过此步骤并在安装GitLab之后配置外部SMTP服务器

```
sudo yum install postfix
sudo systemctl enable postfix
sudo systemctl start postfix
```

在安装Postfix的过程中，可能会出现一些配置选项。选择“ Internet Site”，然后按Enter。使用服务器的外部DNS作为“mail name”，然后按Enter。如果出现其他选项，请继续按Enter接受默认设置。

### 添加仓库并安装

添加GitLab软件包存储库

```
curl https://packages.gitlab.com/install/repositories/gitlab/gitlab-ee/script.rpm.sh | sudo bash
```

接下来，安装GitLab软件包。确保已正确设置DNS，然后更改 https://gitlab.example.com 为要访问GitLab实例的URL。安装将自动配置并在该URL上启动GitLab。

```
sudo EXTERNAL_URL="http://gitlab.example.com" 
sudo yum install -y gitlab-ee
```

### 浏览登录

执行完以上操作,GitLab已经成功安装,可以直接访问设置的域名进行访问。首次访问时,将被重定向到密码重置界面。提供初始管理员帐户的密码，然后重定向到登录界面。使用默认帐户的用户名<code>root</code>进行登录。

### 常用命令

| 执行命令 | 命令功能 |
|--|--|
|sudo gitlab-ctl reconfigure|	重启配置，并启动gitlab服务|
|sudo gitlab-ctl start|	启动所有 gitlab|
|sudo gitlab-ctl restart	|重新启动GitLab|
|sudo gitlab-ctl stop|	停止所有 gitlab|
|sudo gitlab-ctl status	|查看服务状态|
|sudo gitlab-ctl tail	|查看Gitlab日志|
|sudo vim /etc/gitlab/gitlab.rb	|修改默认的配置文件|
|gitlab-rake gitlab:check SANITIZE=true --trace	|检查gitlab|




