---
title: haproxy.cfg示例
tags: 
  - Linux
  - haproxy
categories: 
  - Linux
---
```
# 全局参数的设置
global
     log 127.0.0.1 local0 info # 全局的日志配置，local0 是日志设备，info 表示日志级别。其中日志级别有err、warning、info、debug 四种可选。这个配置表示使用 127.0.0.1 上的 rsyslog 服务中的local0 日志设备，记录日志等级为info。
     maxconn 4096 # 设定每个 haproxy 进程可接受的最大并发连接数，此选项等同于 Linux命令行选项“ulimit -n”。
     user nobody # 设置运行 haproxy 进程的用户，也可使用用户的 uid 值来替代。
     group nobody # 设置运行 haproxy 进程的用户组，也可使用用户组的 gid 值来替代。
     daemon # 设置 HAProxy 进程进入后台运行。这是推荐的运行模式。
     nbproc 1 # 设置 HAProxy 启动时可创建的进程数，此参数要求将HAProxy 运行模式设置为“daemon”，默认只启动一个进程。根据使用经验，该值的设置应该小于服务器的 CPU 核数。创建多个进程，能够减少每个进程的任务队列，但是过多的进程可能会导致进程的崩溃。
     pidfile /usr/local/haproxy/logs/haproxy.pid # 指定 HAProxy 进程的 pid 文件。启动进程的用户必须有访问此文件的权限。
defaults
     # 设置 HAProxy 实例默认的运行模式，有 tcp、http、health 三个可选值。
     # tcp 模式    在此模式下，客户端和服务器端之间将建立一个全双工的连接，不会对七层报文做任何类型的检查，默认为 tcp 模式，经常用于 SSL、SSH、SMTP 等应用。
    # http 模式    在此模式下，客户端请求在转发至后端服务器之前将会被深度分析，所有不与 RFC 格式兼容的请求都会被拒绝。
    # health 模式    目前此模式基本已经废弃，不在多说。
     mode http 
     # log global # 应用全局的日志配置
     # option httplog # 启用日志记录HTTP请求，默认haproxy日志记录是不记录HTTP请求日志
     # 启用该项，日志中将不会记录空连接。所谓空连接就是在上游的负载均衡器 或者监控系统为了探测该  服务是否存活可用时，需要定期的连接或者获取某 一固定的组件或页面，或者探测扫描端口是否在监 听或开放等动作被称为空连接； 官方文档中标注，如果该服务上游没有其他的负载均衡器的话，建议 不要使用 该参数，因为互联网上的恶意扫描或其他动作就不会被记录下来
     # option dontlognull 
     # option http-server-close # 每次请求完毕后主动关闭http通道
     # 如果服务器上的应用程序想记录发起请求的客户端的IP地址， 需要在HAProxy上配置此选项，这样  HAProxy会把客户端的IP信息发送给服务器，在HTTP请求中添加"X-Forwarded-For"字 段。  启用  X-Forwarded-For，在requests头部插入客户端IP发送给后端的server，使后端server获 取到客户端的真实IP。
     # option forwardfor except 127.0.0.0/8
     # 当使用了cookie时，haproxy将会将其请求的后端服务器的serverID插入到cookie中，以保证 会话的SESSION持久性；而此时，如果后端的服务器宕掉了， 但是客户端的cookie是不会刷新 的，如果设置此参数，将会将客户的请求强制定向到另外一个后端server上，以保证服务的正常。
     # option redispatch 
     retries 3 # 设置连接后端服务器的失败重试次数，连接失败的次数如果超过这里设置的值，HAProxy 会将对应的后端服务器标记为不可用。此参数也可在后面部分进行设置。
     # timeout http-request 10s # http请求超时时间
     # timeout queue 1m # 一个请求在队列里的超时时间
     # timeout http-keep-alive 10s # 设置http-keep-alive的超时时间
     timeout connect 10s # 设置成功连接到一台服务器的最长等待时间，默认单位是毫秒，但也可以使用其他的时间单位后缀。
     timeout client 20s # 设置连接客户端发送数据时最长等待时间，默认单位是毫秒，也可以使用其他的时间单位后缀。
     timeout server 30s # 设置服务器端回应客户度数据发送的最长等待时间，默认单位是毫秒，也可以使用其他的时间单位后缀。
     timeout check 5s # 设置对后端服务器的检测超时时间，默认单位是毫秒，也可以使用其他的时间单位后缀。
     # maxconn 3000 # 每个进程可用的最大连接数
frontend www
     bind *:80  # 此选项只能在 frontend 和 listen 部分进行定义，用于定义一个或几个监听的套接字。bind 的使用格式为:bind [&lt;address>:&lt;port_range>] interface &lt;interface> 其中，address 为可选选项，其可以为主机名或IP 地址，如果将其设置为“*”或“0.0.0.0”，将监听当前系统的所有 IPv4 地址。port_range 可以是一个特定的 TCP 端口，也可是一个端口范围，小于 1024 的端口需要有特定权限的用户才能使用。interface 为可选选项，用来指定网络接口的名称，只能在 Linux 系统上使用。 
     mode    http
     option    httplog 
     option    forwardfor # 如果后端服务器需要获得客户端的真实  IP，就需要配置此参数。由于 HAProxy 工作于反向代理模式，因此发往后端真实服务器的请求中的客户端 IP 均为 HAProxy 主机的 IP，而非真正访问客户端的地址，这就导致真实服务器端无法记录客户端真正请求来源的 IP，而“X-Forwarded-For”则可用于解决此问题。通过使用“forwardfor”选项，HAProxy 就可以向每个发往后端真实服务器的请求添加“X-Forwarded-For”记录，这样后端真实服务器日志可以通过“X-Forwarded-For”信息来记录客户端来源 IP。
     option    httpclose # 此选项表示在客户端和服务器端完成一次连接请求后，HAProxy 将主动关闭此 TCP 连接。这是对性能非常有帮助的一个参数。
     log    global # 表示使用全局的日志配置，这里的“ global”表示引用在HAProxy 配置文件 global 部分中定义的 log 选项配置格式。
     #acl host_www    hdr_dom(host)   -i  www.zb.com
     #acl host_img    hdr_dom(host)   -i  img.zb.com
     #use_backend htmpool    if  host_www 
     #use_backend imgpool    if  host_img 
     default_backend    htmpool # 指定默认的后端服务器池，也就是指定一组后端真实服务器，而这些真实服务器组将在 backend 段进行定义。这里的htmpool 就是一个后端服务器组。
# 定义一个名为 my_webserver后端部分。PS：此处 my_webserver只是一个自定义名字而已， 但是需要与frontend里面 配置项default_backend 值相一致
backend htmpool
     mode http 
     # 此参数用于 cookie 保持的环境中。在默认情况下，HAProxy会将其请求的后端服务器的serverID 插入到 cookie 中，以保证会话的 SESSION 持久性。而如果后端的服务器出现故障，客户端的 cookie 是不会刷新的，这就出现了问题。此时，如果设置此参数，就会将客户的请求强制定向到另外一个健康的后端服务器上，以保证服务的正常。
     option    redispatch 
     option    abortonclose  # 如果设置了此参数，可以在服务器负载很高的情况下， 自动结束掉当前队列中处理时间比较长的链接。
     # 此关键字用来定义负载均衡算法。目前 HAProxy 支持多种负载均衡算法，常用的有如下几种
     # roundrobin    是基于权重进行轮询调度的算法，在服务器的性能分布比较均匀的时候，这是一种最公平、最合理的算法。此算法经常使用。
     # static-rr    也是基于权重进行轮询的调度算法，不过此算法为静态方法，在运行时调整其服务器权重不会生效。
     # source    是基于请求源 IP 的算法。此算法先对请求的源 IP 进行 hash 运算， 然后将结果与后端服务器的权重总数相除后转发至某个匹配的后端服务器。这种方式可以使同一个客户端 IP 的请求始终被转发到某特定的后端服务器。
     # leastconn    此算法会将新的连接请求转发到具有最少连接数目的后端服务器。在会话时间较长的场景中推荐使用此算法，例如数据库负载均衡等。此算法不  适合会话较短的环境中，例如基于 HTTP 的应用。
     # uri    此算法会对部分或整个 URI 进行 hash 运算，再经过与服务器的总权重相除，最后转发到某台匹配的后端服务器上。
     # uri_param    此算法会根据 URL 路径中的参数进行转发，这样可保证在后端真实服务器数量不变时，同一个用户的请求始终分发到同一台机器上。
     # hdr():    此算法根据 http 头进行转发，如果指定的 http 头名称不存在，则使用 roundrobin 算法进行策略转发。
     balance  static-rr 
     cookie    SERVERID # 表示允许向 cookie 插入 SERVERID，每台服务器的 SERVERID 可在下面的 server 关键字中使用 cookie 关键字定义。
     # 此选项表示启用 HTTP 的服务状态检测功能。HAProxy 作为一款专业的负载均衡器，它支持对 backend 部分指定的后端服务节点的健康检查，以保证在后端 backend 中某个节点不能服务时，把从 frotend 端进来的客户端请求分配至 backend 中其他健康节点上，从而保证整体服务的可用性。“option httpchk”的用法如下：
     # option httpchk &lt;method> &lt;uri> &lt;version> 其中，各个参数的含义如下：
     # &lt;method>    表示 HTTP 请求的方式，常用的有 OPTIONS、GET、HEAD 几种方式。一般的健康检查可以采用 HEAD 方式进行，而不是才采用 GET 方式，这是因为 HEAD 方式没有数据返回，仅检查 Response 的 HEAD 是不是 200 状态。因此相对与 GET 来说，HEAD 方式更快，更简单。
     # &lt;uri>    表示要检测的 URL 地址，通过执行此 URL，可以获取后端服务器的运行状态。在正常情况下将返回状态码 200，返回其他状态码均为异常状态。
     # &lt;version>    指定心跳检测时的 HTTP 的版本号。
     option    httpchk GET /index.jsp
     # 这个关键字用来定义多个后端真实服务器，不能用于 defaults 和frontend部分。使用格式为：server &lt;name> &lt;address>[:port] [param*] 其中，每个参数含义如下：
     # &lt;name> 为后端真实服务器指定一个内部名称，随便定义一个即可。
     # &lt;address> 后端真实服务器的 IP 地址或主机名。
     # &lt;port> 指定连接请求发往真实服务器时的目标端口。在未设定时，将使用客户端请求时的同一端口。
     # [param*] 为后端服务器设定的一系参数，可用参数非常多，这里仅介绍常用的一些参数：
     # check 表示启用对此后端服务器执行健康状态检查。
     # inter 设置健康状态检查的时间间隔，单位为毫秒。
     # rise 设置从故障状态转换至正常状态需要成功检查的次数，例如。“rise 2”表示 2 次检查正确就认为此服务器可用。
     # fall 设置后端服务器从正常状态转换为不可用状态需要检查的次数，例如，“fall 3”表示 3 次检查失败就认为此服务器不可用。
     # cookie 为指定的后端服务器设定 cookie 值，此处指定的值将在请求入站时被检查，第一次为此值挑选的后端服务器将在后续的请求中一直被选中，其目的在于实现持久连接的功能。上面 的“cookie server1”表示 web1 的 serverid 为 server1。同理， “cookie server2”表示 web2 的 serverid 为 server2。
     # weight 设置后端真实服务器的权重，默认为 1，最大值为 256。设置为 0 表示不参与负载均衡。
     # backup 设置后端真实服务器的备份服务器，仅仅在后端所有真实服务器均不可用的情况下才启用。 
     server    237server 192.168.81.237:8080 cookie server1 weight 6 check inter 2000 rise 2 fall 3
     server    iivey234 192.168.81.234:8080 cookie server2 weight 3 check inter 2000 rise 2 fall 3
backend imgpool
     mode        http 
     option    redispatch
     option    abortonclose
      balance  static-rr 
     cookie  SERVERID
     option    httpchk GET /index.jsp
     server    host236 192.168.81.236:8080 cookie server1 weight 6 check inter 2000 rise 2 fall 3
# 这个部分通过listen 关键字定义了一个名为“admin_stats”的实例，其实就是定义了一个 HAProxy 的监控页面
listen admin_stats
     bind 0.0.0.0:9188 # 页面绑定访问端口
     mode http # 实例默认的运行模式
     log 127.0.0.1 local0 err # 记录日志，原理同global
     stats refresh 30s # 设置 HAProxy 监控统计页面自动刷新的时间。
     stats uri /haproxy-status # 设置 HAProxy 监控统计页面的URL 路径，可随意指定。例如、指定“stats uri /haproxy-status”，就可以过 http://IP:9188/haproxy-status  查看。
     stats realm welcome login\ Haproxy # 设置登录 HAProxy 统计页面时密码框上的文本提示信息。
     stats auth admin:admin # 设置登录 HAProxy 统计页面的用户名和密码。用户名和密码通过冒号分割。可为监控页面设置多个用户名和密码，每行一个。
     stats hide-version # 用来隐藏统计页面上 HAProxy 的版本信息。
     stats admin if TRUE # 通过设置此选项，可以在监控页面上手工启用或禁用后端真实服务器，仅在 haproxy1.4.9 以后版本有效。
```