# 数据库规范

## 1. 命名规范

### 1.1 表命名
- ✅ 使用小写字母和下划线
- ✅ 使用复数名词
- ✅ 包含业务前缀（如 `sys_`, `biz_`）

```sql
-- ✅ 正确
CREATE TABLE biz_user_orders (...);
CREATE TABLE sys_configurations (...);

-- ❌ 错误
CREATE TABLE UserOrder (...);
CREATE TABLE userOrders (...);
```

### 1.2 字段命名
| 类型 | 命名规则 | 示例 |
|------|----------|------|
| 普通字段 | 小写下划线 | `user_name` |
| 主键 | `id` 或 `表名_id` | `id`, `user_id` |
| 外键 | `表名_id` | `order_id`, `product_id` |
| 时间字段 | `_at` 或 `_time` | `created_at`, `login_time` |
| 状态字段 | `status` | `status` |
| 布尔字段 | `is_` 或 `has_` | `is_deleted`, `has_permission` |

### 1.3 索引命名
```
idx_<表名>_<字段名>     # 普通索引
uk_<表名>_<字段名>      # 唯一索引
fk_<表名>_<字段名>      # 外键索引
```

## 2. 表结构规范

### 2.1 必须字段
```sql
CREATE TABLE biz_user (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    created_by VARCHAR(64) DEFAULT '' COMMENT '创建人',
    updated_by VARCHAR(64) DEFAULT '' COMMENT '更新人',
    is_deleted TINYINT NOT NULL DEFAULT 0 COMMENT '删除标记:0-未删除,1-已删除',
    version INT NOT NULL DEFAULT 0 COMMENT '乐观锁版本号'
) COMMENT '用户表';
```

### 2.2 字段类型选择
| 数据 | Java 类型 | MySQL 类型 | 说明 |
|------|-----------|------------|------|
| 主键 | Long | BIGINT | 自增主键 |
| 金额 | BigDecimal | DECIMAL(10,2) | 精确计算 |
| 状态 | Integer | TINYINT | 状态码 |
| 枚举 | Integer | TINYINT | 小范围枚举 |
| 日期 | LocalDateTime | DATETIME | 时间戳 |
| 长文本 | String | TEXT | 超过 255 字符 |
| 短文本 | String | VARCHAR(255) | 255 字符内 |

## 3. 索引规范

### 3.1 索引创建原则
- ✅ WHERE 条件字段添加索引
- ✅ JOIN 连接字段添加索引
- ✅ ORDER BY 字段添加索引
- ❌ 不在重复度高的字段建索引（性别）
- ❌ 避免过多索引（影响写性能）

### 3.2 索引使用规范
```sql
-- ✅ 利用索引
WHERE status = 1 AND created_at > '2024-01-01'
WHERE name LIKE '张%'

-- ❌ 索引失效
WHERE YEAR(created_at) = 2024
WHERE name LIKE '%三%'
WHERE status + 1 = 2
```

## 4. SQL 规范

### 4.1 SELECT 规范
```sql
-- ✅ 明确指定字段
SELECT id, username, email FROM biz_user;

-- ❌ 避免 SELECT *
SELECT * FROM biz_user;

-- ✅ 使用别名
SELECT u.id, u.username FROM biz_user u;

-- ✅ 大表使用 LIMIT
SELECT id, username FROM biz_user LIMIT 100;
```

### 4.2 INSERT 规范
```sql
-- ✅ 批量插入
INSERT INTO biz_user (username, email) VALUES
('user1', 'user1@example.com'),
('user2', 'user2@example.com');

-- ✅ 使用 INSERT IGNORE 或 ON DUPLICATE KEY UPDATE
INSERT INTO biz_user (id, username) VALUES (1, '张三')
ON DUPLICATE KEY UPDATE username = VALUES(username);
```

### 4.3 UPDATE/DELETE 规范
```sql
-- ✅ 带 WHERE 条件
UPDATE biz_user SET status = 1 WHERE id = 1;

-- ✅ 删除前先查询确认
SELECT * FROM biz_user WHERE id = 1;

-- ✅ 安全删除（软删除）
UPDATE biz_user SET is_deleted = 1 WHERE id = 1;
-- 而不是
DELETE FROM biz_user WHERE id = 1;
```

## 5. 事务规范

### 5.1 事务使用原则
- ✅ 保持事务简短
- ✅ 只对写操作使用事务
- ❌ 避免长事务
- ❌ 避免在事务中调用外部接口

### 5.2 隔离级别
| 场景 | 隔离级别 | 说明 |
|------|----------|------|
| 默认 | READ_COMMITTED | 可重复读 |
| 金融交易 | SERIALIZABLE | 串行化 |
| 统计查询 | READ_UNCOMMITTED | 读未提交 |

## 6. 性能规范

### 6.1 分页查询
```sql
-- ✅ 使用游标分页（大数据量）
SELECT * FROM biz_user WHERE id > #{lastId} ORDER BY id LIMIT 100;

-- ✅ 使用 OFFSET（数据量小）
SELECT * FROM biz_user LIMIT 20 OFFSET 100;
```

### 6.2 大表操作
```sql
-- ✅ 分批删除
DELETE FROM biz_log WHERE created_at < '2023-01-01' LIMIT 1000;

-- ✅ 使用临时表
CREATE TEMPORARY TABLE tmp_ids AS SELECT id FROM biz_user WHERE status = 1;
```

## 7. 数据库安全

### 7.1 账户规范
- ✅ 应用程序使用独立账户
- ✅ 遵循最小权限原则
- ❌ 禁止使用 root 远程连接

### 7.2 SQL 注入防护
- ✅ 使用参数化查询
- ❌ 禁止字符串拼接 SQL
