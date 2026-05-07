---
name: skill-dev-e2e
version: 1.0.0
description: |
  E2E 测试集成技能 - Playwright 测试识别、更新与验证
  
  适用场景：
  - 项目重构后更新 E2E 测试
  - 新增功能编写 E2E 测试
  - 删除废弃功能的测试清理
  - 回归测试执行
  - 视觉回归测试
  - CI/CD 集成 E2E
  
  核心原则：
  - 重构前先运行 E2E，确保基线
  - 重构后必须更新 E2E
  - 失败即停，不跳过测试
  - 测试即文档，描述清晰
agent_created: true
created_date: 2026-05-07
tags: [e2e, playwright, test, automation, ci-cd, regression]
---

# E2E 测试集成技能 (skill-dev-e2e)

## 一、触发条件

当任务涉及以下任一场景时，必须使用本技能：

1. **前端重构** — Vue 组件/页面修改后必须更新 E2E
2. **后端 API 变更** — 请求/响应字段变更
3. **新增功能** — 必须编写对应的 E2E 测试
4. **删除功能** — 必须清理对应的 E2E 测试
5. **上线前验证** — 完整 E2E 测试套件执行
6. **CI/CD 集成** — E2E 测试自动化

## 二、Playwright 测试识别（Phase 1: Discovery）

### 2.1 常见测试文件位置

```bash
# 项目根目录
/tests/e2e/
/test/e2e/
/e2e/

# tests 目录
/tests/
  /specs/
  /pages/
  /fixtures/

# Playwright 官方结构
/tests/
  /example.spec.ts
/tests-examples/
```

### 2.2 识别受影响的测试文件

```bash
# 查找所有 Playwright 测试文件
find . -name "*.spec.ts" -o -name "*.spec.js" -o -name "*.test.ts"

# 查找使用特定选择器的测试
grep -r "getByRole" --include="*.spec.ts" .
grep -r "locator('table')" --include="*.spec.ts" .
grep -r "page.goto" --include="*.spec.ts" .

# 查找涉及特定页面的测试
grep -r "/instances" --include="*.spec.ts" .
grep -r "/channels" --include="*.spec.ts" .

# 查找涉及特定文本的测试
grep -r "设备管理" --include="*.spec.ts" .
grep -r "视频资源" --include="*.spec.ts" .
```

### 2.3 Playwright 测试结构分析

```typescript
// 标准 Playwright 测试结构
import { test, expect, Page } from '@playwright/test';
import { LoginPage } from './pages/LoginPage';
import { DeviceListPage } from './pages/DeviceListPage';

test.describe('设备管理模块', () => {
  let page: Page;
  let loginPage: LoginPage;
  let deviceListPage: DeviceListPage;

  test.beforeEach(async ({ page: p }) => {
    page = p;
    loginPage = new LoginPage(page);
    deviceListPage = new DeviceListPage(page);
    
    // 登录
    await loginPage.goto();
    await loginPage.login('admin', 'password');
  });

  test('添加新设备', async () => {
    await deviceListPage.goto();
    await deviceListPage.clickAddButton();
    await deviceListPage.fillForm({
      name: '测试设备',
      port: 5060,
      ffmpegPath: '/usr/bin/ffmpeg',
    });
    await deviceListPage.submit();
    
    // 验证
    await expect(deviceListPage.getSuccessMessage()).toContainText('添加成功');
    await expect(deviceListPage.getTable()).toContainText('测试设备');
  });

  test.afterEach(async () => {
    // 清理
    await deviceListPage.cleanup();
  });
});
```

### 2.4 Page Object 模式

```typescript
// pages/DeviceListPage.ts
import { Page, Locator } from '@playwright/test';

export class DeviceListPage {
  readonly page: Page;
  readonly addButton: Locator;
  readonly table: Locator;
  readonly searchInput: Locator;
  readonly successMessage: Locator;

  constructor(page: Page) {
    this.page = page;
    this.addButton = page.getByRole('button', { name: '添加' });
    this.table = page.locator('table.ant-table');
    this.searchInput = page.getByPlaceholder('请输入设备名称');
    this.successMessage = page.locator('.ant-message-success');
  }

  async goto() {
    await this.page.goto('/instances');
  }

  async clickAddButton() {
    await this.addButton.click();
  }

  async fillForm(data: { name: string; port: number; ffmpegPath: string }) {
    await this.page.getByLabel('名称').fill(data.name);
    await this.page.getByLabel('端口').fill(String(data.port));
    await this.page.getByLabel('FFmpeg路径').fill(data.ffmpegPath);
  }

  async submit() {
    await this.page.getByRole('button', { name: '确定' }).click();
  }

  async getTable(): Promise<Locator> {
    return this.table;
  }

  async getSuccessMessage(): Promise<Locator> {
    return this.successMessage;
  }

  async cleanup() {
    // 清理测试数据
  }
}
```

## 三、测试更新流程（Phase 2: Update）

### 3.1 字段变更更新

```typescript
// Before: 旧字段名
test('编辑设备', async () => {
  await page.getByLabel('SIP端口').fill('5060');
  await page.getByLabel('SIP ID').fill('34020000001110000001');
});

// After: 新字段名（字段改名后）
test('编辑设备', async () => {
  await page.getByLabel('上级平台端口').fill('5060');      // sipPort → platformPort
  await page.getByLabel('上级平台ID').fill('34020000001110000001');  // sipId → platformId
});
```

### 3.2 页面路径变更更新

```typescript
// Before: 旧路由
test.describe.configure({ mode: 'serial' });
test('访问设备列表', async () => {
  await page.goto('/video-management/instances');
});

// After: 新路由（菜单重构后）
test('访问设备列表', async () => {
  await page.goto('/basic-data/instances');
});

// 或者使用 Page Object 模式，只需改一处
export class DeviceListPage {
  async goto() {
    await this.page.goto('/basic-data/instances');  // 改这一处即可
  }
}
```

### 3.3 菜单项变更更新

```typescript
// Before: 旧菜单名
test('导航到设备管理', async () => {
  await page.getByText('视频管理').click();
  await page.getByText('设备管理').click();
});

// After: 新菜单名（改名后）
test('导航到设备管理', async () => {
  await page.getByText('基础数据').click();           // 新增一级菜单
  await page.getByText('设备管理').click();
});
```

### 3.4 UI 组件变更更新

```typescript
// Before: 使用 a-input
test('输入设备名称', async () => {
  await page.locator('.ant-input').first().fill('测试设备');
});

// After: 使用 a-input-number（数字输入框）
test('输入设备端口', async () => {
  await page.locator('.ant-input-number-input').fill('5060');
});

// 更可靠的方式：使用更具体的选择器
test('输入设备信息', async () => {
  await page.getByLabel('设备名称').fill('测试设备');    // 使用 aria-label
  await page.getByRole('spinbutton', { name: '端口' }).fill('5060');
});
```

## 四、新功能测试编写（Phase 3: New Tests）

### 4.1 测试用例模板

```typescript
import { test, expect, Page } from '@playwright/test';

/**
 * 功能：{功能名称}
 * 需求：#{issue_number} {需求描述}
 * 测试数据：{测试数据说明}
 */
test.describe('{功能模块}', () => {
  
  test.beforeEach(async ({ page }) => {
    // 前置条件
    await page.goto('/login');
    await page.getByLabel('用户名').fill('admin');
    await page.getByLabel('密码').fill('password');
    await page.getByRole('button', { name: '登录' }).click();
    await expect(page).toHaveURL(/\/dashboard/);
  });

  test('{场景1_描述}', async ({ page }) => {
    // Arrange - 准备
    const testData = {
      name: '测试设备_' + Date.now(),
      port: 5060,
    };

    // Act - 执行
    await page.getByText('基础数据').click();
    await page.getByText('设备管理').click();
    await page.getByRole('button', { name: '添加' }).click();
    await page.getByLabel('名称').fill(testData.name);
    await page.getByLabel('端口').fill(String(testData.port));
    await page.getByRole('button', { name: '确定' }).click();

    // Assert - 验证
    await expect(page.getByText('保存成功')).toBeVisible();
    await expect(page.locator('table')).toContainText(testData.name);
  });

  test('{场景2_描述}', async ({ page }) => {
    // 边界条件测试
    await page.goto('/basic-data/devices');
    
    // 必填验证
    await page.getByRole('button', { name: '添加' }).click();
    await page.getByRole('button', { name: '确定' }).click();
    
    await expect(page.getByText('请输入名称')).toBeVisible();
  });
});
```

### 4.2 常用选择器优先级

```
1. 优先使用 (按可靠性排序)：
   - getByRole() - 无障碍角色（最可靠）
   - getByLabel() - 表单标签
   - getByText() - 文本内容
   - getByTestId() - data-testid 属性

2. 备选选择器：
   - locator() + CSS 选择器
   - locator() + XPath

3. 避免使用：
   - 精确索引选择器（first(), nth()）
   - 脆弱的 DOM 结构选择器
```

### 4.3 常用断言模式

```typescript
import { expect } from '@playwright/test';

// 元素存在/不存在
await expect(page.getByText('保存成功')).toBeVisible();
await expect(page.getByText('删除')).not.toBeVisible();

// 列表验证
await expect(page.locator('table tr')).toHaveCount(10);
await expect(page.locator('table')).toContainText('测试设备');

// 表单验证
await expect(page.getByLabel('名称')).toHaveValue('测试设备');
await expect(page.getByLabel('端口')).toHaveValue('5060');

// URL 验证
await expect(page).toHaveURL(/\/instances/);
await expect(page).toHaveURL(url => url.pathname === '/instances');

// 状态验证
await expect(page.getByRole('button', { name: '提交' })).toBeEnabled();
await expect(page.getByRole('button', { name: '提交' })).toBeDisabled();
await expect(page.getByRole('progressbar')).toBeHidden();

// 弹窗验证
test('确认删除弹窗', async ({ page }) => {
  await page.getByText('删除').click();
  const dialog = page.locator('.ant-popover');
  await expect(dialog).toBeVisible();
  await dialog.getByRole('button', { name: '确定' }).click();
  await expect(page.getByText('删除成功')).toBeVisible();
});
```

## 五、测试清理（Phase 4: Cleanup）

### 5.1 删除废弃功能的测试

```bash
# 识别不再需要的测试文件
# 1. 找到被删除页面的测试
grep -r "删除的页面路径" --include="*.spec.ts" -l

# 2. 确认可以安全删除
# 检查测试用例是否覆盖其他功能

# 3. 删除或标记为 skip
test.describe.skip('已废弃的XXX功能', () => {
  // ...
});
```

### 5.2 清理测试数据

```typescript
// 在 afterEach 中清理
test.afterEach(async ({ page }) => {
  // 方法1: 通过 UI 清理
  await cleanupTestData(page);
  
  // 方法2: 通过 API 清理（推荐，更快）
  const deviceId = await getCreatedDeviceId(page);
  if (deviceId) {
    await api.deleteDevice(deviceId);
  }
  
  // 方法3: 数据库清理（E2E 测试数据库）
  await db.query('DELETE FROM devices WHERE name LIKE \'测试%\' AND created_at < NOW() - INTERVAL 1 HOUR');
});

async function cleanupTestData(page: Page) {
  await page.goto('/devices');
  const deleteButtons = page.locator('button:has-text("删除")');
  const count = await deleteButtons.count();
  for (let i = 0; i < count; i++) {
    await deleteButtons.first().click();
    await page.getByRole('button', { name: '确定' }).click();
    await page.waitForTimeout(500);
  }
}
```

### 5.3 清理检查清单

```markdown
### 测试清理检查

- [ ] 被删除功能的测试已清理
- [ ] 废弃的测试文件已删除或 skip
- [ ] 测试数据清理逻辑已添加
- [ ] 清理逻辑不会误删其他数据
- [ ] 清理后验证测试可重复执行
```

## 六、测试执行（Phase 5: Execution）

### 6.1 本地执行

```bash
# 运行所有 E2E 测试
npx playwright test

# 运行特定测试文件
npx playwright test tests/e2e/devices.spec.ts

# 运行特定测试用例
npx playwright test -g "添加新设备"

# 运行带 UI 的测试（调试模式）
npx playwright test --ui

# 运行带调试器的测试
npx playwright test --debug

# 运行并发测试
npx playwright test --workers=4

# 生成报告
npx playwright test --reporter=html
npx playwright test --reporter=list
```

### 6.2 CI/CD 配置

```yaml
# .github/workflows/e2e.yml
name: E2E Tests

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  e2e:
    timeout-minutes: 30
    runs-on: ubuntu-latest
    
    services:
      postgres:
        image: postgres:15
        env:
          POSTGRES_DB: test_db
          POSTGRES_USER: test
          POSTGRES_PASSWORD: test
        ports:
          - 5432:5432
      
      app:
        build:
          context: .
          dockerfile: Dockerfile
        env:
          DATABASE_URL: postgresql://test:test@localhost:5432/test_db
          PORT: 3000
        ports:
          - 3000:3000
        wait-on: tcp://localhost:3000
    
    steps:
      - uses: actions/checkout@v4
      
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
      
      - name: Install dependencies
        run: npm ci
      
      - name: Install Playwright browsers
        run: npx playwright install --with-deps chromium
      
      - name: Run E2E tests
        run: npx playwright test
        env:
          BASE_URL: http://localhost:3000
      
      - name: Upload Playwright Report
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: playwright-report
          path: playwright-report/
          retention-days: 14
      
      - name: Upload Test Results
        if: failure()
        uses: actions/upload-artifact@v4
        with:
          name: test-results
          path: test-results/
```

### 6.3 Playwright 配置

```typescript
// playwright.config.ts
import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './tests/e2e',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,  // CI 中禁止 only
  retries: process.env.CI ? 2 : 0,  // CI 失败重试
  workers: process.env.CI ? 1 : undefined,  // CI 中串行
  reporter: [
    ['html'],
    ['list', { outputFile: 'test-results.txt' }],
  ],
  
  use: {
    baseURL: process.env.BASE_URL || 'http://localhost:3000',
    trace: 'on-first-retry',  // 首次失败保留 trace
    screenshot: 'only-on-failure',  // 失败时截图
    video: 'retain-on-failure',  // 失败时保留视频
    actionTimeout: 10000,
    navigationTimeout: 30000,
  },
  
  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },
    {
      name: 'firefox',
      use: { ...devices['Desktop Firefox'] },
    },
    {
      name: 'webkit',
      use: { ...devices['Desktop Safari'] },
    },
    // 移动端测试（可选）
    {
      name: 'Mobile Chrome',
      use: { ...devices['Pixel 5'] },
    },
  ],
  
  outputDir: 'test-results/',  // 测试结果目录
});
```

## 七、视觉回归测试（Phase 6: Visual Regression）

### 7.1 Playwright 视觉对比

```typescript
import { test, expect } from '@playwright/test';
import path from 'path';

test('视觉回归测试', async ({ page }) => {
  await page.goto('/devices');
  
  // 截图
  const screenshot = await page.screenshot();
  
  // 保存截图（首次运行）
  if (process.env.UPDATE_SCREENSHOTS) {
    const screenshotPath = path.join('screenshots', 'devices.png');
    fs.writeFileSync(screenshotPath, screenshot);
    return;
  }
  
  // 对比截图
  const baselinePath = path.join('screenshots', 'devices.png');
  const baseline = fs.readFileSync(baselinePath);
  
  // 使用像素对比库
  const diff = pixelmatch(screenshot, baseline, null, width, height, { threshold: 0.1 });
  expect(diff).toBe(0);  // 无像素差异
});
```

### 7.2 使用 reg-suit

```bash
# 安装
npm install -D reg-suit

# 配置 .regrc
{
  "core": {
    "workingDir": ".reg",
    "actualDir": ".reg/actual",
    "expectedDir": ".reg/expected",
    "diffDir": ".reg/diff"
  },
  "plugins": {
    "reg-keygen-git-hash-plugin": {
      "bucket": "your-s3-bucket"
    },
    "reg-notify-github-status-plugin": {
      "owner": "your-org",
      "repo": "your-repo"
    }
  }
}

# 运行对比
npx reg-suit run
```

## 八、E2E 验证铁律（Phase 7: Verification）

### 8.1 重构前必须做

```markdown
### 重构前检查

1. [ ] 运行完整 E2E 测试套件，记录失败用例
2. [ ] 确认测试环境与生产环境一致性
3. [ ] 备份当前测试代码
4. [ ] 确认被重构功能的测试覆盖
5. [ ] 创建重构前的基线截图（如使用视觉回归）
```

### 8.2 重构后必须做

```markdown
### 重构后检查

1. [ ] 更新受影响的测试用例
2. [ ] 添加新增功能的测试用例
3. [ ] 删除废弃功能的测试用例
4. [ ] 运行更新后的完整测试套件
5. [ ] 确认所有测试通过（不允许跳过）
6. [ ] 如有视觉变更，运行视觉回归测试
7. [ ] 提交更新的测试代码
```

### 8.3 测试质量标准

| 标准 | 要求 | 检查方法 |
|------|------|----------|
| **覆盖度** | 核心流程 100% 覆盖 | 检查测试用例数量 |
| **独立性** | 测试间无依赖 | 并发执行测试 |
| **幂等性** | 可重复执行 | 运行两次对比结果 |
| **稳定性** | 无 flaky 测试 | 运行 3 次验证 |
| **可维护性** | Page Object 模式 | 检查页面对象数量 |
| **可读性** | 描述性测试名称 | 代码审查 |

## 九、与 Dev Suite 其他技能集成

### 9.1 与 skill-dev-frontend 集成

前端重构后自动触发：
```
1. 识别受影响的 E2E 测试文件
2. 更新测试中的选择器
3. 更新测试中的断言
4. 运行测试验证
```

### 9.2 与 skill-dev-review 集成

审查 E2E 测试时检查：
```
- [ ] 测试用例覆盖核心功能
- [ ] 选择器使用正确（优先 getByRole）
- [ ] 断言明确（不多余不少）
- [ ] 测试数据清理完整
- [ ] 无 hardcoded 敏感信息
```

### 9.3 与 skill-dev-verification 集成

E2E 测试作为最终验证：
```
1. 启动应用
2. 运行 E2E 测试套件
3. 如有失败，报告具体失败用例
4. 不允许任何失败测试
```

## 十、最佳实践

1. **Page Object 模式** — 页面逻辑与测试逻辑分离
2. **数据驱动测试** — 使用 fixtures 存放测试数据
3. **分层测试** — Unit → Integration → E2E
4. **失败即停** — CI 中不允许失败测试
5. **定期审查** — 定期清理无效测试
6. **文档即测试** — 测试名称描述功能行为

## 十一、常见陷阱

| 陷阱 | 后果 | 避免方法 |
|------|------|----------|
| 选择器脆弱 | 测试频繁失败 | 使用 getByRole/getByLabel |
| 测试依赖 | 并发执行失败 | 独立测试数据 |
| 未清理数据 | 环境污染 | afterEach 清理 |
| 硬编码 URL | 维护困难 | 使用 baseURL |
| 忽略 flaky 测试 | CI 不稳定 | 立即修复 flaky |
| 跳过失败测试 | 问题隐藏 | 不允许 skip |
