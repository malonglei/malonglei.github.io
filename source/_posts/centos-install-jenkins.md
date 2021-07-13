---
title: CentOS安装Jenkins
tags: 
  - Linux
  - Jenkins
categories: 
  - Linux
---
### 系统要求

最低推荐配置:

- 256MB可用内存
- 1GB可用磁盘空间(作为一个Docker容器运行jenkins的话推荐10GB)

为小团队推荐的硬件配置:

- 1GB+可用内存
- 50 GB+ 可用磁盘空间

Jenkins版本分为两条主线,长期支持版本和每周迭代版本

### 长期稳定版本

长期支持版本每12周发版一次稳定版本,建议生产环境使用,比较稳定

```
sudo wget -O /etc/yum.repos.d/jenkins.repo \
    https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
sudo yum -y upgrade
# java-11-openjdk-devel可选，如果已经有java环境则不用安装
sudo yum install jenkins java-11-openjdk-devel
sudo systemctl daemon-reload
```

### 每周更新版本

每周迭代版本每周更新一次,主要面向开发人员修复一些功能,较为稳定

```
sudo wget -O /etc/yum.repos.d/jenkins.repo \
    https://pkg.jenkins.io/redhat/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat/jenkins.io.key
sudo yum -y upgrade
# java-11-openjdk-devel可选，如果已经有java环境则不用安装
sudo yum install jenkins java-11-openjdk-devel
sudo systemctl daemon-reload
```

### 启动Jenkins

你可以使用下面命令启动jenkins

```
# 加入开机启动
sudo systemctl enable jenkins
# 启动Jenkins
sudo systemctl start jenkins
```

你可以使用下面命令检查Jenkins状态

```
sudo systemctl status jenkins
```

当你成功启动以后,可以从控制台看到以下输出

```
Loaded: loaded (/etc/rc.d/init.d/jenkins; generated)
Active: active (running) since Tue 2018-11-13 16:19:01 +03; 4min 57s ago
...
```

### 安装向导

下载安装并运行Jenkins后，开始进入安装向导。

此安装向导会

- 引导您解锁Jenkins
- 自定义使用插件
- 创建第一个Jenkins的管理员用户。

#### 解锁 Jenkins

当您第一次访问Jenkins时，系统会要求您使用自动生成的密码对其进行解锁。

浏览到 http://localhost:8080 （或安装时为Jenkins配置的任何端口），等待解锁 Jenkins 页面出现。

![](https://www.jenkins.io/zh/doc/book/resources/tutorials/setup-jenkins-01-unlock-jenkins-page.jpg)

从Jenkins控制台日志输出中，复制自动生成的字母数字密码（在两组星号之间）。

![](https://www.jenkins.io/zh/doc/book/resources/tutorials/setup-jenkins-02-copying-initial-admin-password.png)

将此 密码 粘贴到管理员密码字段中，然后单击 继续 。

> 如果您在向导中跳过了后续的管理员用户创建步骤， 则此密码作为默认admininstrator帐户的密码（用户名“admin”）

#### 自定义jenkins插件

解锁 Jenkins之后，在 Customize Jenkins 页面内， 您可以安装任何插件作为您初始步骤的一部分。

两个选项可以设置:

- 安装建议的插件 - 安装推荐的一组插件，这些插件基于最常见的用例
- 选择要安装的插件 - 选择安装的插件集。当你第一次访问插件选择页面时，默认选择建议的插件

> 如果您不确定需要哪些插件，请选择 安装建议的插件 。 您可以通过Jenkins中的Manage Jenkins > Manage Plugins 页面在稍后的时间点安装（或删除）其他Jenkins插件

#### 创建第一个管理员用户

最后，在customizing Jenkins with plugins之后，Jenkins要求您创建第一个管理员用户。出现“ 创建第一个管理员用户 ”页面时， 请在各个字段中指定管理员用户的详细信息，然后单击 保存完成

当 Jenkins准备好了 出现时，单击*开始使用 Jenkins*。

> 如果该页面在一分钟后不会自动刷新，请使用Web浏览器手动刷新页面

从这时起，你可以开始使用jenkins了。


