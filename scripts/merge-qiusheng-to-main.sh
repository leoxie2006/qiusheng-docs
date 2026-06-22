#!/usr/bin/env bash

set -Eeuo pipefail

SOURCE_BRANCH="qiusheng"
TARGET_BRANCH="main"
EXCLUDED_PATH="草稿"
REMOTE="origin"
COMMIT_MESSAGE="docs: 合并 qiusheng 分支非草稿内容"
DRY_RUN=false
SKIP_BUILD=false
ASSUME_YES=false

usage() {
  cat <<'EOF'
将 qiusheng 分支中除草稿目录外的内容 squash 合并到 main，并直接推送。

用法：
  scripts/merge-qiusheng-to-main.sh [选项]

选项：
  --source <分支>      源分支，默认 qiusheng
  --target <分支>      目标分支，默认 main
  --exclude <路径>     不合并的仓库路径，默认 草稿
  --remote <名称>      Git remote，默认 origin
  --message <消息>     main 上生成的提交消息
  --dry-run            执行合并和构建检查，但不提交、不推送
  --skip-build         跳过 pnpm -F=docs build
  -y, --yes            不询问，直接提交并推送
  -h, --help           显示帮助

示例：
  pnpm merge:main --dry-run
  pnpm merge:main --yes
EOF
}

die() {
  printf '错误：%s\n' "$*" >&2
  exit 1
}

info() {
  printf '\n==> %s\n' "$*"
}

while (($# > 0)); do
  case "$1" in
    --source)
      (($# >= 2)) || die "--source 缺少分支名"
      SOURCE_BRANCH="$2"
      shift 2
      ;;
    --target)
      (($# >= 2)) || die "--target 缺少分支名"
      TARGET_BRANCH="$2"
      shift 2
      ;;
    --exclude)
      (($# >= 2)) || die "--exclude 缺少路径"
      EXCLUDED_PATH="${2%/}"
      shift 2
      ;;
    --remote)
      (($# >= 2)) || die "--remote 缺少名称"
      REMOTE="$2"
      shift 2
      ;;
    --message)
      (($# >= 2)) || die "--message 缺少内容"
      COMMIT_MESSAGE="$2"
      shift 2
      ;;
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --skip-build)
      SKIP_BUILD=true
      shift
      ;;
    -y | --yes)
      ASSUME_YES=true
      shift
      ;;
    -h | --help)
      usage
      exit 0
      ;;
    *)
      die "未知参数：$1"
      ;;
  esac
done

[[ -n "$EXCLUDED_PATH" && "$EXCLUDED_PATH" != "." ]] ||
  die "排除路径不能是空值或仓库根目录"

command -v git >/dev/null 2>&1 || die "未找到 git"

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" ||
  die "当前目录不在 Git 仓库中"
cd "$REPO_ROOT"

[[ -z "$(git status --porcelain)" ]] ||
  die "工作区有未提交改动，请先提交或暂存后再运行"

git remote get-url "$REMOTE" >/dev/null 2>&1 ||
  die "remote 不存在：$REMOTE"

git show-ref --verify --quiet "refs/heads/$SOURCE_BRANCH" ||
  die "本地源分支不存在：$SOURCE_BRANCH"

TEMP_WORKTREE=""

cleanup() {
  local exit_code=$?

  if [[ -n "$TEMP_WORKTREE" && -d "$TEMP_WORKTREE" ]]; then
    [[ -L "$TEMP_WORKTREE/node_modules" ]] &&
      unlink "$TEMP_WORKTREE/node_modules"
    [[ -L "$TEMP_WORKTREE/docs/node_modules" ]] &&
      unlink "$TEMP_WORKTREE/docs/node_modules"
    git worktree remove --force "$TEMP_WORKTREE" >/dev/null 2>&1 || true
  fi

  exit "$exit_code"
}

trap cleanup EXIT

info "获取远端分支"
git fetch --prune "$REMOTE"

git show-ref --verify --quiet "refs/remotes/$REMOTE/$TARGET_BRANCH" ||
  die "远端目标分支不存在：$REMOTE/$TARGET_BRANCH"

if git show-ref --verify --quiet "refs/remotes/$REMOTE/$SOURCE_BRANCH"; then
  read -r remote_only local_only < <(
    git rev-list --left-right --count \
      "$REMOTE/$SOURCE_BRANCH...$SOURCE_BRANCH"
  )

  ((remote_only == 0)) ||
    die "$SOURCE_BRANCH 落后或已与 $REMOTE/$SOURCE_BRANCH 分叉，请先同步"
fi

if [[ "$DRY_RUN" == false ]]; then
  info "推送源分支 $SOURCE_BRANCH"
  git push "$REMOTE" \
    "refs/heads/$SOURCE_BRANCH:refs/heads/$SOURCE_BRANCH"
  SOURCE_REF="$REMOTE/$SOURCE_BRANCH"
else
  SOURCE_REF="$SOURCE_BRANCH"
fi

TARGET_REF="$REMOTE/$TARGET_BRANCH"
TARGET_SHA="$(git rev-parse "$TARGET_REF")"
SOURCE_SHA="$(git rev-parse "$SOURCE_REF")"
SOURCE_DRAFT_COUNT="$(
  git ls-tree -r --name-only "$SOURCE_REF" -- "$EXCLUDED_PATH" | wc -l |
    tr -d ' '
)"

printf '源分支：%s (%s)\n' "$SOURCE_REF" "${SOURCE_SHA:0:8}"
printf '目标分支：%s (%s)\n' "$TARGET_REF" "${TARGET_SHA:0:8}"
printf '排除路径：%s/（源分支中 %s 个文件）\n' \
  "$EXCLUDED_PATH" "$SOURCE_DRAFT_COUNT"

TEMP_WORKTREE="$(mktemp -d "${TMPDIR:-/tmp}/qiusheng-main-merge.XXXXXX")"
rmdir "$TEMP_WORKTREE"

info "创建临时 main 工作区"
git worktree add --detach "$TEMP_WORKTREE" "$TARGET_REF" >/dev/null

info "squash 合并 $SOURCE_REF"
if ! git -C "$TEMP_WORKTREE" merge --squash -X theirs "$SOURCE_REF"; then
  git -C "$TEMP_WORKTREE" status --short >&2
  die "自动合并失败，请手动检查冲突"
fi

git -C "$TEMP_WORKTREE" rm -r --force --ignore-unmatch \
  -- "$EXCLUDED_PATH" >/dev/null

[[ -z "$(git -C "$TEMP_WORKTREE" ls-files -- "$EXCLUDED_PATH")" ]] ||
  die "安全检查失败：目标树仍包含 $EXCLUDED_PATH/"

if git -C "$TEMP_WORKTREE" diff --cached --quiet; then
  info "没有需要合并的新内容"
  exit 0
fi

info "待合并内容"
git -C "$TEMP_WORKTREE" diff --cached --stat

if [[ "$SKIP_BUILD" == false ]]; then
  command -v pnpm >/dev/null 2>&1 || die "未找到 pnpm"
  [[ -d "$REPO_ROOT/node_modules" ]] ||
    die "缺少 node_modules，请先运行 pnpm install"
  [[ -d "$REPO_ROOT/docs/node_modules" ]] ||
    die "缺少 docs/node_modules，请先运行 pnpm install"

  ln -s "$REPO_ROOT/node_modules" "$TEMP_WORKTREE/node_modules"
  ln -s "$REPO_ROOT/docs/node_modules" "$TEMP_WORKTREE/docs/node_modules"

  info "构建文档"
  (
    cd "$TEMP_WORKTREE"
    pnpm -F=docs build
  )
fi

[[ -z "$(git -C "$TEMP_WORKTREE" ls-files -- "$EXCLUDED_PATH")" ]] ||
  die "构建后安全检查失败：目标树仍包含 $EXCLUDED_PATH/"

if [[ "$DRY_RUN" == true ]]; then
  info "演练通过：未提交、未推送"
  exit 0
fi

if [[ "$ASSUME_YES" == false ]]; then
  [[ -t 0 ]] || die "非交互环境请添加 --yes"
  printf '\n将直接提交并推送到 %s/%s，是否继续？[y/N] ' \
    "$REMOTE" "$TARGET_BRANCH"
  read -r answer
  [[ "$answer" =~ ^[Yy]$ ]] || die "已取消"
fi

info "提交 main"
git -C "$TEMP_WORKTREE" commit -m "$COMMIT_MESSAGE"
MERGE_SHA="$(git -C "$TEMP_WORKTREE" rev-parse HEAD)"

info "确认远端 main 未被其他提交更新"
git fetch "$REMOTE" "$TARGET_BRANCH"
[[ "$(git rev-parse "$TARGET_REF")" == "$TARGET_SHA" ]] ||
  die "$REMOTE/$TARGET_BRANCH 已更新，本次推送已取消，请重新运行脚本"

info "直接推送 $TARGET_BRANCH"
git -C "$TEMP_WORKTREE" push "$REMOTE" \
  "HEAD:refs/heads/$TARGET_BRANCH"

info "完成"
printf '%s 已更新到 %s\n' "$TARGET_BRANCH" "${MERGE_SHA:0:8}"
printf '%s/ 仍只保留在 %s 分支\n' \
  "$EXCLUDED_PATH" "$SOURCE_BRANCH"
