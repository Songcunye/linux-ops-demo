




# Prometheus运维监控体系部署实战
## 目录
1. [监控基础概念](#1-监控基础概念)
2. [核心组件介绍](#2-核心组件介绍)
3. [Docker部署全套命令](#3-docker部署全套命令)
4. [Prometheus采集配置 prometheus.yml](#4-prometheus采集配置-prometheusyml)
5. [Grafana可视化配置流程](#5-grafana可视化配置流程)
6. [常用PromQL查询语句](#6-常用promql查询语句)
7. [部署踩坑故障汇总](#7-部署踩坑故障汇总)
8. [项目总结](#8-项目总结)

---

## 1. 监控基础概念
Prometheus 是开源时序数据库监控系统，采用**Pull模式**主动抓取监控指标；
适合服务器、容器业务指标采集，搭配Grafana实现可视化，支持自定义告警规则。
核心优势：轻量化、部署简单、原生支持容器环境、丰富的查询语法PromQL。

## 2. 核心组件介绍
1. **Prometheus Server**：主服务，采集指标、存储时序数据、执行告警规则
2. **Node Exporter**：服务器指标采集器，采集CPU、内存、磁盘、网络信息
3. **Grafana**：可视化面板工具，搭配Prometheus数据源展示监控图表
4. **Alert Rules**：自定义告警规则，达到阈值后触发告警（本项目重点实现）

## 3. Docker部署全套命令
采用Docker Compose一键编排所有组件，环境：阿里云ECS Linux。

### 目录结构
```
prometheus-monitor-notes/
├── docker-compose.yml
├── prometheus/
│   ├── prometheus.yml
│   └── alert-rules.yml
├── images/      #存放所有截图
└── prometheus-monitor.md
```

### docker-compose.yml完整配置
```yaml
services:
  prometheus:
    image: prom/prometheus:latest
    volumes:
      - ./prometheus:/etc/prometheus
      - prom_data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
    ports:
      - "9090:9090"
    restart: always

  node-exporter:
    image: prom/node-exporter:latest
    ports:
      - "9100:9100"
    restart: always

  grafana:
    image: grafana/grafana:latest
    volumes:
      - grafana_data:/var/lib/grafana
    ports:
      - "3000:3000"
    restart: always

volumes:
  prom_data:
  grafana_data:
```

### 启动与验证命令
```bash
# 启动服务
docker compose up -d

# 查看容器运行状态
docker compose ps

# 校验Prometheus配置文件
docker compose exec prometheus promtool check config /etc/prometheus/prometheus.yml
```
![Prometheus配置校验](./images/prom-config-check.png)

> 💡重要知识点：修改volumes挂载配置，必须执行`docker compose down && docker compose up -d`，单纯restart无法更新挂载策略。

## 4. Prometheus采集配置 prometheus.yml
```yaml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: "node-server"
    static_configs:
      - targets: ["node-exporter:9100"]

rule_files:
  - "alert-rules.yml"
```

### alert-rules.yml 告警规则示例
```yaml
groups:
- name: server-alert
  rules:
  - alert: HighCpuUsage
    expr: 100 - (avg by (instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 80
    for: 1m
    labels:
      severity: warning
    annotations:
      summary: "服务器CPU使用率过高"
```

## 5. Grafana可视化配置流程
1. 访问地址：`ECS公网IP:3000`，初始账号`admin`
2. 忘记密码重置命令
```bash
docker compose exec grafana grafana-cli admin reset-admin-password Admin@123
```
3. 添加数据源
- Data sources → Add source → Prometheus
- URL填写：`http://prometheus:9090`，测试连通性
4. 导入监控面板
Import面板ID：**1860**（Node Exporter主机监控模板）

![Grafana主机监控大盘](./images/grafana-dashboard.png)

### Prometheus服务验证
访问 `IP:9090` → Status → Targets，查看采集目标状态
![采集目标Targets状态](./images/prom-targets.png)

## 6. 常用PromQL查询语句
```promql
# CPU使用率
100 - (avg by (instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)

# 内存使用率
100 - (node_Memory_MemFree_bytes / node_Memory_MemTotal_bytes * 100)

# 磁盘使用率
100 - (node_filesystem_free_bytes / node_filesystem_size_bytes * 100)
```

## 7. 部署踩坑故障汇总
### 故障1：宿主机存在告警规则文件，容器无法加载alert-rules.yml
现象：配置校验输出 `SUCCESS: 0 rule files found`
根因：docker采用**单文件挂载**，仅映射prometheus.yml，同目录其他文件不会同步至容器。
解决方案：改为**目录挂载模式 `- ./prometheus:/etc/prometheus`**，重建容器。

挂载成功验证命令：
```bash
docker compose exec prometheus ls -l /etc/prometheus/
```
![目录挂载成功](./images/mount-success.png)

### 故障2：Grafana管理员密码遗忘
解决方案：使用grafana-cli命令在线重置密码，无需清空面板数据。

### 故障3：Prometheus无法采集node-exporter指标
排查方向：安全组端口放行、compose内部服务域名互通、服务是否正常Up。

## 8. 项目总结
1. 使用Docker Compose完成Prometheus、NodeExporter、Grafana整套监控环境部署
2. 实现服务器指标采集、PromQL数据分析、Grafana可视化大盘
3. 编写自定义告警规则，掌握容器挂载故障排查思路
4. 熟悉Docker数据卷、目录挂载与单文件挂载的区别，积累容器运维排错经验
```


