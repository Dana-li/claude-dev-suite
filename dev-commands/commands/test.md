---
description: Run tests with coverage and reporting
argument-hint: Optional test scope (unit, integration, all)
---

# Run Tests

> **版本**: v1.0
> **用途**: 规范化测试执行流程

---

## 执行步骤

### 1. 环境检查

```bash
# 检查测试框架
# Maven: mvn -version
# npm: npm -version

# 检查测试配置
ls -la src/test/
```

### 2. 执行测试

**Maven (Java)**:
```bash
# 单元测试
mvn test

# 集成测试
mvn verify -P integration

# 完整测试
mvn clean test
```

**npm (JavaScript/TypeScript)**:
```bash
# 单元测试
npm run test:unit

# E2E 测试
npm run test:e2e

# 全部测试
npm test
```

### 3. 测试报告

```bash
# 生成覆盖率报告
mvn test jacoco:report

# 查看报告
open target/site/jacoco/index.html
```

---

## 测试检查清单

| 检查项 | 说明 |
|--------|------|
| 单元测试 | 核心逻辑覆盖率 > 70% |
| 集成测试 | 关键流程验证 |
| E2E 测试 | 关键用户路径 |
| 性能测试 | 响应时间 < 200ms |

---

## 测试标准

| 指标 | 标准 |
|------|------|
| 覆盖率 | > 70% |
| 通过率 | 100% |
| 边界测试 | 已覆盖 |
| 并发测试 | 已覆盖 |

---

## 常见问题

### Q: 测试失败？
```bash
# 查看详细错误
mvn test -X

# 运行单个测试
mvn test -Dtest=UserServiceTest
```

### Q: 覆盖率不够？
```bash
# 查看未覆盖文件
open target/site/jacoco/index.html
```

---

**版本**: v1.0
**创建日期**: 2026-04-29
