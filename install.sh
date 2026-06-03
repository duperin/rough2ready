#!/usr/bin/env bash
set -euo pipefail

REPO_URL="${ROUGH2READY_REPO_URL:-https://github.com/duperin/rough2ready.git}"
SKILL_NAME="rough2ready"

usage() {
  cat <<'EOF'
Rough2Ready installer

Usage:
  ./install.sh --agent codex
  ./install.sh --agent claude-code
  ./install.sh --target /path/to/skills

Options:
  --agent codex        Install to ~/.codex/skills/rough2ready
  --agent claude-code  Install to ~/.claude/skills/rough2ready
  --target PATH        Install to PATH/rough2ready
  --repo URL           Repository URL used when running from a pipe
  -h, --help           Show help

Examples:
  git clone https://github.com/duperin/rough2ready.git
  cd rough2ready
  ./install.sh --agent codex

  curl -fsSL https://raw.githubusercontent.com/duperin/rough2ready/main/install.sh | bash -s -- --agent codex
EOF
}

die() {
  printf 'Error: %s\n' "$1" >&2
  exit 1
}

agent=""
target_root=""

while [ "$#" -gt 0 ]; do
  case "$1" in
    --agent)
      [ "$#" -ge 2 ] || die "--agent requires a value"
      agent="$2"
      shift 2
      ;;
    --target)
      [ "$#" -ge 2 ] || die "--target requires a value"
      target_root="$2"
      shift 2
      ;;
    --repo)
      [ "$#" -ge 2 ] || die "--repo requires a value"
      REPO_URL="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      die "unknown argument: $1"
      ;;
  esac
done

if [ -z "$target_root" ]; then
  case "$agent" in
    codex|"")
      target_root="$HOME/.codex/skills"
      ;;
    claude-code|claude)
      target_root="$HOME/.claude/skills"
      ;;
    *)
      die "unsupported agent '$agent'. Use --target for custom agents."
      ;;
  esac
fi

target_dir="$target_root/$SKILL_NAME"
tmp_dir=""

cleanup() {
  if [ -n "$tmp_dir" ] && [ -d "$tmp_dir" ]; then
    rm -rf "$tmp_dir"
  fi
}
trap cleanup EXIT

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd || true)"

if [ -n "$script_dir" ] && [ -f "$script_dir/SKILL.md" ] && [ -d "$script_dir/agents" ]; then
  source_dir="$script_dir"
else
  command -v git >/dev/null 2>&1 || die "git is required when installing from a pipe"
  tmp_dir="$(mktemp -d)"
  git clone --depth 1 "$REPO_URL" "$tmp_dir/$SKILL_NAME" >/dev/null
  source_dir="$tmp_dir/$SKILL_NAME"
fi

[ -f "$source_dir/SKILL.md" ] || die "SKILL.md not found in source"
[ -d "$source_dir/agents" ] || die "agents directory not found in source"

mkdir -p "$target_dir"
cp "$source_dir/SKILL.md" "$target_dir/SKILL.md"
rm -rf "$target_dir/agents"
cp -R "$source_dir/agents" "$target_dir/agents"

printf 'Installed %s to %s\n' "$SKILL_NAME" "$target_dir"
printf 'Try: $%s compare produto A com produto B\n' "$SKILL_NAME"
