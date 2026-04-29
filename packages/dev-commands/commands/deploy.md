---
description: Deployment checklist and validation
argument-hint: Optional environment (dev, staging, prod)
---

# Deployment Checklist

> **版本**: v1.0
> **用途**: 规范化部署流程

---

## 部署前检查

### 1. 代码检查

| 检查项 | 状态 |
|--------|------|
| 所有测试通过 | ☐ |
| 代码已审查 | ☐ |
| 无敏感信息 | ☐ |
| 文档已更新 | ☐ |

### 2. 构建验证

```bash
# 本地构建
mvn clean package -DskipTests
npm run build

# 镜像构建
docker build -t app:v1.0.0 .
```

### 3. 环境确认

```bash
# 检查环境
echo $ENVIRONMENT  # dev | staging | prod

# 检查配置
cat config/application.yml
```

---

## 部署步骤

### 1. 备份

```bash
# 备份数据库
mysqldump -u root -p db_name > backup_$(date +%Y%m%d).sql

# 备份配置
cp -r config/ config_backup/
```

### 2. 执行部署

**Docker 部署**:
```bash
# 拉取最新镜像
docker pull registry.example.com/app:latest

# 滚动更新
kubectl rolling-update app --image=app:v1.0.0
```

**传统部署**:
```bash
# 停止服务
systemctl stop app

# 部署新版本
cp app-v1.0.0.jar /opt/app/

# 启动服务
systemctl start app
```

### 3. 验证

```bash
# 健康检查
curl http://localhost:8080/actuator/health

# 日志检查
tail -f logs/app.log
```

---

## 部署后验证

| 检查项 | 说明 |
|--------|------|
| 服务启动 | 进程运行正常 |
| 健康检查 | /health 端点正常 |
| 功能验证 | 核心功能测试 |
| 监控指标 | 正常范围 |

---

## 回滚方案

```bash
# Docker 回滚
kubectl rollout undo deployment/app

# 传统回滚
systemctl stop app
cp app-v1.0.1.jar.bak /opt/app/
systemctl start app
```

---

## 通知

```bash
# 通知团队
curl -X POST "https://notify.example.com/webhook" \
  -d "{\"msg\": \"部署完成\", \"env\": \"prod\"}"
```

---

**版本**: v1.0
**创建日期**: 2026-04-29
