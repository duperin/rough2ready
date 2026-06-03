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
  ./install.sh --agent opencode
  ./install.sh --target /path/to/skills

Options:
  --agent codex        Install to ~/.codex/skills/rough2ready
  --agent claude-code  Install to ~/.claude/skills/rough2ready
  --agent opencode     Install as ~/.config/opencode/commands/rough2ready.md
  --target PATH        Install to PATH/rough2ready
  --repo URL           Repository URL used when running from a pipe
  -h, --help           Show help

Examples:
  git clone https://github.com/duperin/rough2ready.git
  cd rough2ready
  ./install.sh --agent codex
  ./install.sh --agent opencode

  curl -fsSL https://raw.githubusercontent.com/duperin/rough2ready/main/install.sh | bash -s -- --agent codex
EOF
}

die() {
  printf 'Error: %s\n' "$1" >&2
  exit 1
}

agent=""
target_root=""
install_kind="skill"

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
    opencode|open-code)
      target_root="$HOME/.config/opencode/commands"
      install_kind="opencode-command"
      ;;
    *)
      die "unsupported agent '$agent'. Use --target for custom agents."
      ;;
  esac
fi

target_dir="$target_root/$SKILL_NAME"
tmp_dir=""
staging_dir=""
staging_file=""

cleanup() {
  if [ -n "$tmp_dir" ] && [ -d "$tmp_dir" ]; then
    rm -rf "$tmp_dir"
  fi
  if [ -n "$staging_dir" ] && [ -d "$staging_dir" ]; then
    rm -rf "$staging_dir"
  fi
  if [ -n "$staging_file" ] && [ -f "$staging_file" ]; then
    rm -f "$staging_file"
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

if [ "$install_kind" = "opencode-command" ]; then
  mkdir -p "$target_root"
  command_file="$target_root/$SKILL_NAME.md"
  staging_file="$(mktemp "${target_root%/}/.${SKILL_NAME}.command.XXXXXX")"

  {
    printf '%s\n' '---'
    printf '%s\n' 'description: Improve a rough prompt and answer it with Rough2Ready'
    printf '%s\n' '---'
    printf '\n'
    printf '%s\n' 'Use the Rough2Ready instructions below to improve and execute this request.'
    printf '\n'
    printf '%s\n' 'User request:'
    printf '%s\n' '$ARGUMENTS'
    printf '\n'
    printf '%s\n' '<rough2ready>'
    cat "$source_dir/SKILL.md"
    printf '\n%s\n' '</rough2ready>'
  } > "$staging_file"

  if [ -e "$command_file" ]; then
    backup_file="${command_file}.bak.$(date +%Y%m%d%H%M%S).$$"
    mv "$command_file" "$backup_file"
    printf 'Backed up existing command to %s\n' "$backup_file"
  fi

  mv "$staging_file" "$command_file"
  printf 'Installed OpenCode command to %s\n' "$command_file"
  printf 'Try: /%s compare product A with product B\n' "$SKILL_NAME"
  exit 0
fi

mkdir -p "$target_root"
staging_dir="$(mktemp -d "${target_root%/}/.${SKILL_NAME}.install.XXXXXX")"
mkdir -p "$staging_dir/$SKILL_NAME"
cp "$source_dir/SKILL.md" "$staging_dir/$SKILL_NAME/SKILL.md"
cp -R "$source_dir/agents" "$staging_dir/$SKILL_NAME/agents"

if [ -e "$target_dir" ]; then
  backup_dir="${target_dir}.bak.$(date +%Y%m%d%H%M%S).$$"
  mv "$target_dir" "$backup_dir"
  printf 'Backed up existing install to %s\n' "$backup_dir"
fi

mv "$staging_dir/$SKILL_NAME" "$target_dir"

printf 'Installed %s to %s\n' "$SKILL_NAME" "$target_dir"
printf 'Try: $%s compare product A with product B\n' "$SKILL_NAME"
