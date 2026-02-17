# Emacs Keybinding Cheatsheet

快速入口：
- `C-c ?` 打开这份 cheatsheet
- `C-h k` 然后按某个键，查看它绑定到什么命令

## 1. 高频直达（优先记）

### Completion / Navigation
- `C-c b`: `consult-buffer`
- `C-c p`: `consult-project-buffer`
- `C-c f`: `consult-find`
- `C-c s`: `consult-ripgrep`
- `C-c /`: `consult-line`
- `C-c i`: `consult-imenu`

### LSP 高频
- `C-c d`: `xref-find-definitions`
- `C-c u`: `xref-find-references`
- `C-c r`: `eglot-rename`
- `C-c a`: `eglot-code-actions`
- `C-c n`: `flymake-goto-next-error`
- `C-c j`: `flymake-goto-prev-error`
- `C-c e`: `eldoc-box-help-at-point`

### Window / Terminal / Git / Help
- `M-o`  : `ace-window`
- `C-c t`: `vterm`
- `C-c v`: `vterm-other-window`
- `C-c g`: `magit-status`
- `C-c h`: `helpful-at-point`

## 2. 低频前缀

### `C-c l` (LSP advanced)
- `C-c l s`: 启动/连接 LSP (`eglot`)
- `C-c l q`: 关闭 LSP (`eglot-shutdown`)
- `C-c l c`: 重连 LSP (`eglot-reconnect`)
- `C-c l o`: 整理 imports
- `C-c l f`: 格式化 buffer
- `C-c l i`: 跳实现
- `C-c l t`: 跳类型定义
- `C-c l b`: 打开 `eldoc-doc-buffer`
- `C-c l e`: 打开 `eglot-events-buffer`

### `C-c c` (Extra)
- `C-c c g`: `consult-goto-line`
- `C-c c o`: `consult-outline`
- `C-c c e`: `consult-compile-error`
- `C-c c n`: `consult-flymake`
- `C-c c h`: `consult-history`
- `C-c c m`: `consult-mode-command`
- `C-c c k`: `consult-kmacro`
- `C-c c y`: `consult-yank-pop`
- `C-c c x`: `consult-bookmark`
- `C-c c v`: `vertico-repeat`
- `C-c c d`: `magit-dispatch`
- `C-c c f`: `magit-file-dispatch`

### `C-c m` (Multiple Cursors)
- `C-c m l`: 按行多光标
- `C-c m n`: 标记下一个相同项
- `C-c m p`: 标记上一个相同项
- `C-c m a`: 标记全部相同项
- `C-c m s`: 跳过下一个相同项
- `C-c m b`: 跳过上一个相同项

### `C-c y` (Snippets)
- `C-c y e`: 展开 snippet
- `C-c y i`: 插入 snippet
- `C-c y n`: 新建 snippet
- `C-c y v`: 打开 snippet 文件
- `C-c y r`: 重载 snippets

## 3. 其他编辑增强

- `C-,`: 复制当前行
- `M-<up>` / `M-<down>`: 上移/下移当前行或选区

## 4. Markdown 工作流

在 `markdown-mode/gfm-mode` 中：
- `C-c C-c p`: 在浏览器中预览 HTML
- `C-c C-c l`: 在另一边切换 live preview（Emacs 内预览）
- 预览 HTML 使用临时文件（`/tmp`）并自动清理，不会在 `.md` 文件旁生成残留 HTML

## 5. 建议练习顺序

1. 先练 10 个：`C-c b/f/s/d/u/a/n/e/o/t`
2. 第二阶段：`C-c g/r/p/i/v/h`
3. 最后补齐前缀：`C-c l ...`、`C-c c ...`、`C-c m ...`、`C-c y ...`
