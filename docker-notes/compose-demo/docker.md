# Docker学习实战笔记.md（全文可直接复制粘贴覆盖你的docker.md）
```markdown
# Docker 学习实战笔记
## 目录
1. [Docker 基础概念](#一docker-基础概念)
2. [容器基础操作&单机服务部署](#二容器基础操作单机服务部署)
3. [Dockerfile 自定义镜像构建实战](#三dockerfile-自定义镜像构建实战)
4. [Docker Compose 多容器编排部署](#四docker-compose-多容器编排部署)
5. [常见问题与踩坑记录](#五常见问题与踩坑记录)
6. [面试高频考点总结](#六面试高频考点总结)

---

## 一、Docker 基础概念
### 1.1 核心定义
- **Docker**：开源容器化引擎，将应用与依赖打包为轻量化容器，实现环境统一、一次构建随处运行
- **镜像（Image）**：只读模板文件，包含程序代码、运行环境、配置文件，等同于容器安装包
- **容器（Container）**：镜像运行后的可读写进程实例，资源隔离、独立运行，销毁容器默认清空内部数据
- **数据卷挂载**：通过`-v`将宿主机目录挂载至容器，实现数据库等数据持久化保存
- **Docker Compose**：单服务器多容器编排工具，yaml配置文件统一管理多服务启停

### 1.2 整体执行链路
```
Dockerfile → docker build 构建 → 自定义镜像 → docker run 运行 → 容器实例
```

### 1.3 核心优势
1. 环境一致性：解决本地可运行、服务器环境异常问题
2. 资源轻量化：共享宿主机内核，容器秒级启动，内存CPU占用远低于虚拟机
3. 部署标准化：一套配置全环境复用，降低部署运维成本

### 1.4 镜像加速配置（CentOS7）
修改docker daemon配置更换国内镜像源，解决拉取镜像超时问题
```bash
vi /etc/docker/daemon.json
```
写入配置：
```json
{
  "registry-mirrors": ["https://xxx.mirror.aliyuncs.com"]
}
```
重载生效：
```bash
systemctl daemon-reload
systemctl restart docker
```

---

## 二、容器基础操作&单机服务部署
### 2.1 镜像管理常用命令
```bash
# 拉取官方镜像
docker pull nginx
docker pull mariadb:5.5
# 查看本地全部镜像
docker images
# 删除无用镜像
docker rmi 镜像ID/镜像名称:版本
```

### 2.2 容器生命周期核心命令
```bash
# 后台创建并启动容器 端口映射+数据挂载
docker run -d --name 容器名 -p 宿主机端口:容器端口 -v 宿主机目录:容器目录 镜像名
# 查看运行中容器
docker ps
# 查看所有容器（包含已停止）
docker ps -a
# 启停重启容器
docker stop 容器名
docker start 容器名
docker restart 容器名
# 删除容器
docker rm 容器名
# 实时查看容器运行日志
docker logs -f 容器名
# 进入容器内部终端排查问题
docker exec -it 容器名 /bin/bash
```

#### 核心参数说明
| 参数 | 功能说明 |
| ---- | ---- |
| `-d` | 后台守护进程运行容器 |
| `--name` | 自定义容器名称 |
| `-p` | 端口映射：宿主机端口:容器内部端口 |
| `-v` | 目录挂载，实现数据持久化 |
| `-it` | 交互式终端，用于进入容器操作 |

### 2.3 实战1：原生Nginx容器部署
```bash
docker run -d --name nginx-base -p 8080:80 nginx
```
访问地址：`虚拟机IP:8080`，验证默认Nginx页面

### 2.4 实战2：MariaDB持久化数据库部署
```bash
docker run -d --name mysql-base -p 3306:3306 \
-e MYSQL_ROOT_PASSWORD=Admin123! \
-v /data/mysql_data:/var/lib/mysql \
mariadb:5.5
```
- `-e`：设置数据库root初始密码
- `-v`：数据库数据挂载到宿主机`/data/mysql_data`，删除容器数据不丢失

![容器运行状态](./images/docker01_container_run.png)

---

## 三、Dockerfile 自定义镜像构建实战
### 3.1 Dockerfile作用
纯文本构建脚本，通过指令基于基础镜像修改、添加文件、配置启动项，打包生成专属业务镜像

### 3.2 Dockerfile高频指令
| 指令 | 作用 |
| ---- | ---- |
| `FROM` | 指定基础镜像，文件首行必填 |
| `MAINTAINER` | 标注作者信息 |
| `COPY` | 将本地文件复制进镜像内 |
| `RUN` | 镜像构建阶段执行系统命令 |
| `WORKDIR` | 设置容器内默认工作目录 |
| `EXPOSE` | 声明容器对外暴露端口 |
| `CMD` | 容器启动执行命令，仅最后一条生效 |

### 3.3 目录结构
```
dockerfile-demo/
├── Dockerfile
└── index.html
```
#### index.html页面内容
```html
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <title>自定义Nginx镜像</title>
</head>
<body>
    <h1>我的第一个Docker自定义镜像</h1>
    <p>作者：songcunye</p>
    <p>基于Nginx官方镜像构建</p>
</body>
</html>
```
#### Dockerfile编写内容
```dockerfile
FROM nginx:latest
MAINTAINER songcunye
COPY index.html /usr/share/nginx/html/index.html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

### 3.4 构建镜像&启动验证
```bash
# 构建自定义镜像 末尾.代表当前构建上下文目录
docker build -t my-nginx:v1 .
# 启动自定义镜像容器
docker run -d --name my-nginx-run -p 8082:80 my-nginx:v1
```

![镜像构建日志](./images/docker02_build_log.png)

访问地址：`127.0.0.1:8082` 查看自定义HTML页面

![网页预览效果](./images/docker03_web_preview.png)

### 3.5 镜像优化要点
1. 多条RUN命令用`&&`合并，减少镜像层级降低体积
2. 构建目录仅保留必要文件，减少构建上下文大小
3. 静态文件拷贝优先使用COPY，ADD仅用于解压/远程文件场景

---
## 四、Docker Compose 多容器编排部署
### 4.1 Compose定位
替代多条零散docker run命令，单yaml配置文件管理多个关联容器，一键创建网络、批量启停整套业务（Nginx+数据库）

### 4.2 Compose常用命令
```bash
# 后台启动全部服务
docker compose up -d
# 查看编排容器运行状态
docker compose ps
# 实时查看服务日志
docker compose logs -f
# 重启整套服务
docker compose restart
# 删除容器+自定义网络（挂载数据卷保留）
docker compose down
```

### 4.3 docker-compose.yml完整配置
```yaml
services:
  nginx:
    image: my-nginx:v1
    container_name: compose-nginx
    ports:
      - "8083:80"
    restart: always

  mysql:
    image: mariadb:5.5
    container_name: compose-mysql
    ports:
      - "3307:3306"
    environment:
      MYSQL_ROOT_PASSWORD: Admin123!
    volumes:
      - /data/compose_mysql:/var/lib/mysql
    restart: always
```
### 4.4 部署执行流程
1. cd进入yml配置文件所在文件夹
2. 执行启动命令
```bash
sudo docker compose up -d
```
3. 查看容器运行状态
```bash
sudo docker compose ps
```

![Compose启动日志](./images/docker04_compose_start.png)

### 4.5 编排特性说明
1. Compose自动创建专属网桥网络，同yml内容器可通过容器名互相访问
2. restart: always 配置容器开机自启、异常自动重启
3. 统一管理，一条命令即可启停整套Web+数据库环境

---
## 五、常见问题与踩坑记录
### 1. permission denied 权限拒绝报错
**报错场景**：普通用户执行docker命令提示无法连接socket
解决方法：
```bash
# 临时方案：所有docker命令前加sudo
# 永久免sudo方案
sudo usermod -aG docker songcunye
newgrp docker
```

### 2. docker compose no configuration file provided
原因：当前终端目录无docker-compose.yml配置文件
解决：`cd`切换到yml文件所在目录后再执行compose命令

### 3. 镜像拉取超时失败
原因：默认海外镜像源网络不稳定
解决：配置国内阿里云镜像加速器

### 4. HTML页面中文乱码
原因：网页未指定UTF-8字符集
解决：html head标签内添加 `<meta charset="UTF-8">`

### 5. docker build 构建提示文件不存在
原因：build命令末尾遗漏`.`（当前构建上下文目录）
正确格式：`docker build -t 镜像名称:版本 .`

---
## 六、面试高频考点总结
1. 镜像与容器核心区别：镜像是静态只读模板，容器是镜像运行的动态进程实例
2. 容器数据持久化实现方式：宿主机目录-v挂载数据卷
3. Dockerfile中COPY与ADD、CMD与ENTRYPOINT区别
4. 镜像分层缓存机制，镜像体积优化思路
5. Docker Compose使用场景：单机多容器统一编排管理
6. Docker四种网络模式：bridge桥接、host主机、none无网络、container共享网络
```

