#!/usr/bin/env bash
set -uo pipefail

source_script="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/quick-verify.sh"
fixture_root="$(mktemp -d)" || exit 1
trap 'rm -rf "$fixture_root"' EXIT

passed=0
failed=0

pass() {
    printf 'PASS %s\n' "$1"
    passed=$((passed + 1))
}

fail() {
    printf 'FAIL %s: %s\n' "$1" "$2"
    printf '  exit=%s\n' "$status"
    sed 's/^/  output: /' "$fixture/output.txt"
    failed=$((failed + 1))
}

new_fixture() {
    local name="$1"
    fixture="$fixture_root/$name"
    mkdir -p "$fixture/.md/scripts" "$fixture/bin" "$fixture/src"
    cp "$source_script" "$fixture/.md/scripts/quick-verify.sh"
    printf '{"devDependencies":{"eslint":"test"}}\n' > "$fixture/package.json"
    printf '<script>export default {}</script>\n' > "$fixture/src/a.vue"
    printf '<script>export default {}</script>\n' > "$fixture/src/b.vue"
    printf '<script>export default {}</script>\n' > "$fixture/src/c.vue"
    printf 'bin/\nindex-before.txt\nindex-after.txt\noutput.txt\nnpx-args.txt\n' > "$fixture/.gitignore"
    printf '#!/usr/bin/env bash\nprintf "%%s\\n" "$@" > "$MOCK_NPX_LOG"\n' > "$fixture/bin/npx"
    chmod +x "$fixture/bin/npx"
    git -C "$fixture" init -q
    git -C "$fixture" config user.name 'Quick Verify Test'
    git -C "$fixture" config user.email 'quick-verify-test@example.invalid'
    git -C "$fixture" add -- .gitignore .md/scripts/quick-verify.sh package.json src/a.vue src/b.vue src/c.vue
    git -C "$fixture" commit -qm 'fixture baseline'
}

run_verify() {
    git -C "$fixture" ls-files --stage -z > "$fixture/index-before.txt"
    (
        cd "$fixture" || exit 1
        PATH="$fixture/bin:$PATH" MOCK_NPX_LOG="$fixture/npx-args.txt" \
            bash .md/scripts/quick-verify.sh "$@"
    ) > "$fixture/output.txt" 2>&1
    status=$?
    git -C "$fixture" ls-files --stage -z > "$fixture/index-after.txt"
}

assert_index_unchanged() {
    local name="$1"
    if cmp -s "$fixture/index-before.txt" "$fixture/index-after.txt"; then
        pass "$name: 暂存区文件快照未变"
    else
        fail "$name: 暂存区文件快照发生变化"
    fi
}

assert_rejected() {
    local name="$1"
    if [ "$status" -ne 0 ]; then
        pass "$name"
    else
        fail "$name" '应非零退出'
    fi
    assert_index_unchanged "$name"
}

new_fixture empty_unstaged
run_verify --scope unstaged
assert_rejected '空的 --scope unstaged'
if ! grep -Eq '✅.*通过|✅ 快速验证完成' "$fixture/output.txt"; then
    pass '空的 --scope unstaged 不显示通过'
else
    fail '空的 --scope unstaged 不显示通过' '出现成功标记'
fi

new_fixture unstaged_console
printf '<script>console.log("new")</script>\n' >> "$fixture/src/a.vue"
run_verify --scope unstaged
assert_rejected '未暂存 Vue 文件新增 console.log'

new_fixture allow_mismatch
printf '<script>export default { name: "changed" }</script>\n' >> "$fixture/src/b.vue"
git -C "$fixture" add -- src/b.vue
run_verify --scope staged --allow-files src/a.vue
if [ "$status" -ne 0 ] && grep -q 'src/b.vue' "$fixture/output.txt"; then
    pass '--allow-files 拒绝越界文件并列出文件名'
else
    fail '--allow-files 拒绝越界文件并列出文件名' '应非零退出并列出 src/b.vue'
fi
assert_index_unchanged '--allow-files 越界'

new_fixture nonexistent_file
printf '<script>export default { name: "changed" }</script>\n' >> "$fixture/src/b.vue"
git -C "$fixture" add -- src/b.vue
run_verify --scope staged --files src/missing.vue
assert_rejected '--files 拒绝不存在的文件'

new_fixture unchanged_file
printf '<script>export default { name: "changed" }</script>\n' >> "$fixture/src/b.vue"
git -C "$fixture" add -- src/b.vue
run_verify --scope staged --files src/c.vue
assert_rejected '--files 拒绝未在当前 diff 的文件'

new_fixture selected_file_only
printf '<script>export default { name: "selected" }</script>\n' >> "$fixture/src/a.vue"
printf '<script>console.log("not selected")</script>\n' >> "$fixture/src/b.vue"
git -C "$fixture" add -- src/a.vue src/b.vue
run_verify --scope staged --files src/a.vue
if [ "$status" -eq 0 ] && [ -f "$fixture/npx-args.txt" ] && \
    grep -Fxq -- 'src/a.vue' "$fixture/npx-args.txt" && \
    ! grep -Fxq -- 'src/b.vue' "$fixture/npx-args.txt" && \
    ! grep -Fq -- 'src/b.vue' "$fixture/output.txt"; then
    pass '--files 只把合法目标交给 ESLint'
else
    fail '--files 只把合法目标交给 ESLint' '应成功，ESLint 参数仅包含 src/a.vue，输出不检查 src/b.vue'
fi
assert_index_unchanged '--files 合法目标'

new_fixture eslint_no_ignore
printf '<script>export default { name: "changed" }</script>\n' >> "$fixture/src/a.vue"
git -C "$fixture" add -- src/a.vue
run_verify --scope staged
if [ -f "$fixture/npx-args.txt" ] && grep -qx -- '--no-ignore' "$fixture/npx-args.txt"; then
    pass 'ESLint 参数包含 --no-ignore'
else
    fail 'ESLint 参数包含 --no-ignore' 'npx 替身未收到 --no-ignore'
fi
assert_index_unchanged 'ESLint 调用'

new_fixture spaced_path
printf '<script>export default {}</script>\n' > "$fixture/src/with space.vue"
git -C "$fixture" add -- 'src/with space.vue'
git -C "$fixture" commit -qm 'track spaced path'
printf '<script>export default { name: "changed" }</script>\n' >> "$fixture/src/with space.vue"
run_verify --scope unstaged --files 'src/with space.vue'
if [ "$status" -eq 0 ] && grep -Fxq -- 'src/with space.vue' "$fixture/npx-args.txt"; then
    pass '含空格路径原样交给 ESLint'
else
    fail '含空格路径原样交给 ESLint' '应成功且不拆分文件名'
fi
assert_index_unchanged '含空格路径'

new_fixture both_dedup
printf '<script>export default { name: "staged" }</script>\n' >> "$fixture/src/a.vue"
git -C "$fixture" add -- src/a.vue
printf '<script>export default { name: "unstaged" }</script>\n' >> "$fixture/src/a.vue"
run_verify --scope both --allow-files src/a.vue
if [ "$status" -eq 0 ] && grep -Fq '文件数: 1' "$fixture/output.txt" && \
    grep -Fq '新增行: 2' "$fixture/output.txt"; then
    pass 'both 合并同一路径并汇总两侧统计'
else
    fail 'both 合并同一路径并汇总两侧统计' '应统计一个文件、两行新增'
fi
assert_index_unchanged 'both 去重'

new_fixture invalid_arguments
run_verify --scope unexpected
assert_rejected '未知 scope'
run_verify --files ''
assert_rejected '空 --files'
run_verify --unknown
assert_rejected '未知参数'

new_fixture lint_failure
printf '#!/usr/bin/env bash\nexit 5\n' > "$fixture/bin/npx"
printf '<script>export default { name: "changed" }</script>\n' >> "$fixture/src/a.vue"
git -C "$fixture" add -- src/a.vue
run_verify --scope staged
assert_rejected 'ESLint 非零退出'

new_fixture diff_check
printf '<script>export default {}</script>  \n' >> "$fixture/src/a.vue"
run_verify --scope unstaged
assert_rejected 'diff --check 空白错误'

new_fixture git_read_failure
printf '<script>export default { name: "changed" }</script>\n' >> "$fixture/src/a.vue"
git -C "$fixture" add -- src/a.vue
real_git="$(command -v git)"
printf '#!/usr/bin/env bash\nif [ "$1" = diff ] && [ "$2" = --name-only ]; then exit 128; fi\nexec "%s" "$@"\n' "$real_git" > "$fixture/bin/git"
chmod +x "$fixture/bin/git"
run_verify --scope both
if [ "$status" -ne 0 ] && ! grep -Fq '✅ 快速验证完成' "$fixture/output.txt"; then
    pass 'Git diff 读取失败必须向上传播'
else
    fail 'Git diff 读取失败必须向上传播' 'git diff exit 128 时不得误报成功'
fi
assert_index_unchanged 'Git diff 读取失败'

new_fixture untracked_source
printf '<script>export default { name: "new" }</script>\n' > "$fixture/src/new.vue"
run_verify --scope unstaged --allow-files src/new.vue
if [ "$status" -eq 0 ] && grep -Fxq -- 'src/new.vue' "$fixture/npx-args.txt"; then
    pass 'unstaged 必须检查未跟踪源码文件'
else
    fail 'unstaged 必须检查未跟踪源码文件' '新建源码必须进入受检列表并传给 ESLint'
fi
assert_index_unchanged '未跟踪源码文件'

new_fixture untracked_console
printf '<script>console.log("untracked")</script>\n' > "$fixture/src/new.vue"
run_verify --scope unstaged --allow-files src/new.vue
if [ "$status" -ne 0 ] && grep -Fq '新增 console.log' "$fixture/output.txt"; then
    pass '未跟踪源码中的 console.log 必须被拦截'
else
    fail '未跟踪源码中的 console.log 必须被拦截' '应由 console.log 门禁失败，而非范围检查失败'
fi
assert_index_unchanged '未跟踪源码 console.log'

new_fixture diff_fingerprint
printf '<script>export default { name: "first" }</script>\n' >> "$fixture/src/a.vue"
run_verify --scope unstaged --files src/a.vue
first_fingerprint=$(awk '/差异指纹 SHA-256:/ {print $NF}' "$fixture/output.txt")
printf '<script>export default { name: "second" }</script>\n' >> "$fixture/src/a.vue"
run_verify --scope unstaged --files src/a.vue
second_fingerprint=$(awk '/差异指纹 SHA-256:/ {print $NF}' "$fixture/output.txt")
if [ "$status" -eq 0 ] && [ "${#first_fingerprint}" -eq 64 ] && [ "${#second_fingerprint}" -eq 64 ] && [ "$first_fingerprint" != "$second_fingerprint" ]; then
    pass '代码变化必须改变差异指纹'
else
    fail '代码变化必须改变差异指纹' '每次成功验证应输出 64 位 SHA-256，且内容变化后不同'
fi
assert_index_unchanged '差异指纹'

printf '结果: %s 通过，%s 失败\n' "$passed" "$failed"
if [ "$failed" -ne 0 ]; then
    exit 1
fi
