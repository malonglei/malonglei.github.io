---
title: kubeadm搭建Kubernetes集群
tags: 
  - Kubernetes
  - kubeadm
categories: 
  - Kubernetes
---

官方文档



[https://kubernetes.io/zh/docs/setup/production-environment/tools/kubeadm/install-kubeadm/](https://kubernetes.io/zh/docs/setup/production-environment/tools/kubeadm/install-kubeadm/)



[https://kubernetes.io/zh/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/](https://kubernetes.io/zh/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/)



## 准备条件



- 一台或多台运行着下列系统的机器：
  - Ubuntu 16.04+
  - Debian 9+
  - CentOS 7+
  - Red Hat Enterprise Linux (RHEL) 7+
  - Fedora 25+
  - HypriotOS v1.0.1+
  - Flatcar Container Linux （使用 2512.3.0 版本测试通过
- 2GB内存或以上
- 2核CPU或以上
- 集群中所有机器的网络能相互连接
- 可以访问外网，需要下载镜像
- 节点之中不可以有重复的hostname
- 开启机器上的某些端口。具体端口可[看这里](https://kubernetes.io/zh/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#check-required-ports)（用于测试可以关闭防火墙）
- 禁用交换分区。



## 准备环境



准备两台虚拟机



|hostname|IP|
|---|---|
|ks-m|172.16.193.11|
|ks-n|172.16.193.12|



```
# 修改主机名
hostnamectl set-hostname <your-hostname>

# 关闭防火墙：
systemctl stop firewalld
systemctl disable firewalld

# 关闭selinux：
setenforce 0
sed -i 's/enforcing/disabled/'/etc/selinux/config
# 或者将 SELinux 设置为 permissive 模式（相当于将其禁用）
sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

# 关闭swap：
swapoff -a
sed -i '/swap/s/^\(.*\)$/#\1/g' /etc/fstab

# 允许iptables桥接流量
cat << EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF
cat << EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sudo sysctl --system
```



## 安装



### 安装docker



安装过程请参考[CentOS安装Docker](https://www.mllweb.com/archives/93)



### 安装kubeadm、kubelet、kubectl



- `kubeadm`：用来初始化集群的指令。
- `kubelet`：在集群中的每个节点上用来启动 Pod 和容器等。 
- `kubectl`：用来与集群通信的命令行工具。



```
# 添加官方仓库如果网络允许，如果网络无法连接可选择阿里云镜像
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-\$basearch
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kubelet kubeadm kubectl
EOF
# 添加阿里云YUM源
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=0
repo_gpgcheck=0
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF
# 安装kubelet kubeadm kubectl
yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
# 启动kubelet
systemctl enable --now kubelet
```



## 部署集群



kubeadm初始化集群时可以指定参数，详细的参数请参见 [kubeadm 参考指南](https://kubernetes.io/zh/docs/reference/setup-tools/kubeadm/)。



```
# 部署集群这里指定阿里云镜像
kubeadm init --image-repository=registry.aliyuncs.com/google_containers
```



`kubeadm init` 首先运行一系列预检查以确保机器准备运行 Kubernetes。这些预检查会显示警告并在错误时退出。然后 `kubeadm init` 下载并安装集群组件。这可能会需要几分钟。 完成之后你应该看到：



```
Your Kubernetes control-plane has initialized successfully!
 
To start using your cluster, you need to run the following as a regular user:
 
   mkdir -p $HOME/.kube
   sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
   sudo chown $(id -u):$(id -g) $HOME/.kube/config
 
Alternatively, if you are the root user, you can run:
 
   export KUBECONFIG=/etc/kubernetes/admin.conf
 
You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
   https://kubernetes.io/docs/concepts/cluster-administration/addons/
 
Then you can join any number of worker nodes by running the following on each as root:
 
kubeadm join 172.16.193.11:6443 --token hwlhrb.vpz1gwp2l1zbh29c \
     --discovery-token-ca-cert-hash sha256:7b99fbbe7d5f3a07dc3db32ce89f6ec8089771a3bc09a1fc9c884e769f7ebf7c
```



要使非 root 用户可以运行 kubectl，请运行以下命令， 它们也是 `kubeadm init` 输出的一部分：




```
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```



或者，如果你是 `root` 用户，则可以运行：



```
export KUBECONFIG=/etc/kubernetes/admin.conf
```



记录 `kubeadm init` 输出的 `kubeadm join` 命令。 你需要此命令[将节点加入集群](https://kubernetes.io/zh/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/#join-nodes)。



token用于master节点和worker节点之间的相互身份验证。 这里包含的token是密钥。请安全保存， 因为拥有此token的任何人都可以将经过身份验证的节点添加到你的集群中。 可以使用 `kubeadm token` 命令列出，创建和删除这些令牌。 



## 部署CNI网络



你必须部署一个基于 Pod 网络插件的容器网络接口 (CNI)，以便你的 Pod 可以相互通信。 在安装网络之前，集群 DNS (CoreDNS) 将不会启动。



```
# 查看CoreDNS状态
kubectl get pods --all-namespaces
# STATUS=Pending代表未启动
NAMESPACE     NAME                           READY   STATUS    RESTARTS   AGE
kube-system   coredns-74ff55c5b-dlxg9        0/1     Pending   0          6m38s
kube-system   coredns-74ff55c5b-n2xbk        0/1     Pending   0          6m38s
```



- 注意你的 Pod IP不得与任何主机IP相同
- 默认情况下，`kubeadm` 将集群设置为使用和强制使用 RBAC（基于角色的访问控制）。 确保你的 Pod 网络插件支持 RBAC，以及用于部署它的 manifests 也是如此。
- 如果要为集群使用 IPv6（双协议栈或仅单协议栈 IPv6 网络）， 请确保你的Pod网络插件支持 IPv6。 IPv6 支持已在 CNI v0.6.0 版本中添加。



目前 Calico 是 kubeadm 项目中执行 e2e 测试的唯一 CNI 插件，你可以选择其他插件，详情见[Kubernetes 网络模型](https://kubernetes.io/zh/docs/concepts/cluster-administration/networking/#how-to-implement-the-kubernetes-networking-model)



```
#【flannel 、calico部署一个就可以】
# calico 网络插件
wget https://docs.projectcalico.org/v3.11/manifests/calico.yaml
kubectl apply -f calico.yaml

# flannel 网络插件
wget https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
kubectl apply -f kube-flannel.yml
```



每个集群只能安装一个 Pod 网络。



此过程可能持续几分钟，稍等片刻，再次通过 `kubectl get pods --all-namespaces` 查看CoreDNS状态



```
kubectl get pods --all-namespaces
# 此时STATUS=Running代表正在运行
NAMESPACE     NAME                                       READY   STATUS    RESTARTS   AGE
kube-system   calico-kube-controllers-6b8f6f78dc-h5q7z   1/1     Running   0          95s
kube-system   calico-node-wvjmx                          1/1     Running   0          95s
kube-system   coredns-74ff55c5b-dlxg9                    1/1     Running   0          10m
kube-system   coredns-74ff55c5b-n2xbk                    1/1     Running   0          10m
```



安装 Pod 网络后， 确保 CoreDNS Pod 启用并运行，就可以继续加入其他节点。



## 加入Node节点服务器



这是 `kubeadm init` 输出的 `kubeadm join` 命令，根据输出日志在Node节点执行命令，加入集群


```
# 模版
# kubeadm join <control-plane-host>:<control-plane-port> --token <token> \
#     --discovery-token-ca-cert-hash sha256:<hash>
kubeadm join 172.16.193.11:6443 --token hwlhrb.vpz1gwp2l1zbh29c \
     --discovery-token-ca-cert-hash sha256:7b99fbbe7d5f3a07dc3db32ce89f6ec8089771a3bc09a1fc9c884e769f7ebf7c
```



稍等片刻后，查看节点信息



```
kubectl get node
# 可以看到worker节点已经成功加入到集群中
NAME   STATUS   ROLES                  AGE   VERSION
ks-m   Ready    control-plane,master   18m   v1.20.5
ks-n   Ready    <none>                 62s   v1.20.5
```



如果没有令牌，可以通过在控制平面节点上运行以下命令来获取令牌：



```
kubeadm token list
```



输出类似于以下内容：




```
TOKEN                     TTL         EXPIRES                     USAGES                   DESCRIPTION                                                EXTRA GROUPS
hwlhrb.vpz1gwp2l1zbh29c   23h         2021-03-25T13:48:33+08:00   authentication,signing   The default bootstrap token generated by 'kubeadm init'.   system:bootstrappers:kubeadm:default-node-token
```



默认情况下，令牌会在24小时后过期。如果要在当前令牌过期后将节点加入集群， 则可以通过在控制平面节点上运行以下命令来创建新令牌：



```
kubeadm token create
```



输出类似于以下内容：



```
0gaske.aqb6any6xs7cuq3s
```



如果你没有 `--discovery-token-ca-cert-hash` 的值，则可以通过在控制平面节点上执行以下命令链来获取它：



```
openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | \
   openssl dgst -sha256 -hex | sed 's/^.* //' 
```



输出类似于以下内容：



```
7b99fbbe7d5f3a07dc3db32ce89f6ec8089771a3bc09a1fc9c884e769f7ebf7c
```



## 集群测试



一个简单的集群已经搭建完毕，我们测试一下集群的运行



下面我给大家准备了一个 **nginx.yaml** 部署文件



```
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      name: nginx
      labels:
        app: nginx
    spec:
      containers:
        - name: nginx
          image: nginx:1.19
          ports:
            - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: nginx
spec:
  selector:
    app: nginx
  type: NodePort
  ports:
    - name: nginx
      protocol: TCP
      port: 80
      targetPort: 80
      nodePort: 30001
```



将nginx运行到集群中



```
kubectl apply -f nginx.yaml
```



```
# 查看Deployment和Service信息
kubectl get deployment,service
# 当READY 3个副本全部准备完后说明成功
NAME                    READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/nginx   3/3     3            3           36s
# service已经启动并将80端口映射到了30001端口
NAME                 TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)        AGE
service/kubernetes   ClusterIP   10.96.0.1                443/TCP        30m
service/nginx        NodePort    10.110.236.239           80:30001/TCP   4m28s
```



此时我们打开浏览器访问一下服务 http://<ip>:30001

![](https://image.mllweb.com/wp-content/uploads/2021/03/1616566920-image.png)




