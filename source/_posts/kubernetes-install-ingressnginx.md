---
title: Kubernetes安装IngressNginx
tags: 
  - Kubernetes
  - IngressNginx
categories: 
  - Kubernetes
---

## 安装

```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v0.44.0/deploy/static/provider/baremetal/deploy.yaml
```

部署完，我们查看一下状态

![](https://image.mllweb.com/wp-content/uploads/2021/03/1616755596-image.png)

对应的service和deployment已经创建完毕，并且service以NodePort方式对外开放了32756端口

## 部署tomcat进行测试

我准备了yaml文件，部署一个tomcat，并指定host信息


```
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: tomcat
spec:
  replicas: 3
  selector:
    matchLabels:
      app: tomcat
  template:
    metadata:
      name: tomcat
      labels:
        app: tomcat
    spec:
      containers:
        - name: nginx
          image: tomcat:6.0
          ports:
             - containerPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: tomcat
spec:
  selector:
    app: tomcat
  ports:
    - name: tomcat
      protocol: TCP
      port: 8080
      targetPort: 8080
---
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  name: ingress-tomcat
spec:
  rules:
    - host: tomcat.custom.com
      http:
        paths: 
          - path: /
            backend:
              serviceName: tomcat
              servicePort: 8080
```

部署到集群

```
kubectl apply -f tomcat.yaml
```

等部署完毕后，我们访问一下http://tomcat.custom.com:32756/，tomcat.custom.com随意映射集群任何一个节点就可以

![](https://image.mllweb.com/wp-content/uploads/2021/03/1616757837-image.png)

说明ingressNginx已经成功代理了我们的域名服务

但是还有一个我们访问的端口是ingressnginx生成的NodePort接口，我们更希望直接代理到80端口上，这种情况怎么处理呢

[官方](https://kubernetes.github.io/ingress-nginx/deploy/baremetal/)给出了几种解决方法，我们来看一下

## 注意事项

### 通过NodePort服务

**NodePort**通过**kube-proxy**组件在每个主机节点上公开<strong>相同的非特权</strong>端口（默认值：30000-32767）。

可以使用**--service-node-port-range**API服务器标志重新配置NodePort范围以包括非特权端口并能够公开端口80和443听起来很诱人，但这样做可能会导致意外问题，包括（但不限于）使用否则保留给其他用户使用的端口系统守护程序，以及授予**kube-proxy**它可能不需要的特权。

这种方式可以指定监听80端口，但是<strong>不鼓励</strong>这种做法。

![](https://image.mllweb.com/wp-content/uploads/2021/03/1616758664-40c23cd97a05b731ee2f84a3ae601646.jpeg)

### 主机网络

可以将Pod配置**ingress-nginx**为使用其运行的主机的网络，而不是kubenetes内部网络。这种方法的好处是，NGINX Ingress控制器可以将端口80和443直接绑定到Kubernetes节点的网络接口，而无需由NodePort Services施加额外的网络转换。

这可以通过启用**hostNetwork**Pods规范中的选项来实现。

```
template:   
  spec:     
    hostNetwork: true
```

此部署方法的一个主要限制是，在每个群集节点上只能调度<strong>单个NGINX Ingress控制器Pod</strong>，因为从技术上讲，在同一网络接口上多次绑定同一端口是不可能的。由于这种情况只能每个节点启动唯一的pod

![](https://image.mllweb.com/wp-content/uploads/2021/03/1616989777-ea6ae9a1cfe64bb59c4146b2960b5229.jpeg)

### 扩展组件(推荐)

此部署方法需要第三方扩展组件为Kubernetes集群提供公共入口点。该组件可以是硬件（例如供应商设备）或软件（例如**HAproxy**），并且通常由运营团队在Kubernetes领域之外进行管理。


这种部署建立在上面“基于NodePort服务”中描述的NodePort服务的基础上，有一个显着的区别：外部客户端不直接访问群集节点，只有边缘组件可以访问。这特别适用于没有任何节点具有公共IP地址的私有Kubernetes集群。


在组件方面，唯一的要求是专用于将所有HTTP请求转发到Kubernetes节点和/或主节点的公共IP地址。TCP端口80和443上的传入流量被转发到目标节点上的相应HTTP和HTTPS NodePort，如下图所示：

![](https://image.mllweb.com/wp-content/uploads/2021/03/1616989778-954a07cead8aa4a4610eb1727ccdd279.jpeg)