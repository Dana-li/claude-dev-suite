---
name: skill-dev-db-migration
version: 1.0.0
description: |
  数据库迁移技能 - 字段改名/迁移/兼容性策略
  
  适用场景：
  - 实体字段改名（如 ffmpegPath → globalFfmpegPath）
  - 字段类型变更（VARCHAR → TEXT、INT → BIGINT）
  - 字段拆分/合并
  - 数据迁移（实例级 → 全局级）
  - 添加/删除索引
  - 外键约束变更
  
  核心原则：
  - 始终提供回滚方案
  - 兼容性优先于性能
  - 迁移脚本必须幂等
  - 大数据量分批处理
agent_created: true
created_date: 2026-05-07
tags: [database, migration, flyway, liquibase, sql]
---

# 数据库迁移技能 (skill-dev-db-migration)

## 一、触发条件

当任务涉及以下任一场景时，必须使用本技能：

1. **字段改名** — 数据库已有数据的字段名变更
2. **字段迁移** — 数据从 A 表/字段迁移到 B 表/字段
3. **字段拆分** — 一个字段拆分为多个字段
4. **字段合并** — 多个字段合并为一个
5. **类型变更** — 字段类型不兼容变更（如 INT → VARCHAR）
6. **约束变更** — 添加/删除 NOT NULL、默认值、外键
7. **索引变更** — 添加/删除索引影响查询性能

## 二、分析阶段（Phase 1: Analysis）

### 2.1 依赖检查清单

```markdown
### 依赖检查

- [ ] 确认迁移涉及的实体类（Entity/DTO/VO）
- [ ] 确认使用 JPA/MyBatis-Plus 的字段映射
- [ ] 确认是否有 REST API 字段绑定
- [ ] 确认是否有缓存层（Redis/本地缓存）使用旧字段
- [ ] 确认是否有消息队列消费者使用旧字段
- [ ] 确认是否有定时任务/批处理使用旧字段
- [ ] 确认是否有前端表单绑定旧字段
- [ ] 确认是否有导出/导入功能涉及旧字段
```

### 2.2 数据量评估

```bash
# 评估迁移数据量
SELECT COUNT(*) FROM table_name;
SELECT COUNT(*) FROM table_name WHERE field IS NOT NULL;

# 评估关联数据量
SELECT COUNT(DISTINCT related_id) FROM table_name;
```

### 2.3 兼容性分析

| 场景 | 兼容性方案 |
|------|-----------|
| 字段改名 | 新增字段 → 数据迁移 → API 更新 → 旧字段标记废弃 → 删除 |
| 字段删除 | 标记废弃 → 监控无使用 → 删除 |
| 类型变更 | 新增临时字段 → 迁移数据 → 切换 → 删除旧字段 |
| 字段拆分 | 新增子字段 → 部分数据迁移 → 全量迁移 → 旧字段废弃 |
| 字段合并 | 新增合并字段 → 迁移数据 → 删除原始字段 |

## 三、策略选择（Phase 2: Strategy）

### 3.1 四种迁移策略

```
┌─────────────────────────────────────────────────────────────┐
│ 策略 A: 直接变更（仅小表、无数据、无 API 暴露）                 │
│   ALTER TABLE ... 直接执行                                  │
├─────────────────────────────────────────────────────────────┤
│ 策略 B: 增删字段模式（推荐，字段改名/拆分/合并）               │
│   1. 新增字段（新列/新表）                                   │
│   2. 数据迁移脚本                                           │
│   3. 验证数据一致性                                         │
│   4. 切换业务代码                                           │
│   5. 废弃并删除旧字段                                       │
├─────────────────────────────────────────────────────────────┤
│ 策略 C: 版本兼容模式（API 兼容、字段共存）                    │
│   1. 新增字段，保留旧字段                                   │
│   2. 写：双写（写入新旧字段）                                │
│   3. 读：优先读新字段，降级读旧字段                          │
│   4. 确认无依赖后删除旧字段                                  │
├─────────────────────────────────────────────────────────────┤
│ 策略 D: 表替换模式（大数据量、高风险变更）                    │
│   1. 创建新表                                               │
│   2. 迁移数据（分批）                                       │
│   3. 原子切换（重命名）                                     │
│   4. 旧表备份观察                                            │
└─────────────────────────────────────────────────────────────┘
```

### 3.2 策略选择决策树

```
开始
  │
  ├─ 数据量 < 1000 行？
  │     ├─ 是 → 策略 A（直接变更）
  │     └─ 否 → 继续
  │
  ├─ 是否需要 API 兼容？
  │     ├─ 是 → 策略 C（版本兼容）
  │     └─ 否 → 继续
  │
  ├─ 字段结构是否根本性改变？
  │     ├─ 是 → 策略 D（表替换）
  │     └─ 否 → 策略 B（增删字段）
  │
结束
```

## 四、脚本生成（Phase 3: Script Generation）

### 4.1 Flyway 迁移脚本命名规范

```
V{version}__{description}.sql

示例：
V1.0.0.001__add_ffmpeg_global_path_column.sql
V1.0.0.002__migrate_instance_ffmpeg_to_global.sql
V1.0.0.003__drop_instance_ffmpeg_path_column.sql
```

### 4.2 迁移脚本模板

#### 模板 A: 新增字段

```sql
-- {version}__{description}.sql
-- 描述：{变更说明}
-- 策略：{选择策略}

-- ============================================
-- Step 1: 新增字段
-- ============================================
ALTER TABLE {table_name}
ADD COLUMN {new_column_name} {column_type}
{DEFAULT default_value | NULL};

-- 添加索引（如需要）
CREATE INDEX idx_{table_name}_{column_name} ON {table_name}({column_name});

-- ============================================
-- Step 2: 数据迁移（可选）
-- ============================================
UPDATE {table_name}
SET {new_column_name} = {expression}
WHERE {new_column_name} IS NULL;

-- ============================================
-- Step 3: 添加约束（如需要）
-- ============================================
-- 在确认数据迁移完成后执行
ALTER TABLE {table_name}
MODIFY COLUMN {new_column_name} {column_type} NOT NULL;
```

#### 模板 B: 字段改名（增删字段模式）

```sql
-- {version}__rename_{old_column}_to_{new_column}.sql
-- 描述：将 {table}.{old_column} 改名为 {new_column}
-- 策略：策略 B - 增删字段模式（保留旧字段过渡）

-- ============================================
-- Step 1: 新增新字段
-- ============================================
ALTER TABLE {table_name}
ADD COLUMN {new_column_name} {column_type}
{DEFAULT default_value | NULL};

-- ============================================
-- Step 2: 数据迁移
-- ============================================
UPDATE {table_name}
SET {new_column_name} = {old_column_name}
WHERE {new_column_name} IS NULL;

-- ============================================
-- Step 3: 迁移完成后，删除旧字段（分阶段执行）
-- ============================================
-- 此步骤在确认无依赖后执行
-- ALTER TABLE {table_name} DROP COLUMN {old_column_name};
```

#### 模板 C: 数据迁移（实例级 → 全局级）

```sql
-- {version}__migrate_ffmpeg_to_global.sql
-- 描述：将实例级 ffmpegPath 迁移到全局配置
-- 策略：策略 B - 增删字段模式

-- ============================================
-- Step 1: 创建全局配置表（如果不存在）
-- ============================================
CREATE TABLE IF NOT EXISTS gb_global_config (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    config_key VARCHAR(100) NOT NULL UNIQUE,
    config_value TEXT,
    description VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- ============================================
-- Step 2: 迁移现有实例的 ffmpegPath 到全局配置
-- ============================================
INSERT INTO gb_global_config (config_key, config_value, description)
SELECT DISTINCT 'ffmpeg.path', ffmpeg_path, '从实例迁移的 FFmpeg 全局路径'
FROM gb_simulator_instance
WHERE ffmpeg_path IS NOT NULL AND ffmpeg_path != ''
ON DUPLICATE KEY UPDATE
    config_value = VALUES(config_value),
    updated_at = CURRENT_TIMESTAMP;

-- ============================================
-- Step 3: 更新实例的 ffmpegPath 为 NULL
-- ============================================
UPDATE gb_simulator_instance
SET ffmpeg_path = NULL
WHERE ffmpeg_path IS NOT NULL;

-- ============================================
-- Step 4: 验证迁移结果
-- ============================================
-- SELECT COUNT(*) as global_configs FROM gb_global_config WHERE config_key = 'ffmpeg.path';
-- SELECT COUNT(*) as instances_with_null_ffmpeg FROM gb_simulator_instance WHERE ffmpeg_path IS NULL;
```

### 4.3 回滚脚本模板

```sql
-- R{version}__{description}.sql
-- 回滚：{version}__{description}

-- ============================================
-- 回滚 Step: {操作说明}
-- ============================================
-- 注意：回滚可能丢失迁移后新增的数据
```

## 五、执行阶段（Phase 4: Execution）

### 5.1 迁移执行检查清单

```markdown
### 执行前检查

- [ ] 备份当前数据库（或确认有最近备份）
- [ ] 在测试环境验证迁移脚本
- [ ] 确认无长事务运行（`SHOW PROCESSLIST`）
- [ ] 确认无主从复制延迟
- [ ] 通知相关团队（如果影响查询）

### 执行中

- [ ] 记录开始时间
- [ ] 监控执行时间（大表 > 1 分钟需谨慎）
- [ ] 如有异常立即停止并回滚

### 执行后验证

- [ ] 验证数据完整性（COUNT、CHECKSUM）
- [ ] 验证迁移数据量（迁移前 vs 迁移后）
- [ ] 执行相关查询测试
- [ ] 确认应用日志无数据库错误
```

### 5.2 大数据量分批处理

```sql
-- 分批迁移脚本模板
-- 每批处理 1000 行，间隔 100ms

DELIMITER //

CREATE PROCEDURE migrate_data_batch()
BEGIN
    DECLARE batch_size INT DEFAULT 1000;
    DECLARE offset_val INT DEFAULT 0;
    DECLARE affected_rows INT DEFAULT 1;

    WHILE affected_rows > 0 DO
        UPDATE {table_name}
        SET {new_column} = {expression}
        WHERE {condition}
        AND id IN (
            SELECT id FROM (
                SELECT id FROM {table_name}
                WHERE {condition}
                LIMIT batch_size OFFSET offset_val
            ) AS tmp
        );

        SET affected_rows = ROW_COUNT();
        SET offset_val = offset_val + batch_size;

        -- 防止无限循环
        IF offset_val > 10000000 THEN
            LEAVE;
        END IF;

        -- 短暂休眠（生产环境可调整或移除）
        DO SLEEP(0.1);
    END WHILE;
END //

DELIMITER ;

-- 执行
CALL migrate_data_batch();

-- 删除存储过程
DROP PROCEDURE IF EXISTS migrate_data_batch;
```

## 六、验证阶段（Phase 5: Verification）

### 6.1 数据一致性验证

```sql
-- 1. 记录迁移前状态
SELECT COUNT(*) as total_rows FROM {table_name};
SELECT COUNT(*) as null_count FROM {table_name} WHERE {column} IS NULL;

-- 2. 迁移后验证
-- 2.1 行数一致性
SELECT COUNT(*) as total_rows FROM {table_name};  -- 必须等于迁移前

-- 2.2 必填字段无 NULL
SELECT COUNT(*) as unexpected_nulls FROM {table_name}
WHERE {new_required_column} IS NULL;  -- 必须为 0

-- 2.3 数据完整性校验和
SELECT COUNT(DISTINCT {checksum_column}) as unique_count FROM {table_name};
-- 必须等于迁移前唯一值数量

-- 2.4 业务规则验证
-- 根据具体业务规则编写
SELECT * FROM {table_name}
WHERE {business_rule_condition}
LIMIT 10;
```

### 6.2 应用验证

```bash
# 1. 启动应用，观察日志
# 确保无数据库异常

# 2. 执行关键业务操作
# - 创建新记录
# - 查询包含新字段的列表
# - 更新新字段
# - 删除记录

# 3. 检查缓存状态
# 如果使用 Redis，确认缓存已失效或更新
redis-cli KEYS "*{table_name}*"

# 4. 检查消息队列
# 如果有消费者，确认能正确处理新字段格式
```

## 七、特殊情况处理

### 7.1 外键约束处理

```sql
-- 禁用外键检查（迁移时）
SET FOREIGN_KEY_CHECKS = 0;

-- ... 执行迁移 ...

-- 启用外键检查
SET FOREIGN_KEY_CHECKS = 1;

-- 验证外键完整性
SELECT
    kcu.TABLE_NAME,
    kcu.COLUMN_NAME,
    kcu.REFERENCED_TABLE_NAME,
    kcu.REFERENCED_COLUMN_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE kcu
WHERE kcu.TABLE_SCHEMA = '{database_name}'
AND kcu.REFERENCED_TABLE_NAME IS NOT NULL;
```

### 7.2 全文索引重建

```sql
-- MySQL 全文索引重建
ALTER TABLE {table_name} DROP INDEX {index_name};
ALTER TABLE {table_name} ADD FULLTEXT INDEX {index_name}({column_name});

-- 或使用OPTIMIZE TABLE
OPTIMIZE TABLE {table_name};
```

### 7.3 表结构同步（多环境）

```bash
# 使用 mysqldump 导出表结构
mysqldump -h {host} -u {user} -p --no-data {database} {table_name} > structure.sql

# 使用 liquibase diff 生成差异
liquibase diff
```

## 八、与 Dev Suite 其他技能集成

### 8.1 与 brainstorming 集成

在 brainstorming 讨论到数据库变更时：
```
提示用户："这个需求涉及数据库字段变更（{具体描述}），需要使用 skill-dev-db-migration 进行分析。"
```

### 8.2 与 skill-dev-review 集成

在代码审查阶段：
```
检查清单：
- [ ] 迁移脚本已生成
- [ ] 回滚脚本已准备
- [ ] 迁移策略已记录
- [ ] 数据验证 SQL 已编写
```

### 8.3 与 skill-dev-verification 集成

在验证阶段执行：
```
1. 运行数据一致性验证 SQL
2. 执行应用关键业务操作
3. 确认日志无数据库错误
```

## 九、最佳实践

1. **永远先备份** — 任何迁移前确保有可用备份
2. **幂等脚本** — 多次执行结果一致
3. **小步快跑** — 大变更拆分为多个小迁移
4. **监控执行时间** — 大表变更可能锁表
5. **灰度发布** — 先在测试环境充分验证
6. **文档记录** — 每个迁移必须记录原因和影响

## 十、常见陷阱

| 陷阱 | 后果 | 避免方法 |
|------|------|----------|
| 未考虑索引 | 查询性能下降 | 迁移前分析查询模式 |
| 未清理缓存 | 数据不一致 | 迁移后刷新相关缓存 |
| 未更新文档 | 后续维护困难 | 同步更新 API 文档 |
| 未通知相关方 | 服务中断 | 提前沟通变更计划 |
| 未测试回滚 | 无法恢复 | 必须测试回滚脚本 |
