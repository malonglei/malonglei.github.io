---
title: CentOS安装Docker
tags: 
  - Linux
  - Docker
categories: 
  - Linux
---
### 前提

#### 系统要求

安装Docker,推荐使用CentOS 7 或者 8 的稳定版本

#### 卸载旧版本

如果已经安装了旧版本的Docker,或者不清楚是否已经安装了Docker想要重新安装最新版本,需要先卸载旧版本

下面命令会卸载旧版本及相关依赖项

```
sudo yum remove docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-engine
```

### 安装

Docker的安装方式有以下几种,可以根据自身选择不同的安装方式

1. 设置 yum 仓库的方式安装,这种方式安装比较简单,有利于后续版本升级,也是**最推荐**的一种安装方式
2. 如果你希望手动管理升级,或者安装时没有网络,则可以选择RPM安装包的方式
3. 在测试环境,或者希望快速搭建Docker环境,可以使用一键安装脚本进行安装

#### 仓库方式

**设置仓库**

```
# 安装yum工具包,提供了一些管理工具
sudo yum install -y yum-utils
# 增加docker仓库源
 sudo yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo
```

有些仓库模式是禁用状态,如果你有需要可以手动开启

```
sudo yum-config-manager --enable docker-ce-nightly
sudo yum-config-manager --enable docker-ce-test
```

**安装**

安装最新版本,可以直接执行以下命令

```
sudo yum -y install docker-ce docker-ce-cli containerd.io
```

对版本有要求,想要安装指定版本,可以执行以下命令列出所有版本

```
yum list docker-ce --showduplicates | sort -r

docker-ce.x86_64  3:18.09.1-3.el7                     docker-ce-stable
docker-ce.x86_64  3:18.09.0-3.el7                     docker-ce-stable
docker-ce.x86_64  18.06.1.ce-3.el7                    docker-ce-stable
docker-ce.x86_64  18.06.0.ce-3.el7                    docker-ce-stable
```

可以选择需要的版本,然后安装指定的版本,例如 docker-ce-18.09.1

```
sudo yum -y install docker-ce-<VERSION_STRING> docker-ce-cli-<VERSION_STRING> containerd.io
```

#### RPM方式

**下载RPM安装包**

跳转到[https://download.docker.com/linux/centos/](https://download.docker.com/linux/centos/) 选择对应的CentOS版本,然后进入x86_64 /stable/Packages/目录下选择要安装的对应版本的RPM安装包

**安装**

将RPM安装包上传到服务器,然后执行以下命令进行安装

```
sudo yum install /path/to/package.rpm
```

#### 一键安装包方式

官方为了简化Docker的安装步骤,提供了一键安装包方式,但是不建议在生产环境中使用,如果为了测试或者快速搭建,可以选择此安装方式

**潜在风险**

1. 脚本需要运行root或具有sudo特权。因此，在运行脚本之前，应仔细检查和审核脚本。
2. 这些脚本尝试检测Linux发行版和版本，并为您配置软件包管理系统。此外，脚本不允许您自定义任何安装参数。
3. 这些脚本将安装软件包管理器的所有依赖项和建议，而无需进行确认。根据主机的当前配置，这可能会安装大量软件包。
4. 该脚本未提供用于指定要安装哪个版本的Docker的选项，而是安装了发布的最新版本。
5. 如果已经使用其他方式在主机上安装了Docker，请不要使用便捷脚本。

**安装**

执行以下命令进行安装

```
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
```

### 启动

#### 启动Docker

执行以下命令启动Docker

```
# 将Docker加入开启自启动
sudo systemctl enable docker
# 启动Docker
sudo systemctl start docker
```

#### 验证Docker

Docker启动成功后,可以运行以下命令验证运行状态,保证Docker已经成功启动

```
docker version

Client: Docker Engine - Community
 Cloud integration: 1.0.7
 Version:           20.10.2
 API version:       1.41
 Go version:        go1.13.15
 Git commit:        2291f61
 Built:             Mon Dec 28 16:12:42 2020
 OS/Arch:           darwin/amd64
 Context:           default
 Experimental:      true

Server: Docker Engine - Community
 Engine:
  Version:          20.10.2
  API version:      1.41 (minimum version 1.12)
  Go version:       go1.13.15
  Git commit:       8891c58
  Built:            Mon Dec 28 16:15:28 2020
  OS/Arch:          linux/amd64
  Experimental:     false
 containerd:
  Version:          1.4.3
  GitCommit:        269548fa27e0089a8b8278fc4fc781d7f65a939b
 runc:
  Version:          1.0.0-rc92
  GitCommit:        ff819c7e9184c13b7c2607fe6c30ae19403a7aff
 docker-init:
  Version:          0.19.0
  GitCommit:        de40ad0
```

Docker有服务端和客户端,两个全部成功打印说明启动成功
