# Java 编码规范

> 本规则适用于 Java/Spring Boot 项目开发

## 命名规范

| 类型 | 规范 | 示例 |
|------|------|------|
| 类名 | PascalCase | `UserService`, `OrderController` |
| 方法名 | camelCase | `getUserById`, `createOrder` |
| 变量名 | camelCase | `userName`, `orderList` |
| 常量 | UPPER_SNAKE_CASE | `MAX_RETRY_COUNT` |
| 包名 | 全小写 | `com.example.service` |

## 代码风格

### 类结构顺序

```java
public class UserService {

    // 1. 常量
    private static final Logger log = LoggerFactory.getLogger(UserService.class);

    // 2. 成员变量
    @Autowired
    private UserMapper userMapper;

    // 3. 构造方法
    public UserService() {
    }

    // 4. 公共方法
    public User getUserById(Long id) {
        return userMapper.selectById(id);
    }

    // 5. 私有方法
    private void validateUser(User user) {
        // ...
    }
}
```

### 方法规范

```java
// ✅ 好的实践
public User createUser(UserDTO dto) {
    // 1. 参数校验
    validate(dto);

    // 2. 转换
    User user = convertToEntity(dto);

    // 3. 保存
    User saved = userMapper.insert(user);

    // 4. 返回
    return saved;
}

// ❌ 避免
public User createUser(UserDTO dto) {
    if (dto == null) throw new IllegalArgumentException();
    // 太多代码...
}
```

## Spring Boot 规范

### 控制器

```java
@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;

    @GetMapping("/{id}")
    public Result<User> getUser(@PathVariable Long id) {
        return Result.success(userService.getUserById(id));
    }

    @PostMapping
    public Result<User> createUser(@Valid @RequestBody UserDTO dto) {
        return Result.success(userService.createUser(dto));
    }
}
```

### 服务层

```java
@Service
@Transactional(readOnly = true)
@RequiredArgsConstructor
public class UserService {

    private final UserMapper userMapper;

    @Transactional
    public User createUser(UserDTO dto) {
        // 实现
    }
}
```

## 日志规范

```java
// ✅ 正确级别
log.debug("查询参数: {}", params);     // 调试信息
log.info("用户登录: {}", username);    // 一般信息
log.warn("重试次数: {}", retryCount);  // 警告信息
log.error("保存失败", ex);              // 错误信息

// ❌ 避免
log.info("开始处理");
log.info("处理完成");
// 不要用 info 记录步骤
```

## 异常处理

```java
// ✅ 全局异常处理
@ExceptionHandler(BusinessException.class)
public Result<Void> handleBusinessException(BusinessException e) {
    log.warn("业务异常: {}", e.getMessage());
    return Result.fail(e.getCode(), e.getMessage());
}

// ❌ 避免捕获具体异常
try {
    // ...
} catch (NullPointerException e) {
    // 不要这样
}
```

## 数据库规范

### Mapper 命名

```java
// ✅
User selectById(Long id);
User selectByUsername(String username);
List<User> selectByStatus(Integer status);

// ❌
User getUser(Long id);  // 不要混用 select/get
```

## 安全规范

```java
// ❌ 禁止
String sql = "SELECT * FROM user WHERE id = " + id;

// ✅ 使用参数化查询
@Select("SELECT * FROM user WHERE id = #{id}")
User selectById(Long id);
```
