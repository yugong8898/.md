#!/bin/bash
# WLYD 快速验证脚本 - 每次改动后运行
# 用法: bash .md/scripts/quick-verify.sh

set -e

echo "🔍 WLYD 快速验证开始..."
echo ""

# 1. 检查 git 状态
echo "📋 检查 git 状态..."
if git diff --quiet && git diff --cached --quiet; then
    echo "   ✅ 无未提交改动"
else
    echo "   ⚠️  有未提交改动，请先查看 git diff"
fi
echo ""

# 2. 检查是否有 console.log（排除 node_modules）
echo "🔍 检查 console.log..."
CONSOLE_COUNT=$(git diff --cached --name-only | grep -E '\.(js|ts|vue)$' | xargs grep -n "console\.log" 2>/dev/null | wc -l | xargs)
if [ "$CONSOLE_COUNT" -eq 0 ]; then
    echo "   ✅ 无 console.log"
else
    echo "   ⚠️  发现 $CONSOLE_COUNT 处 console.log"
    git diff --cached --name-only | grep -E '\.(js|ts|vue)$' | xargs grep -n "console\.log" 2>/dev/null || true
fi
echo ""

# 3. 检查是否有大文件（>500KB）
echo "📦 检查大文件..."
LARGE_FILES=$(git diff --cached --name-only | xargs ls -lh 2>/dev/null | awk '$5 ~ /[5-9][0-9][0-9]K|[0-9]+M/ {print $9, $5}')
if [ -z "$LARGE_FILES" ]; then
    echo "   ✅ 无大文件"
else
    echo "   ⚠️  发现大文件："
    echo "$LARGE_FILES"
fi
echo ""

# 4. 运行 ESLint（如果有配置）
echo "🔧 运行 ESLint..."
if [ -f "package.json" ] && grep -q "eslint" package.json; then
    CHANGED_FILES=$(git diff --cached --name-only | grep -E '\.(js|ts|vue)$' || echo "")
    if [ -n "$CHANGED_FILES" ]; then
        if npx eslint $CHANGED_FILES 2>/dev/null; then
            echo "   ✅ ESLint 检查通过"
        else
            echo "   ❌ ESLint 检查失败"
            exit 1
        fi
    else
        echo "   ⏭️  无 JS/TS/Vue 文件改动"
    fi
else
    echo "   ⏭️  未配置 ESLint"
fi
echo ""

# 5. 检查改动范围
echo "📊 改动统计..."
FILES_CHANGED=$(git diff --cached --name-only | wc -l | xargs)
LINES_ADDED=$(git diff --cached --numstat | awk '{sum+=$1} END {print sum}')
LINES_DELETED=$(git diff --cached --numstat | awk '{sum+=$2} END {print sum}')
echo "   文件数: $FILES_CHANGED"
echo "   新增行: $LINES_ADDED"
echo "   删除行: $LINES_DELETED"
echo ""

# 6. 总结
echo "✅ 快速验证完成！"
echo ""
echo "下一步："
echo "  1. 检查 git diff，确认改动符合预期"
echo "  2. 运行 npm run build（如需要）"
echo "  3. 提交代码: git commit -m 'xxx'"
