---
title: 使用Keepalived搭建Nginx高可用集群
date: 2024-01-13 00:00:00 +0800
categories: [Distributed]
tags: [nginx,keepalived,distributed]
slug: '1443750446'
author: longlei
---

### 是什么

keepalived是检测服务器状态的软件，如果有一台web服务器宕机，Keepalived将检测到，并将有故障的服务器从系统中删除，同时使用其他服务器代替该服务器的工作，当服务器工作正常后Keepalived自动将服务器加入到服务器集群中，这些工作全部自动完成，不需要人工干涉，需要人工做的只是修复故障的服务器。

### 为什么

下面图片是我们日常比较常见的一种服务架构

![](https://mll-typora.oss-cn-beijing.aliyuncs.com/202401011724312.png)

我们通常将Nginx作为我们的Web服务,当客户端向服务器发送请求时, 由Nginx负责接收,然后转发到我们具体的微服务进行处理


这种结构有一个问题,Nginx是单点的,如果Nginx发生了故障或者机器故障导致无法响应服务,即使后端的各个微服务是正常启动的也无法处理请求


针对这种情况,我们需要对Nginx进行高可用的集群搭建,或者给Nginx配置一个备份机器,当主机器发生故障时,自动将请求转换到备用机器,此时我们的Keepalived就登场了


下图是我们使用keepalived高可用的服务示意图


![](https://mll-typora.oss-cn-beijing.aliyuncs.com/202401011724152.png)


利用keepalived生成一个虚拟IP,客户端发送请求到虚拟IP,然后keepalived会将虚拟IP映射到主机器,如果主机器正常，就会正确的响应服务。当主机器发生故障时,keepalived会将虚拟IP自动切换到备用机器，由备用机器响应服务，此过程由keepalived自动切换，当主机器恢复后，keepalived会再次将虚拟IP切换到主机器


### 搭建Keepalived

我们首先搭建Keepalived,实现虚拟IP的自动切换

准备两台机器

|IP地址|主/备|
|:---:|:---:|
|192.168.8.53|主节点|
|192.168.8.146|备节点|

在两台机器上分别安装Keepalived

```shell
yum -y install keepalived
```

在主节点上添加keepalived配置

```shell
cat  <<EOF > /etc/keepalived/keepalived.conf
global_defs {
      router_id keepalive-master
}
vrrp_instance VI-Nginx-master {
      state MASTER
      interface ens33
      virtual_router_id 68
      priority 100
      dont_track_primary
      advert_int 1
      virtual_ipaddress {
        192.168.8.88
      }
}
EOF
```

在备节点上添加keepalived配置

```shell
cat <<EOF > /etc/keepalived/keepalived.conf
global_defs {
    router_id keepalive-backup
}
vrrp_instance VI-Nginx-master {
    state BACKUP
    interface ens33
    virtual_router_id 68
    priority 99
    dont_track_primary
    advert_int 1
    virtual_ipaddress {
      192.168.8.88
    }
}
EOF
```

配置项说明

- router_id 指定唯一路由id
- state 节点状态
- interface 指定网卡名称,使用 ifconfig 查看
- virtual_router_id 虚拟路由id
- priority 权重
- dont_track_primary 忽略VRRP接口故障
- advert_int 节点之间心跳间隔 1S
- virtual_ipaddress 指定生成的虚拟IP地址

在主节点和备节点上先后分别启动keepalived服务

```shell
systemctl enable keepalived
systemctl start keepalived
```

查看服务启动状态


```shell
systemctl status keepalived
```

![](https://mll-typora.oss-cn-beijing.aliyuncs.com/202401011724458.png)


如上图所示，keepalived已经成功启动，我们可以在主机器上查看当前的虚拟IP是否增加成功



```shell
# 查看当前的虚拟IP状态
ip a
```

![](https://mll-typora.oss-cn-beijing.aliyuncs.com/202401011724104.png)


我们配置的虚拟IP 192.168.8.88 已经成功映射到我们的主机器



我们在主机器手动关闭keepalived服务



```shell
systemctl stop keepalived
```


然后再次查看主机器和备用机器的虚拟IP绑定状态，会发现此时虚拟IP已经自动切换到备用机器



然后启动主机器的keepalived服务，虚拟IP会再次切换到主机器



至此,keepalived的自动切换服务我们已经完成



### 安装Nginx服务



我们在两台机器上分别安装nginx服务，然后将nginx服务和keepalived关联起来，首先先安装nginx服务



安装工具包


```shell
sudo yum install yum-utils
```


添加yum仓库


```shell
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


安装nginx


```shell
sudo yum -y install nginx
```


启动nginx


```shell
systemctl enable nginx
systemctl start nginx
```


nginx服务已经安装完成，我们可以打开浏览器直接输入虚拟IP来访问nginx主页。



如果本机器可以正常访问，外部无法访问，可以检测一下防火墙状态，如果开启了，可以暂时关闭防火墙，或者将80端口加入允许



如果此时我们关闭主机器的Nginx服务，访问就直接没有响应了，因为此时Nginx还没有和keepalived做联动，我们只是通过虚拟IP直接访问了服务



### 检测keepalived切换状态



为了区分两台机器的服务，我们修改一下nginx主页，来区分不同机器


```shell
# 主节点执行
sed -i 's/Welcome to nginx!/主节点/g' /usr/share/nginx/html/index.html
# 备节点执行
sed -i 's/Welcome to nginx!/备节点/g' /usr/share/nginx/html/index.html
```


此时我们访问keepalived设置的虚拟IP地址，可以直接访问主机器的服务


![](https://mll-typora.oss-cn-beijing.aliyuncs.com/202401011724512.png)


我们手动关闭主节点的keepalived服务，让虚拟IP切换到备用机器，然后再次访问一下



首先关闭主机器的keepalived服务


```shell
systemctl stop keepalived
```

再次访问虚拟ip


![](https://mll-typora.oss-cn-beijing.aliyuncs.com/202401011724326.png)


可以看到，此时虚拟IP已经成功切换到备用机器。

我们的高可用集群基本已经搭建，只差将keepalived服务状态和nginx服务状态绑定就可以完成跟随nginx服务状态来自动切换虚拟IP

### Nginx利用Keepalived搭建高可用集群



上例中，我们手动关闭keepalived服务实现了虚拟ip的自动切换，但在实际运用中，我们不可能手动去控制服务状态，服务一般都是突发问题导致的。我们可以编写一个脚本，让Keepalived去检测nginx服务的状态


#### Nginx自动检测脚本 

这个脚本会查看nginx是否启动，如果没启动则启动，如果启动不起来，停掉keepalived服务，此时心跳断掉，虚拟IP自动切换

```shell
#!/bin/bash
counter=\$(ps -C nginx --no-heading|wc -l)
if [ "\${counter}" = "0" ]; then
    /usr/sbin/nginx
    sleep 2
    counter=\$(ps -C nginx --no-heading|wc -l)
    if [ "\${counter}" = "0" ]; then
        systemctl stop keepalived
    fi
fi
EOF
```

重新配置主机器的keepalived配置文件

```shell
cat << EOF > /etc/keepalived/keepalived.conf
global_defs {
      router_id keepalive-master
}
vrrp_script nginx_check {
      script "/etc/keepalived/nginx_check.sh"
      interval 1
}
vrrp_instance VI-Nginx-master {
      state MASTER
      interface ens33
      virtual_router_id 68
      priority 100
      dont_track_primary
      advert_int 1
      virtual_ipaddress {
        192.168.8.88
      }
      track_script {
        nginx_check
     }
}
EOF
```


重新配置备用机器的keepalived配置文件

```shell
cat << EOF > /etc/keepalived/keepalived.conf
global_defs {
     router_id keepalive-backup
}
vrrp_script nginx_check {
     script "/etc/keepalived/nginx_check.sh"
     interval 1
}
vrrp_instance VI-Nginx-master {
     state BACKUP
     interface ens33
     virtual_router_id 68
     priority 99
     dont_track_primary
     advert_int 1
     virtual_ipaddress {
       192.168.8.88
     }
     track_script {
        nginx_check
    }
}
EOF
```

重启两台机器上的keepalived服务


```shell
systemctl restart keepalived
```

此时我们的使用Keepalived搭建Nginx高可用集群已经完成

我们可以关闭nginx服务来进行测试，验证一下



参考资料:

- [keepalived官网](https://www.keepalived.org/)
- [nginx官网](https://nginx.org/)