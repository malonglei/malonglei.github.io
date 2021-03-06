---
title: .gitlab-ci.yml示例
tags: 
  - Linux
  - GitLab
categories: 
  - Linux
---
```
#定义 stages（阶段）。任务将按此顺序执行。
stages: 
     - build 
     - test 
     - deploy 

#定义 job（任务）
job1: 
     stage: test 
     tags: 
         - XX    #只有标签为XX的runner才会执行这个任务 
     only: 
         - dev   #只有dev分支提交代码才会执行这个任务。也可以是分支名称或触发器名称 
         - /^future-.*$/     #正则表达式，只有future-开头的分支才会执行 
     script: 
         - echo "I am job1" 
         - echo "I am in test stage" 

#定义 job
job2: 
     stage: test     #如果此处没有定义stage，其默认也是test 
     only: 
         - master    #只有master分支提交代码才会执行这个任务 
     script: 
         - echo "I am job2" 
         - echo "I am in test stage" 
     allow_failure: true     #允许失败，即不影响下步构建 

#定义 job
job3: 
     stage: build 
     except: 
         - dev   #除了dev分支，其它分支提交代码都会执行这个任务 
     script: 
         - echo "I am job3" 
         - echo "I am in build stage" 
     when: always    #不管前面几步成功与否，永远会执行这一步。它有几个值：on_success （默认值）\on_failure\always\manual（手动执行） 

#定义 job
.job4:      #对于临时不想执行的job，可以选择在前面加个"."，这样就会跳过此步任务，否则你除了要注释掉这个jobj外，还需要注释上面为deploy的stage 
     stage: deploy 
     script: 
         - echo "I am job4" 

#模板，相当于公用函数，有重复任务时很有用
.job_template: &job_definition      # 创建一个锚，'job_definition' 
     image: ruby:2.1 
     services: 
         - postgres 
         - redis 

test1: 
     <<: *job_definition             # 利用锚'job_definition'来合并 
     script: 
         - test1 project 

test2: 
     <<: *job_definition             # 利用锚'job_definition'来合并 
     script: 
         - test2 project 

#下面几个都相当于全局变量，都可以添加到具体job中，这时会被子job的覆盖
before_script: 
     - echo "每个job之前都会执行" 
 
after_script: 
     - echo "每个job之后都会执行" 
 
variables:      #变量 
     DATABASE_URL: "postgres://postgres@postgres/my_database"    #在job中可以用${DATABASE_URL}来使用这个变量。常用的预定义变量有CI_COMMIT_REF_NAME（项目所在的分支或标签名称），CI_JOB_NAME（任务名称），CI_JOB_STAGE（任务阶段） 
     GIT_STRATEGY: "none"    #GIT策略，定义拉取代码的方式，有3种：clone/fetch/none，默认为clone，速度最慢，每步job都会重新clone一次代码。我们一般将它设置为none，在具体任务里设置为fetch就可以满足需求，毕竟不是每步都需要新代码，那也不符合我们测试的流程 
 
cache:          #缓存 
     #因为缓存为不同管道和任务间共享，可能会覆盖，所以有时需要设置key 
     key: ${CI_COMMIT_REF_NAME}                      # 启用每分支缓存。 
     #key: "$CI_JOB_NAME/$CI_COMMIT_REF_NAME"        # 启用每个任务和每个分支缓存。需要注意的是，如果是在windows中运行这个脚本，需要把$换成% 
     untracked: true                                 #缓存所有Git未跟踪的文件 
     paths:                                          #以下2个文件夹会被缓存起来，下次构建会解压出来 
         - node_modules/ 
         - dist/
```