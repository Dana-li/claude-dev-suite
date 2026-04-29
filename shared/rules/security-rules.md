# 安全规则

## 1. 输入校验

### 1.1 参数校验
- ⚠️ 所有外部输入必须校验（请求参数、URL、Header、Cookie）
- ⚠️ 使用正则白名单，禁止黑名单
- ✅ 使用框架提供的校验注解

```java
// ✅ 正确：使用校验注解
@NotNull
@Size(min = 1, max = 100)
@Pattern(regexp = "^[a-zA-Z0-9_]+$")
private String username;

// ❌ 错误：手动校验字符串
if (username.contains("<script>")) {
    throw new BadRequestException();
}
```

### 1.2 SQL 注入防护
- ⚠️ 禁止字符串拼接 SQL
- ✅ 使用参数化查询
- ✅ 使用 ORM 框架

```java
// ✅ 正确：参数化查询
@Query("SELECT u FROM User u WHERE u.username = :username")
User findByUsername(@Param("username") String username);

// ❌ 错误：字符串拼接
String sql = "SELECT * FROM user WHERE name = '" + name + "'";
```

### 1.3 XSS 防护
- ⚠️ 输出到 HTML 前必须转义
- ✅ 使用框架的 HTML 转义功能
- ✅ 设置 HTTP Security Headers

## 2. 认证授权

### 2.1 认证
- ⚠️ 密码必须加密存储（BCrypt/Argon2）
- ⚠️ 会话 Token 必须随机、不可预测
- ✅ 使用标准 JWT 或 Session
- ❌ 禁止在 URL 中传递 Token

```java
// ✅ 正确：使用 @PreAuthorize
@PreAuthorize("hasRole('ADMIN')")
public void deleteUser(Long id) { }

// ❌ 错误：手动校验
if (!currentUser.isAdmin()) {
    throw new ForbiddenException();
}
```

### 2.2 权限校验
- ⚠️ 每个接口都要校验权限
- ⚠️ 使用框架的权限注解
- ✅ 遵循最小权限原则

## 3. 敏感数据

### 3.1 数据脱敏
- ⚠️ 日志中禁止记录敏感信息
- ⚠️ 返回结果中禁止包含明文密码

```java
// ✅ 正确：脱敏处理
log.info("用户登录: username={}, ip={}", username, ip);
// ❌ 错误：记录密码
log.info("登录: password={}", password);
```

### 3.2 加密存储
- ✅ 密码使用 BCrypt
- ✅ 敏感字段（如身份证号）使用 AES 加密
- ✅ 密钥使用专门的密钥管理服务

## 4. 常见漏洞防护

### 4.1 CSRF
- ✅ POST/PUT/DELETE 请求必须携带 CSRF Token
- ✅ 使用 SameSite Cookie

### 4.2 文件上传
- ⚠️ 限制文件大小
- ⚠️ 验证文件类型（MIME + 扩展名）
- ⚠️ 上传文件重命名，禁止用户指定文件名
- ⚠️ 文件存储在非 Web 根目录

### 4.3 外部调用
- ⚠️ 调用外部 API 必须设置超时
- ⚠️ 必须验证 SSL 证书
- ⚠️ 敏感数据必须加密传输

## 5. 安全检查清单

- [ ] 所有输入参数有校验
- [ ] SQL 使用参数化查询
- [ ] 敏感数据已脱敏
- [ ] 密码已加密存储
- [ ] 接口有权限控制
- [ ] 错误信息不泄露敏感信息
- [ ] 日志不包含敏感数据
- [ ] 第三方依赖无已知漏洞
