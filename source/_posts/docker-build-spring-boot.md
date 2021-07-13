---
title: 使用Docker部署Spring Boot
tags: 
  - Java
  - Docker
  - Spring Boot
categories: 
  - Java
---
随着云原生的普及以及成熟，越来越多的项目开始用容器装载。

Docker已经是容器的准则了，我们学习如何将Spring Boot项目装载在Docker容器内，然后启动部署。

### 创建Spring Boot项目

1. 导航到[https://start.spring.io](https://start.spring.io)。该网站可以选择依赖关系，并自动为我们完成项目设置。
2. 选择**Gradle**或**Maven**以及要使用的语言。
3. 单击**Dependencies**，然后选择**Spring Web依赖**。
4. 点击**生成**。
5. 下载生成的ZIP文件，然后用IDEA打开项目

### 设置Spring Web项目

现在我们简单来创建一个API接口

编辑src/main/java/hello/Application.java文件


```
package hello;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@SpringBootApplication
@RestController
public class Application {

  @RequestMapping("/")
  public String home() {
     return "Hello World";
  }

  public static void main(String[] args) {
     SpringApplication.run(Application.class, args);
  }
}
```

项目已经准备完成，我们可以直接运行

如果使用gradle，执行下面命令

```
gradle build && java -jar build/libs/spring-boot-docker-0.0.1.jar
```

如果使用maven，执行下面命令

```
mvn package && java -jar target/spring-boot-docker-0.0.1.jar
```

现在我们可以打开[http://127.0.0.1:8080](http://127.0.0.1:8080)查看

### 容器化

Docker提供了简单的Dockerfile文件来构建镜像，首先在项目跟路径创建Dockerfile文件

```
# 指定基础镜像
FROM java:8
# 构建参数，默认是target/*.jar，如果指定则覆盖
ARG JAR_FILE=target/*.jar
# 将jar包添加进镜像中
COPY ${JAR_FILE} app.jar
# 镜像入口，部署镜像时将被执行
ENTRYPOINT ["java","-jar","/app.jar"]
```

如果使用gradle，执行下面命令

```
docker build --build-arg JAR_FILE=build/libs/\*.jar -t spring-boot-docker:0.0.1 .
```

如果使用maven，执行下面命令

```
docker build -t spring-boot-docker:0.0.1 .
```

这个命令会构建Docker镜像，镜像名称为spring-boot-docker，镜像版本为0.0.1

### 部署容器

我们的Spring Boot项目已经构建成Docker镜像

执行下面命令启动Docker镜像

```
docker run -p 8080:8080 spring-boot-docker:0.0.1
```

现在我们可以打开[http://127.0.0.1:8080](http://127.0.0.1:8080/)查看

