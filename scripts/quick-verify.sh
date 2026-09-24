#!/usr/bin/env bash
# WLYD 快速验证脚本
# 用法: bash .md/scripts/quick-verify.sh [--scope unstaged|staged|both] [--files 路径,...] [--allow-files 路径,...]

set -eo pipefail

scope=both
files_given=false
allow_given=false
files_arg=
allow_arg=

die() {
    printf '❌ %s\n' "$1" >&2
    exit 1
}

contains_file() {
    local target="$1" item
    shift
    for item in "$@"; do
        [ "$item" = "$target" ] && return 0
    done
    return 1
}

parse_csv() {
    local remaining="$1" part
    parsed=()
    [ -n "$remaining" ] || die '文件列表不能为空'
    while :; do
        if [[ "$remaining" == *,* ]]; then
            part="${remaining%%,*}"
            remaining="${remaining#*,}"
            [ -n "$remaining" ] || die '文件列表包含空路径'
        else
            part="$remaining"
            remaining=
        fi
        [ -n "$part" ] || die '文件列表包含空路径'
        contains_file "$part" "${parsed[@]}" || parsed[${#parsed[@]}]="$part"
        [ -n "$remaining" ] || break
    done
}

while [ "$#" -gt 0 ]; do
    case "$1" in
        --scope)
            [ "$#" -ge 2 ] || die '--scope 缺少值'
            case "$2" in
                unstaged|staged|both) scope="$2" ;;
                *) die "无效的 scope: $2" ;;
            esac
            shift 2
            ;;
        --files)
            [ "$#" -ge 2 ] || die '--files 缺少值'
            [ "$files_given" = false ] || die '--files 不能重复'
            files_given=true
            files_arg="$2"
            shift 2
            ;;
        --allow-files)
            [ "$#" -ge 2 ] || die '--allow-files 缺少值'
            [ "$allow_given" = false ] || die '--allow-files 不能重复'
            allow_given=true
            allow_arg="$2"
            shift 2
            ;;
        *) die "未知参数: $1" ;;
    esac
done

git rev-parse --is-inside-work-tree >/dev/null 2>&1 || die '当前目录不在 Git 仓库中'

verify_tmp_dir=$(mktemp -d "${TMPDIR:-/tmp}/wlyd-quick-verify.XXXXXX") || die '无法创建临时目录'
trap 'rm -rf "$verify_tmp_dir"' EXIT

collect_diff_files() {
    local mode="$1" output_file="$verify_tmp_dir/${1}-files"
    if [ "$mode" = unstaged ]; then
        git diff --name-only -z -- > "$output_file" || die '读取 unstaged 文件列表失败'
    else
        git diff --cached --name-only -z -- > "$output_file" || die '读取 staged 文件列表失败'
    fi
    while IFS= read -r -d '' file; do
        contains_file "$file" "${diff_files[@]}" || diff_files[${#diff_files[@]}]="$file"
    done < "$output_file"
    if [ "$mode" = unstaged ]; then
        output_file="$verify_tmp_dir/untracked-files"
        git ls-files --others --exclude-standard -z > "$output_file" || die '读取未跟踪文件列表失败'
        while IFS= read -r -d '' file; do
            contains_file "$file" "${untracked_files[@]}" || untracked_files[${#untracked_files[@]}]="$file"
            contains_file "$file" "${diff_files[@]}" || diff_files[${#diff_files[@]}]="$file"
        done < "$output_file"
    fi
}

accumulate_numstat() {
    local mode="$1" file="$2" output_file="$verify_tmp_dir/numstat"
    if [ "$mode" = unstaged ] && contains_file "$file" "${untracked_files[@]}"; then
        added=$(awk 'END {print NR}' "$file") || die "读取未跟踪文件统计失败: $file"
        lines_added=$((lines_added + added))
        return
    fi
    if [ "$mode" = unstaged ]; then
        git diff --numstat -z -- "$file" > "$output_file" || die "读取 unstaged 统计失败: $file"
    else
        git diff --cached --numstat -z -- "$file" > "$output_file" || die "读取 staged 统计失败: $file"
    fi
    while IFS= read -r -d '' entry; do
        added="${entry%%$'\t'*}"
        remainder="${entry#*$'\t'}"
        deleted="${remainder%%$'\t'*}"
        case "$added" in ''|'-') added=0 ;; esac
        case "$deleted" in ''|'-') deleted=0 ;; esac
        lines_added=$((lines_added + added))
        lines_deleted=$((lines_deleted + deleted))
    done < "$output_file"
}

calculate_fingerprint() {
    local input_file="$verify_tmp_dir/fingerprint" file size
    : > "$input_file"
    printf 'scope=%s\0' "$scope" >> "$input_file"
    for file in "${selected[@]}"; do
        printf 'path=%s\0' "$file" >> "$input_file"
        if contains_file "$file" "${untracked_files[@]}"; then
            size=$(wc -c < "$file") || die "读取未跟踪文件失败: $file"
            printf 'untracked-size=%s\0' "$size" >> "$input_file"
            cat "$file" >> "$input_file" || die "读取未跟踪文件失败: $file"
        else
            case "$scope" in
                unstaged) git diff --binary -- "$file" >> "$input_file" || die "生成 unstaged 指纹失败: $file" ;;
                staged) git diff --cached --binary -- "$file" >> "$input_file" || die "生成 staged 指纹失败: $file" ;;
                both) git diff --binary HEAD -- "$file" >> "$input_file" || die "生成完整指纹失败: $file" ;;
            esac
        fi
    done
    if command -v shasum >/dev/null 2>&1; then
        fingerprint=$(shasum -a 256 "$input_file" | awk '{print $1}') || die '计算 SHA-256 失败'
    elif command -v sha256sum >/dev/null 2>&1; then
        fingerprint=$(sha256sum "$input_file" | awk '{print $1}') || die '计算 SHA-256 失败'
    else
        die '缺少 SHA-256 工具（shasum 或 sha256sum）'
    fi
}

diff_files=()
untracked_files=()
if [ "$scope" = unstaged ] || [ "$scope" = both ]; then
    collect_diff_files unstaged
fi
if [ "$scope" = staged ] || [ "$scope" = both ]; then
    collect_diff_files staged
fi

if [ "$allow_given" = true ]; then
    parse_csv "$allow_arg"
    allowed=("${parsed[@]}")
    drift=false
    for file in "${diff_files[@]}"; do
        if ! contains_file "$file" "${allowed[@]}"; then
            printf '❌ 越界改动: %s\n' "$file" >&2
            drift=true
        fi
    done
    for file in "${allowed[@]}"; do
        if ! contains_file "$file" "${diff_files[@]}"; then
            printf '❌ 预期文件未在 %s diff 中: %s\n' "$scope" "$file" >&2
            drift=true
        fi
    done
    [ "$drift" = false ] || exit 1
fi

selected=("${diff_files[@]}")
if [ "$files_given" = true ]; then
    parse_csv "$files_arg"
    selected=()
    for file in "${parsed[@]}"; do
        [ -f "$file" ] || die "--files 指定文件不存在: $file"
        contains_file "$file" "${diff_files[@]}" || die "--files 指定文件不在 $scope diff 中: $file"
        selected[${#selected[@]}]="$file"
    done
fi
[ "${#selected[@]}" -gt 0 ] || die "scope=$scope 没有可验证的改动文件"

printf '🔍 WLYD 快速验证开始...\n'
printf '   scope: %s\n' "$scope"
printf '   受检文件（%s）：\n' "${#selected[@]}"
for file in "${selected[@]}"; do
    printf '   - %s\n' "$file"
done

failed=false
printf '\n🔍 检查新增 console.log...\n'
console_count=0
for file in "${selected[@]}"; do
    case "$file" in
        *.js|*.ts|*.vue)
            if [ "$scope" = unstaged ] || [ "$scope" = both ]; then
                if contains_file "$file" "${untracked_files[@]}"; then
                    hits=$(awk '/console[.]log[[:space:]]*\(/ {print "+" $0}' "$file") || die "读取未跟踪文件失败: $file"
                else
                    hits=$(git diff --unified=0 -- "$file" | awk '/^\+\+\+ / {next} /^\+/ && /console[.]log[[:space:]]*\(/ {print}') || die "读取 unstaged diff 失败: $file"
                fi
                if [ -n "$hits" ]; then
                    printf '   %s (unstaged):\n%s\n' "$file" "$hits"
                    console_count=$((console_count + $(printf '%s\n' "$hits" | wc -l)))
                fi
            fi
            if [ "$scope" = staged ] || [ "$scope" = both ]; then
                hits=$(git diff --cached --unified=0 -- "$file" | awk '/^\+\+\+ / {next} /^\+/ && /console[.]log[[:space:]]*\(/ {print}') || die "读取 staged diff 失败: $file"
                if [ -n "$hits" ]; then
                    printf '   %s (staged):\n%s\n' "$file" "$hits"
                    console_count=$((console_count + $(printf '%s\n' "$hits" | wc -l)))
                fi
            fi
            ;;
    esac
done
if [ "$console_count" -gt 0 ]; then
    printf '   ❌ 发现 %s 处新增 console.log\n' "$console_count"
    failed=true
else
    printf '   ✅ 无新增 console.log\n'
fi

printf '\n📦 检查大文件（>500KB）...\n'
large_count=0
for file in "${selected[@]}"; do
    if [ -f "$file" ]; then
        size=$(wc -c < "$file")
        if [ "$size" -gt 512000 ]; then
            printf '   ❌ %s (%s bytes)\n' "$file" "$size"
            large_count=$((large_count + 1))
        fi
    fi
done
if [ "$large_count" -gt 0 ]; then
    failed=true
else
    printf '   ✅ 无大文件\n'
fi

printf '\n🔧 检查 diff 空白错误...\n'
diff_failed=false
if [ "$scope" = unstaged ] || [ "$scope" = both ]; then
    git diff --check -- "${selected[@]}" || diff_failed=true
    for file in "${selected[@]}"; do
        if contains_file "$file" "${untracked_files[@]}"; then
            awk '/[[:blank:]]$/ { print FNR ": trailing whitespace"; found=1 } END { exit found ? 1 : 0 }' "$file" || diff_failed=true
        fi
    done
fi
if [ "$scope" = staged ] || [ "$scope" = both ]; then
    git diff --cached --check -- "${selected[@]}" || diff_failed=true
fi
if [ "$diff_failed" = true ]; then
    printf '   ❌ diff 检查失败\n'
    failed=true
else
    printf '   ✅ diff 检查通过\n'
fi

printf '\n🔧 运行 ESLint...\n'
lint_files=()
for file in "${selected[@]}"; do
    if [ -f "$file" ]; then
        case "$file" in
            *.js|*.ts|*.vue) lint_files[${#lint_files[@]}]="$file" ;;
        esac
    fi
done
if [ "${#lint_files[@]}" -gt 0 ]; then
    if npx eslint --no-ignore -- "${lint_files[@]}"; then
        printf '   ✅ ESLint 检查通过\n'
    else
        printf '   ❌ ESLint 检查失败（含配置缺失）\n'
        failed=true
    fi
else
    printf '   ⏭️  无 JS/TS/Vue 文件改动\n'
fi

printf '\n📊 改动统计...\n'
lines_added=0
lines_deleted=0
for file in "${selected[@]}"; do
    if [ "$scope" = unstaged ] || [ "$scope" = both ]; then
        accumulate_numstat unstaged "$file"
    fi
    if [ "$scope" = staged ] || [ "$scope" = both ]; then
        accumulate_numstat staged "$file"
    fi
done
printf '   文件数: %s\n' "${#selected[@]}"
printf '   新增行: %s\n' "$lines_added"
printf '   删除行: %s\n' "$lines_deleted"

[ "$failed" = false ] || die '快速验证未通过'
calculate_fingerprint
printf '   差异指纹 SHA-256: %s\n' "$fingerprint"
printf '\n✅ 快速验证完成！\n'

# [Task 2] 旧版只扫描暂存区，保留原逻辑以便追溯。
: <<'LEGACY_QUICK_VERIFY'
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
LEGACY_QUICK_VERIFY
