---
name: skill-dev-test
description: 自动生成单元测试，覆盖正常路径、边界值、异常场景。触发场景：用户要求生成测试、为函数编写测试用例、增加测试覆盖。
allowed-tools: Read,Grep,Glob,Write,Bash
---

# 单元测试生成 Skill

## 功能范围

- ✅ 自动分析源代码
- ✅ 智能检测测试框架
- ✅ 生成 5 类测试用例
- ✅ Mock 外部依赖
- ✅ 输出测试摘要

## 支持框架

| 语言 | 框架 | Mock 库 |
|------|------|---------|
| Java | JUnit 5 | Mockito |
| Python | pytest | unittest.mock |
| JavaScript/TypeScript | Jest / Vitest | jest.fn() |
| Go | go test | - |
| Vue | Vitest | @vue/test-utils |

## 测试用例分类

### 5 类必测场景

1. **正常路径** — 正常输入，预期输出
2. **边界：空/零值** — 空字符串、空列表、零、None/null
3. **边界：极值** — 最小/最大值、单元素
4. **错误：无效输入** — 类型错误、越界、格式错误
5. **错误：外部失败** — API 超时、DB 错误、文件未找到

## 生成流程

```
Step 1: 分析源代码
   ↓
Step 2: 检测测试框架
   ↓
Step 3: 生成测试用例（5 类）
   ↓
Step 4: 编写测试代码
   ↓
Step 5: 输出摘要
```

## 输出摘要格式

```markdown
# 测试生成摘要

## 目标文件
[文件路径]

## 测试框架
[JUnit 5 / pytest / Jest]

## 测试用例统计

| 类型 | 数量 |
|------|------|
| 正常路径 | X |
| 边界值 | X |
| 异常处理 | X |
| **总计** | **X** |

## 创建/修改文件

| 文件 | 操作 |
|------|------|
| [测试文件1] | 新增 |
| [测试文件2] | 修改 |

## 运行命令
```bash
[测试运行命令]
```
```

## Java (JUnit 5 + Mockito) 示例

```java
@ExtendWith(MockitoExtension.class)
class UserServiceTest {

    @Mock
    private UserRepository userRepository;

    @InjectMocks
    private UserService userService;

    // 正常路径
    @Test
    void testGetUserById_Success() {
        // Given
        Long userId = 1L;
        User expected = new User(userId, "张三");
        when(userRepository.findById(userId)).thenReturn(expected);

        // When
        User result = userService.getUserById(userId);

        // Then
        assertEquals(expected.getName(), result.getName());
    }

    // 边界：空值
    @Test
    void testGetUserById_NotFound() {
        // Given
        Long userId = 999L;
        when(userRepository.findById(userId)).thenReturn(null);

        // When & Then
        assertThrows(UserNotFoundException.class,
            () -> userService.getUserById(userId));
    }
}
```

## 规则约束

1. ⚠️ 必须 mock 所有外部依赖（DB、API、文件系统）
2. ⚠️ 禁止 mock 被测函数本身
3. ✅ 使用描述性命名：`test_<功能>_<场景>`
4. ✅ 每个测试至少包含一个断言
5. ✅ 修改全局状态时必须在 afterEach 清理

## 使用方式

| 场景 | 触发方式 |
|------|----------|
| 开发流程 | `/dev-feature` (Phase 5) |
| 独立测试生成 | `/skill-dev-test` |
