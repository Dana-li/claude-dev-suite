# Vue 编码规范

> 本规则适用于 Vue 3 项目开发

## 组件规范

### 命名

| 类型 | 规范 | 示例 |
|------|------|------|
| 组件文件名 | PascalCase | `UserCard.vue`, `OrderList.vue` |
| 组件名 | PascalCase | `name: 'UserCard'` |
| 组件标签 | kebab-case | `<user-card>`, `<order-list>` |

### 结构顺序

```vue
<script setup lang="ts">
// 1. 导入
import { ref, computed } from 'vue'
import UserCard from './UserCard.vue'

// 2. Props
interface Props {
  title: string
  users: User[]
}
const props = withDefaults(defineProps<Props>(), {
  title: '默认标题',
  users: () => []
})

// 3. Emits
const emit = defineEmits<{
  (e: 'update', value: User): void
  (e: 'delete', id: number): void
}>()

// 4. 响应式数据
const loading = ref(false)
const selectedId = ref<number | null>(null)

// 5. 计算属性
const hasUsers = computed(() => props.users.length > 0)
const userCount = computed(() => props.users.length)

// 6. 方法
function handleSelect(user: User) {
  selectedId.value = user.id
  emit('update', user)
}

// 7. 生命周期
onMounted(() => {
  fetchUsers()
})
</script>

<template>
  <div class="user-list">
    <h2>{{ title }}</h2>
    <div v-if="loading">加载中...</div>
    <div v-else-if="hasUsers">
      <UserCard
        v-for="user in users"
        :key="user.id"
        :user="user"
        :selected="selectedId === user.id"
        @select="handleSelect"
      />
    </div>
    <EmptyState v-else message="暂无数据" />
  </div>
</template>

<style scoped>
.user-list {
  padding: 16px;
}
</style>
```

## TypeScript 规范

### 类型定义

```typescript
// ✅ 接口命名
interface User {
  id: number
  name: string
  email: string
}

// ✅ 使用 type 别名
type UserStatus = 'active' | 'inactive' | 'banned'

// ✅ Props 类型
interface Props {
  user: User
  loading?: boolean
}
```

## 样式规范

### Scoped CSS

```vue
<style scoped>
/* ✅ 使用 BEM 或 scoped 避免冲突 */
.user-list {
  padding: 16px;
}

.user-list__title {
  font-size: 18px;
  font-weight: 600;
}

.user-list--loading {
  opacity: 0.6;
}
</style>
```

### CSS 变量

```vue
<style scoped>
:root {
  --primary-color: #1890ff;
  --border-radius: 4px;
}

.button {
  background-color: var(--primary-color);
  border-radius: var(--border-radius);
}
</style>
```

## API 调用规范

### 使用 Composables

```typescript
// composables/useUser.ts
import { ref } from 'vue'
import type { User } from '@/types'

export function useUser() {
  const users = ref<User[]>([])
  const loading = ref(false)
  const error = ref<string | null>(null)

  async function fetchUsers() {
    loading.value = true
    error.value = null
    try {
      const { data } = await api.get<User[]>('/users')
      users.value = data
    } catch (e) {
      error.value = '获取用户列表失败'
    } finally {
      loading.value = false
    }
  }

  return {
    users,
    loading,
    error,
    fetchUsers
  }
}
```

## 性能规范

### 懒加载

```typescript
// ✅ 路由懒加载
const UserDetail = () => import('./views/UserDetail.vue')

// ✅ 组件懒加载
const HeavyChart = defineAsyncComponent(() => import('./HeavyChart.vue'))

// ✅ 图片懒加载
<img v-lazy="src" alt="description" />
```

### 避免响应式过度

```typescript
// ❌ 不必要的响应式
const config = reactive({
  apiUrl: 'https://api.example.com',
  timeout: 5000,
  retryCount: 3,
})

// ✅ 静态配置不需要响应式
const CONFIG = {
  apiUrl: 'https://api.example.com',
  timeout: 5000,
  retryCount: 3,
}
```
