---
name: skill-dev-frontend
version: 1.0.0
description: |
  前端重构技能 - Vue 组件改造、菜单重构、UI 一致性
  
  适用场景：
  - Vue 组件重构（Composition API / Options API 转换）
  - 菜单结构调整（一级菜单、二级菜单、命名）
  - 表单字段改名与映射
  - UI 组件库升级（Ant Design Vue 版本升级）
  - 状态管理重构（Pinia/Vuex）
  - 路由重构与权限控制
  
  核心原则：
  - 保持向后兼容（API 接口不变）
  - 组件单一职责
  - 样式隔离
  - 可访问性（a11y）
agent_created: true
created_date: 2026-05-07
tags: [frontend, vue, ant-design-vue, refactor, menu, router]
---

# 前端重构技能 (skill-dev-frontend)

## 一、触发条件

当任务涉及以下任一场景时，必须使用本技能：

1. **Vue 组件改造** — 组件拆分/合并/重写
2. **菜单结构调整** — 新增/删除/重命名菜单项
3. **表单重构** — 字段改名、字段增减、验证规则变更
4. **路由重构** — 路由路径修改、嵌套路由调整
5. **UI 组件库升级** — Ant Design Vue 版本升级
6. **状态管理重构** — Pinia store 改造
7. **API 接口调整** — 请求/响应字段映射

## 二、Vue 组件改造（Phase 1: Component Refactor）

### 2.1 组件分析清单

```markdown
### 组件分析

- [ ] 确认组件位置（`src/views/` 或 `src/components/`）
- [ ] 确认组件类型（Page / Layout / Shared / Form / Table）
- [ ] 确认使用的 API（后端接口）
- [ ] 确认使用的 Store（Pinia/Vuex）
- [ ] 确认路由参数使用（`useRoute`、`route.params`）
- [ ] 确认依赖的其他组件
- [ ] 确认国际化配置（i18n）
- [ ] 确认权限控制（按钮级别权限）
```

### 2.2 Vue 3 Composition API 迁移模式

#### 模式 A: Options API → Composition API

```vue
<!-- 迁移前 (Options API) -->
<template>
  <div>
    <a-table :dataSource="data" :columns="columns" />
  </div>
</template>

<script>
export default {
  data() {
    return {
      data: [],
      columns: [
        { title: '名称', dataIndex: 'name' },
        { title: '状态', dataIndex: 'status' },
      ],
    };
  },
  mounted() {
    this.loadData();
  },
  methods: {
    loadData() {
      // 调用 API
    },
  },
};
</script>

<!-- 迁移后 (Composition API) -->
<template>
  <div>
    <a-table :dataSource="data" :columns="columns" :loading="loading" />
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import { getData } from '@/api/module';

const data = ref([]);
const loading = ref(false);
const columns = [
  { title: '名称', dataIndex: 'name' },
  { title: '状态', dataIndex: 'status' },
];

const loadData = async () => {
  loading.value = true;
  try {
    const response = await getData();
    data.value = response.data;
  } finally {
    loading.value = false;
  }
};

onMounted(() => {
  loadData();
});
</script>
```

#### 模式 B: 组件拆分（Large → Small）

```
Before: InstanceForm.vue (800+ lines)
├── 基本信息表单
├── 网络配置表单
├── FFmpeg 配置表单
├── 通道管理
└── 按钮组

After:
├── InstanceForm.vue (容器)
├── BasicInfoForm.vue (基本信息)
├── NetworkConfigForm.vue (网络配置)
├── FfmpegConfigForm.vue (FFmpeg 配置)
├── ChannelManager.vue (通道管理)
└── FormActions.vue (按钮组)
```

### 2.3 Ant Design Vue 组件使用规范

#### 表单验证

```vue
<script setup>
import { reactive, ref } from 'vue';
import { Form, Input, message } from 'ant-design-vue';
import { Rule } from 'ant-design-vue/es/form/interface';

const formRef = ref();
const formState = reactive({
  name: '',
  port: undefined,
  ffmpegPath: '',
});

const rules = {
  name: [
    { required: true, message: '请输入名称', trigger: 'blur' },
    { min: 2, max: 50, message: '名称长度为 2-50 字符', trigger: 'blur' },
  ],
  port: [
    { required: true, message: '请输入端口', trigger: 'blur' },
    { type: 'number', min: 1024, max: 65535, message: '端口范围 1024-65535', trigger: 'blur' },
  ],
  ffmpegPath: [
    { required: true, message: '请输入 FFmpeg 路径', trigger: 'blur' },
    { pattern: /^[\w\-./\\:]+$/, message: '路径格式不正确', trigger: 'blur' },
  ],
};

// 提交处理
const onSubmit = async () => {
  try {
    await formRef.value.validate();
    // 提交表单
    message.success('保存成功');
  } catch (error) {
    // 验证失败
  }
};
</script>

<template>
  <Form
    ref="formRef"
    :model="formState"
    :rules="rules"
    layout="vertical"
  >
    <Form.Item label="名称" name="name">
      <Input v-model:value="formState.name" placeholder="请输入名称" />
    </Form.Item>
    <Form.Item label="端口" name="port">
      <InputNumber v-model:value="formState.port" :min="1024" :max="65535" style="width: 100%" />
    </Form.Item>
  </Form>
</template>
```

#### 表格列配置

```vue
<script setup>
const columns = [
  {
    title: '序号',
    dataIndex: 'index',
    width: 60,
    customRender: ({ index }) => index + 1,
  },
  {
    title: '名称',
    dataIndex: 'name',
    ellipsis: true,  // 文字超出省略
    sorter: true,
  },
  {
    title: '状态',
    dataIndex: 'status',
    width: 100,
    scopedSlots: { customRender: 'status' },  // 使用 slot 自定义渲染
  },
  {
    title: '操作',
    key: 'action',
    width: 150,
    fixed: 'right',  // 固定列
  },
];
</script>

<template>
  <a-table
    :columns="columns"
    :data-source="data"
    :pagination="{ pageSize: 10 }"
    :scroll="{ x: 1200 }"  <!-- 支持横向滚动 -->
    row-key="id"
  >
    <template #bodyCell="{ column, record }">
      <template v-if="column.key === 'status'">
        <a-tag :color="record.status === 'online' ? 'green' : 'red'">
          {{ record.status === 'online' ? '在线' : '离线' }}
        </a-tag>
      </template>
      <template v-if="column.key === 'action'">
        <a-space>
          <a @click="handleEdit(record)">编辑</a>
          <a-popconfirm title="确认删除?" @confirm="handleDelete(record)">
            <a class="danger">删除</a>
          </a-popconfirm>
        </a-space>
      </template>
    </template>
  </a-table>
</template>

<style scoped>
.danger {
  color: #ff4d4f;
}
</style>
```

## 三、菜单重构（Phase 2: Menu Refactor）

### 3.1 菜单分析清单

```markdown
### 菜单分析

- [ ] 确认菜单配置文件位置
  - Vue Router 配置: `src/router/`
  - Ant Design Menu: `App.vue` 或 `Layout.vue`
- [ ] 确认菜单层级（一级/二级/三级）
- [ ] 确认菜单项对应的路由
- [ ] 确认菜单图标配置
- [ ] 确认权限控制（visible / auth）
- [ ] 确认国际化配置
```

### 3.2 菜单重构模式

#### 模式 A: 新增一级菜单

```vue
<!-- App.vue -->
<template>
  <a-layout>
    <a-layout-sider v-model:collapsed="collapsed">
      <div class="logo">GB28181 Simulator</div>
      <a-menu v-model:selectedKeys="selectedKeys" theme="dark" mode="inline">
        <!-- 现有菜单 -->
        <a-menu-item key="dashboard" @click="$router.push('/dashboard')">
          <DashboardOutlined />
          <span>监控面板</span>
        </a-menu-item>

        <!-- 新增：一级菜单 -->
        <a-sub-menu key="basic-data">
          <template #title>
            <SettingOutlined />
            <span>基础数据</span>
          </template>
          <!-- 二级菜单 -->
          <a-menu-item key="device" @click="$router.push('/basic-data/device')">
            设备管理
          </a-menu-item>
          <a-menu-item key="channel" @click="$router.push('/basic-data/channel')">
            通道管理
          </a-menu-item>
        </a-sub-menu>
      </a-menu>
    </a-layout-sider>
  </a-layout>
</template>
```

#### 模式 B: 移动菜单项到新位置

```javascript
// router/index.js - 路由重组
// Before
{
  path: '/video-management',
  component: Layout,
  children: [
    { path: 'instances', name: 'InstanceList', component: () => import('@/views/instances/InstanceList.vue') },
    { path: 'channels', name: 'ChannelList', component: () => import('@/views/channels/ChannelList.vue') },
  ],
}

// After - 移动到基础数据菜单下
{
  path: '/basic-data',
  component: Layout,
  children: [
    // 从 video-management 移入
    { path: 'instances', name: 'InstanceList', component: () => import('@/views/instances/InstanceList.vue') },
    { path: 'channels', name: 'ChannelList', component: () => import('@/views/channels/ChannelList.vue') },
  ],
}
```

#### 模式 C: 重命名菜单项

```vue
<!-- 命名规范：清晰 > 简短 -->
<!-- Before -->
<MenuItem key="video">视频管理</MenuItem>

<!-- After -->
<MenuItem key="video-resources">视频资源</MenuItem>

<!-- 需要同时更新： -->
<!-- 1. 路由 name -->
<!-- 2. 页面标题 -->
<!-- 3. 面包屑 -->
<!-- 4. 国际化 key -->
<!-- 5. 按钮权限 key -->
```

### 3.3 路由重构清单

```markdown
### 路由重构检查

- [ ] 新路由路径已添加到路由配置
- [ ] 旧路由已标记废弃（可选：保留一段时间兼容）
- [ ] 路由守卫（Navigation Guard）已更新
- [ ] 404 页面已测试
- [ ] 面包屑组件已更新
- [ ] 权限配置已同步
```

## 四、表单字段重构（Phase 3: Form Refactor）

### 4.1 字段映射表

```markdown
### 字段映射表

| 旧字段 | 新字段 | 类型变更 | 默认值 | API 映射 |
|--------|--------|----------|--------|----------|
| ffmpegPath | globalFfmpegPath | VARCHAR → TEXT | null | ffmpegPath → ffmpegPath |
| sipPort | platformPort | INT → INT | 5060 | sipPort → platformPort |
| sipId | platformId | VARCHAR(20) → VARCHAR(32) | - | sipId → platformId |
```

### 4.2 前后端字段同步

```typescript
// types/device.ts

// 旧接口
interface OldDevice {
  ffmpegPath: string;
  sipPort: number;
}

// 新接口
interface NewDevice {
  globalFfmpegPath: string;
  platformPort: number;
  platformId: string;
}

// 转换函数（后端返回旧字段，前端需要转换）
export const convertToNew = (old: OldDevice): NewDevice => ({
  globalFfmpegPath: old.ffmpegPath,
  platformPort: old.sipPort,
  platformId: old.sipId,
});

// 反向转换（前端提交新字段）
export const convertToOld = (newDevice: NewDevice): OldDevice => ({
  ffmpegPath: newDevice.globalFmpegPath,
  sipPort: newDevice.platformPort,
});
```

### 4.3 表单字段变更清单

```markdown
### 表单字段变更检查

- [ ] 前端表单字段名已更新
- [ ] 数据转换层已实现
- [ ] 默认值已设置
- [ ] 验证规则已更新
- [ ] 必填标识已调整
- [ ] 提示文字已更新
- [ ] 旧字段已清理（无遗留）
```

## 五、UI 一致性检查（Phase 4: Consistency Check）

### 5.1 命名一致性规则

```
菜单命名：
- 一级菜单：{业务域}（如：基础数据、视频资源）
- 二级菜单：{功能}（如：设备管理、通道管理）
- 按钮：{动作}{对象}（如：添加设备、删除通道）

字段命名：
- 标签：{对象}{属性}（如：设备名称、通道状态）
- 占位符：请输入{对象}{属性}（如：请输入设备名称）
- 错误：{对象}{属性}{错误类型}（如：设备名称不能为空）

消息命名：
- 成功：{动作}{对象}成功（如：保存设备成功）
- 失败：{动作}{对象}失败（如：保存设备失败）
- 确认：确认{动作}{对象}？（如：确认删除设备？）
```

### 5.2 UI 规范检查清单

```markdown
### UI 一致性检查

布局规范：
- [ ] 表单使用垂直布局（labelPosition: top）
- [ ] 列表使用斑马纹（striped）
- [ ] 操作按钮组统一在右侧
- [ ] 页面标题与菜单名称一致

间距规范：
- [ ] 组件间距统一（16px / 24px）
- [ ] 卡片内边距统一（24px）
- [ ] 按钮之间间距 ≥ 8px

颜色规范：
- [ ] 主色调统一（使用主题色）
- [ ] 状态颜色一致（成功 green、警告 orange、危险 red）
- [ ] 禁用状态使用灰色

文字规范：
- [ ] 标签首字母大写（除专有名词）
- [ ] 按钮文字简洁（不超过 4 个字）
- [ ] 提示文字完整（不含糊）
```

## 六、状态管理重构（Phase 5: Store Refactor）

### 6.1 Pinia Store 重构模式

```typescript
// stores/device.ts

// Before (Vuex)
export default {
  namespaced: true,
  state: {
    devices: [],
    currentDevice: null,
  },
  mutations: {
    SET_DEVICES(state, devices) {
      state.devices = devices;
    },
    SET_CURRENT(state, device) {
      state.currentDevice = device;
    },
  },
  actions: {
    async fetchDevices({ commit }) {
      const { data } = await api.getDevices();
      commit('SET_DEVICES', data);
    },
  },
};

// After (Pinia)
import { defineStore } from 'pinia';

export const useDeviceStore = defineStore('device', () => {
  // State
  const devices = ref<Device[]>([]);
  const currentDevice = ref<Device | null>(null);
  const loading = ref(false);

  // Getters
  const deviceCount = computed(() => devices.value.length);
  const onlineDevices = computed(() =>
    devices.value.filter(d => d.status === 'online')
  );

  // Actions
  const fetchDevices = async () => {
    loading.value = true;
    try {
      const { data } = await api.getDevices();
      devices.value = data;
    } finally {
      loading.value = false;
    }
  };

  const setCurrentDevice = (device: Device) => {
    currentDevice.value = device;
  };

  return {
    // State
    devices,
    currentDevice,
    loading,
    // Getters
    deviceCount,
    onlineDevices,
    // Actions
    fetchDevices,
    setCurrentDevice,
  };
});
```

### 6.2 Store 重构检查清单

```markdown
### Store 重构检查

- [ ] 新 Store 已创建
- [ ] 旧 Store 已迁移（状态、getters、actions）
- [ ] 使用新 Store（`useXxxStore()`）替换旧调用
- [ ] 持久化配置已更新（如使用 pinia-plugin-persistedstate）
- [ ] 类型定义已同步更新
```

## 七、API 层重构（Phase 6: API Refactor）

### 7.1 API 适配层

```typescript
// api/device/v1.ts - 旧 API
export const getDevice = (id: string) => {
  return request.get<Device>(`/devices/${id}`);
};

// api/device/v2.ts - 新 API
export const getDeviceDetail = (id: string) => {
  return request.get<DeviceDetail>(`/api/v2/devices/${id}`);
};

// api/adapter.ts - 适配层（平滑迁移）
import { getDevice as getDeviceV1 } from './v1';
import { getDeviceDetail as getDeviceV2 } from './v2';

export const getDevice = async (id: string, useNewApi = false) => {
  if (useNewApi) {
    const { data } = await getDeviceV2(id);
    // 字段映射
    return {
      ...data,
      // 新旧字段映射
      globalFfmpegPath: data.ffmpegPath,
      platformPort: data.sipPort,
    };
  }
  return getDeviceV1(id);
};
```

## 八、测试与验证（Phase 7: Test & Verify）

### 8.1 前端验证清单

```markdown
### 前端重构验证

功能验证：
- [ ] 表单新建功能正常
- [ ] 表单编辑功能正常
- [ ] 表单删除功能正常
- [ ] 列表查询功能正常
- [ ] 分页功能正常
- [ ] 排序功能正常
- [ ] 筛选功能正常
- [ ] 导出功能正常（如有）
- [ ] 导入功能正常（如有）

交互验证：
- [ ] 表单验证提示正常
- [ ] 成功/失败消息正常
- [ ] 确认对话框正常
- [ ] 加载状态正常
- [ ] 空状态展示正常
- [ ] 错误状态展示正常

兼容性验证：
- [ ] 刷新页面状态保持（如有必要）
- [ ] 浏览器后退功能正常
- [ ] 刷新后 URL 参数保持

响应式验证：
- [ ] 桌面端布局正常
- [ ] 平板端布局正常
- [ ] 移动端布局正常（如适用）
```

### 8.2 视觉回归测试

```bash
# 安装 reg-cli 进行视觉回归测试
npm install -D reg-cli

# 配置 .regrc
{
  "apiKey": "your-api-key",
  "newHtml": "artifacts/new",
  "oldHtml": "artifacts/old",
  "diffHtml": "artifacts/diff"
}
```

## 九、与 Dev Suite 其他技能集成

### 9.1 与 brainstorming 集成

在 brainstorming 讨论到前端变更时：
```
提示用户："这个需求涉及前端变更，需要使用 skill-dev-frontend 进行分析。"
询问：
- 是否涉及菜单结构调整？
- 是否涉及表单字段变更？
- 是否需要新增页面还是改造现有页面？
```

### 9.2 与 skill-dev-review 集成

前端审查要点：
```
代码审查：
- [ ] Vue 组件结构清晰
- [ ] Composition API 使用规范
- [ ] Ant Design Vue 使用正确
- [ ] 类型定义完整
- [ ] 样式无冲突（scoped）

UI 审查：
- [ ] 与现有 UI 风格一致
- [ ] 命名规范统一
- [ ] 响应式适配正常
- [ ] 可访问性达标（a11y）
```

### 9.3 与 E2E 测试集成

重构后需要：
1. 更新 Playwright 测试用例
2. 添加新页面的 E2E 测试
3. 删除废弃页面的 E2E 测试
4. 运行完整 E2E 测试套件

## 十、最佳实践

1. **小步迭代** — 每次只重构一个组件或一个功能
2. **保持 API 兼容** — 前端改动不应要求后端同步修改
3. **类型安全** — 使用 TypeScript 确保类型正确
4. **原子提交** — 每次重构单独提交，便于回滚
5. **自动化测试** — 单元测试 + E2E 测试双重保障
6. **文档同步** — 更新 Swagger 文档和 README

## 十一、常见陷阱

| 陷阱 | 后果 | 避免方法 |
|------|------|----------|
| 路由冲突 | 页面无法访问 | 重构后全面测试路由 |
| 样式污染 | 页面样式错乱 | 使用 scoped + BEM |
| 状态丢失 | 用户操作白费 | 状态持久化或提示 |
| API 版本不兼容 | 请求失败 | 保持 API 向后兼容 |
| 缓存未清理 | 显示旧数据 | 迁移后清理缓存 |
| 权限遗漏 | 功能无法访问 | 全面检查权限配置 |
