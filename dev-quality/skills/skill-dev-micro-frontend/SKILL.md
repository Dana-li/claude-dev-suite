---
name: "skill-dev-micro-frontend"
version: "1.0.0"
description: "qiankun 微前端整合 - 主应用改造、子应用开发、多项目整合"
agent_created: true
---

# qiankun 微前端整合技能

## 适用场景

- 多项目整合：将多个独立前端项目整合为统一平台
- 子应用开发：开发基于 qiankun 的微应用
- 主应用改造：将现有项目改造为 qiankun 主应用

---

## 核心概念

### 主应用（Main App）
负责注册子应用、管理生命周期、提供共享依赖

### 子应用（Micro App）
独立运行的前端应用，可被主应用加载

### 关键术语
- `entry`: 子应用入口（支持 HTML 入口或配置对象）
- `activeRule`: 激活子应用的路由规则
- `props`: 主应用向子应用传递数据
- `base`: 子应用的路由基础路径（通常为 activeRule）

---

## 主应用改造步骤

### 1. 安装 qiankun

```bash
# 主应用项目根目录
npm install qiankun
# 或
pnpm add qiankun
```

### 2. 创建微前端配置文件

**推荐目录结构：**
```
src/
├── micro-frontend/
│   ├── apps.ts          # 子应用注册配置
│   ├── index.ts         # 初始化逻辑
│   └── state.ts         # 共享状态（可选）
```

**`apps.ts` - 子应用配置：**
```typescript
import { registerMicroApps, addGlobalUncaughtErrorHandler } from 'qiankun';

const microApps = [
  {
    name: 'sub-app-1',
    entry: '//localhost:8081',  // 子应用开发服务器地址
    container: '#subapp-container',  // 挂载容器
    activeRule: '/sub-app-1',  // 激活路由
    props: {
      // 传递给子应用的数据
      userId: '123',
      token: localStorage.getItem('token'),
    },
  },
  {
    name: 'sub-app-2',
    entry: '//localhost:8082',
    container: '#subapp-container',
    activeRule: '/sub-app-2',
  },
];

export default microApps;
```

**`index.ts` - 初始化：**
```typescript
import { registerMicroApps, start } from 'qiankun';
import microApps from './apps';

export function setupMicroFrontend() {
  registerMicroApps(microApps, {
    beforeLoad: [
      (app) => {
        console.log('[主应用] 开始加载子应用', app.name);
        return Promise.resolve();
      },
    ],
    beforeMount: [
      (app) => {
        console.log('[主应用] 子应用挂载前', app.name);
        return Promise.resolve();
      },
    ],
    afterMount: [
      (app) => {
        console.log('[主应用] 子应用挂载完成', app.name);
        return Promise.resolve();
      },
    ],
  });

  // 添加全局错误处理
  addGlobalUncaughtErrorHandler((event) => {
    console.error('[主应用] 子应用加载失败', event);
  });

  // 启动 qiankun
  start({
    sandbox: {
      experimentalStyleIsolation: true,  // 样式隔离
    },
    prefetch: 'all',  // 预加载所有子应用
  });
}
```

### 3. 在主应用中引入

**`src/main.ts`（Vue/React 项目入口）：**
```typescript
import { setupMicroFrontend } from './micro-frontend';

// 在应用初始化后启动微前端
setupMicroFrontend();
```

### 4. 添加子应用挂载容器

**`src/App.vue` 或 `src/App.tsx`：**
```vue
<template>
  <div id="app">
    <header>主应用头部</header>
    <!-- 子应用挂载点 -->
    <div id="subapp-container"></div>
  </div>
</template>
```

---

## 子应用开发步骤

### 1. 导出生命周期钩子

**`src/main.ts`（Vue 3 示例）：**
```typescript
import { createApp } from 'vue';
import App from './App.vue';
import router from './router';

let instance: any = null;

function render(props: any = {}) {
  const { container } = props;
  instance = createApp(App);
  instance.use(router);
  
  // 挂载到指定容器或默认 #app
  const mountPoint = container ? container.querySelector('#app') : '#app';
  instance.mount(mountPoint);
}

// 独立运行时
if (!window.__POWERED_BY_QIANKUN__) {
  render();
}

// 导出 qiankun 生命周期
export async function bootstrap() {
  console.log('[子应用] bootstrap');
}

export async function mount(props: any) {
  console.log('[子应用] mount', props);
  render(props);
}

export async function unmount() {
  console.log('[子应用] unmount');
  if (instance) {
    instance.unmount();
    instance = null;
  }
}
```

### 2. 配置打包工具（Vite）

**`vite.config.ts`：**
```typescript
import { defineConfig } from 'vite';
import vue from '@vitejs/plugin-vue';
import qiankun from 'vite-plugin-qiankun';

export default defineConfig({
  plugins: [
    vue(),
    qiankun('sub-app-1', {
      useDevMode: true,  // 开发模式下支持 qiankun
    }),
  ],
  server: {
    port: 8081,
    cors: true,  // 允许跨域
    headers: {
      'Access-Control-Allow-Origin': '*',
    },
  },
  base: '/sub-app-1/',  // 子应用基础路径
});
```

### 3. 配置路由（Vue Router）

**`src/router/index.ts`：**
```typescript
import { createRouter, createWebHistory } from 'vue-router';

const router = createRouter({
  // 根据是否作为子应用运行动态调整 base
  history: createWebHistory(
    window.__POWERED_BY_QIANKUN__ ? '/sub-app-1' : '/'
  ),
  routes: [
    // 路由配置
  ],
});

export default router;
```

---

## 多项目整合最佳实践

### 1. 共享依赖优化

**主应用提供共享库：**
```typescript
// 主应用 main.ts
import { setDefaultMountApp } from 'qiankun';
import { SharedModule } from 'shared-module';  // 共享模块

// 将共享模块挂载到 window
window.shared = {
  SharedModule,
};
```

**子应用使用共享依赖：**
```typescript
// 子应用 main.ts
if (window.__POWERED_BY_QIANKUN__) {
  // 使用主应用提供的共享模块
  const { SharedModule } = window.shared;
}
```

### 2. 通信方案

**方案 A：props 传递（推荐）**
```typescript
// 主应用
registerMicroApps([
  {
    name: 'sub-app',
    entry: '//localhost:8081',
    container: '#container',
    activeRule: '/sub-app',
    props: {
      onGlobalStateChange: (callback) => {
        // 状态变化回调
      },
      setGlobalState: (state) => {
        // 设置全局状态
      },
    },
  },
]);
```

**方案 B：自定义事件**
```typescript
// 主应用发送事件
window.dispatchEvent(
  new CustomEvent('main-app-message', { detail: { type: 'UPDATE_USER', data: user } })
);

// 子应用监听
window.addEventListener('main-app-message', (event) => {
  console.log('收到主应用消息', event.detail);
});
```

### 3. 样式隔离

```typescript
// 主应用 start 配置
start({
  sandbox: {
    experimentalStyleIsolation: true,  // 实验性样式隔离
    // 或使用 strictStyleIsolation: true,  // 严格样式隔离（Shadow DOM）
  },
});
```

---

## 常见问题与解决方案

### 问题 1：子应用资源 404

**原因：** 子应用打包后的资源路径不正确

**解决：**
```typescript
// vite.config.ts
export default defineConfig({
  base: '/sub-app-1/',  // 确保 base 配置正确
});
```

### 问题 2：开发环境跨域

**解决：**
```typescript
// vite.config.ts
server: {
  cors: true,
  headers: {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': '*',
    'Access-Control-Allow-Headers': '*',
  },
}
```

### 问题 3：Vue Router 路由冲突

**解决：**
```typescript
// 子应用路由配置
const router = createRouter({
  history: createWebHistory(
    window.__POWERED_BY_QIANKUN__ ? '/sub-app-1' : '/'
  ),
});
```

### 问题 4：子应用挂载失败

**检查清单：**
- [ ] 子应用是否导出了 `bootstrap`、`mount`、`unmount` 生命周期
- [ ] 子应用 `entry` 地址是否正确且在运行
- [ ] 主应用 `container` 选择器是否匹配 DOM 元素
- [ ] 是否存在跨域问题（检查 Network 请求）

---

## 检查清单

### 主应用改造检查
- [ ] 已安装 qiankun
- [ ] 已创建 `micro-frontend/` 配置目录
- [ ] 已在 `main.ts` 中调用 `setupMicroFrontend()`
- [ ] 已添加子应用挂载容器 `<div id="subapp-container">`
- [ ] 已配置 `activeRule` 和 `entry`

### 子应用开发检查
- [ ] 已导出 `bootstrap`、`mount`、`unmount` 生命周期
- [ ] 已安装 `vite-plugin-qiankun`（Vite 项目）
- [ ] 已配置 `vite.config.ts` 的 `base` 和 `cors`
- [ ] 已根据 `__POWERED_BY_QIANKUN__` 调整路由 base
- [ ] 已处理独立运行和微前端运行两种模式

### 整合测试检查
- [ ] 主应用可以正常加载子应用
- [ ] 子应用独立运行正常
- [ ] 路由切换正常
- [ ] 样式隔离生效
- [ ] 通信机制正常工作

---

## 示例项目结构

### 主应用
```
main-app/
├── src/
│   ├── micro-frontend/
│   │   ├── apps.ts
│   │   ├── index.ts
│   │   └── state.ts
│   ├── App.vue
│   └── main.ts
├── package.json
└── vite.config.ts
```

### 子应用
```
sub-app-1/
├── src/
│   ├── main.ts       # 导出生命周期
│   ├── App.vue
│   └── router/
│       └── index.ts  # 动态 base
├── package.json
└── vite.config.ts    # 配置 vite-plugin-qiankun
```

---

## 参考资料

- qiankun 官方文档：https://qiankun.umijs.org/zh
- vite-plugin-qiankun：https://github.com/лиqa/vite-plugin-qiankun
- 微前端架构实践：https://micro-frontends.org/
