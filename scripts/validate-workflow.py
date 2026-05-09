#!/usr/bin/env python3
"""
工作流配置验证脚本
验证 dev-workflow/workflows/ 下的 YAML 配置文件是否合法
"""

import os
import sys
import yaml
import json

WORKFLOWS_DIR = os.path.join(os.path.dirname(__file__), '..', 'dev-workflow', 'workflows')

REQUIRED_FIELDS = ['name', 'version', 'phases']
PHASE_REQUIRED_FIELDS = ['id', 'name', 'required']


def validate_workflow(file_path):
    """验证单个工作流配置文件"""
    errors = []
    warnings = []
    
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            config = yaml.safe_load(f)
    except Exception as e:
        return [], [f"YAML 解析失败: {e}"]
    
    # 检查必需字段
    for field in REQUIRED_FIELDS:
        if field not in config:
            errors.append(f"缺少必需字段: {field}")
    
    if 'phases' in config:
        phase_ids = []
        
        for i, phase in enumerate(config['phases']):
            phase_prefix = f"phases[{i}]"
            
            # 检查 phase 必需字段
            for field in PHASE_REQUIRED_FIELDS:
                if field not in phase:
                    errors.append(f"{phase_prefix} 缺少必需字段: {field}")
            
            if 'id' in phase:
                phase_ids.append(str(phase['id']))
            
            # 检查 depends_on 引用
            if 'depends_on' in phase:
                for dep in phase['depends_on']:
                    if dep not in phase_ids and dep not in [str(p.get('id', '')) for p in config['phases']]:
                        warnings.append(f"{phase_prefix} (id={phase.get('id')}) 依赖的 phase {dep} 未定义")
        
        # 检查 phase id 是否唯一
        if len(phase_ids) != len(set(phase_ids)):
            errors.append("phase id 不唯一")
    
    return errors, warnings


def main():
    """主函数"""
    print("🔍 验证工作流配置...\n")
    
    if not os.path.exists(WORKFLOWS_DIR):
        print(f"❌ 工作流目录不存在: {WORKFLOWS_DIR}")
        sys.exit(1)
    
    yaml_files = [f for f in os.listdir(WORKFLOWS_DIR) if f.endswith('.yaml') or f.endswith('.yml')]
    
    if not yaml_files:
        print(f"⚠️  未找到 YAML 文件 in {WORKFLOWS_DIR}")
        sys.exit(0)
    
    all_passed = True
    
    for yaml_file in yaml_files:
        file_path = os.path.join(WORKFLOWS_DIR, yaml_file)
        errors, warnings = validate_workflow(file_path)
        
        status = "✅" if not errors else "❌"
        print(f"{status} {yaml_file}")
        
        for warning in warnings:
            print(f"   ⚠️  {warning}")
        
        for error in errors:
            print(f"   ❌ {error}")
            all_passed = False
        
        print()
    
    if all_passed:
        print("🎉 所有工作流配置验证通过！")
        sys.exit(0)
    else:
        print("💥 存在配置错误，请修复后重试")
        sys.exit(1)


if __name__ == '__main__':
    main()
