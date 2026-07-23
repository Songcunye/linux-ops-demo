# 基础镜像：基于官方nginx最新版
FROM nginx:latest

# 作者信息
MAINTAINER songcunye

# 把本地的index.html 复制到容器内nginx网页目录
COPY index.html /usr/share/nginx/html/index.html

# 声明容器暴露80端口
EXPOSE 80

# 容器启动时运行的命令（nginx前台运行）
CMD ["nginx", "-g", "daemon off;"]
