#!/usr/bin/env bash
# Install deribit-options-monitor as a Claude Code skill

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="$SCRIPT_DIR/deribit-options-monitor"
SKILL_DIR="$HOME/.claude/skills/deribit-options-monitor"
VENV_DIR="$SCRIPT_DIR/.venv"

# Check Python 3.10+
PYTHON=""
for cmd in python3.13 python3.12 python3.11 python3.10 python3; do
  if command -v "$cmd" >/dev/null 2>&1; then
    version=$("$cmd" -c "import sys; print(sys.version_info[:2])")
    major=$("$cmd" -c "import sys; print(sys.version_info[0])")
    minor=$("$cmd" -c "import sys; print(sys.version_info[1])")
    if [ "$major" -ge 3 ] && [ "$minor" -ge 10 ]; then
      PYTHON="$cmd"
      break
    fi
  fi
done

if [ -z "$PYTHON" ]; then
  echo "Error: Python 3.10+ is required but not found."
  echo "Install it with: brew install python@3.13"
  exit 1
fi

echo "Using Python: $PYTHON ($($PYTHON --version))"

# Create venv and install dependencies
if [ ! -d "$VENV_DIR" ]; then
  echo "Creating virtual environment..."
  "$PYTHON" -m venv "$VENV_DIR"
fi

echo "Installing dependencies..."
"$VENV_DIR/bin/pip" install -q requests

# Verify tool works
echo "Running health check..."
cd "$SOURCE_DIR"
"$VENV_DIR/bin/python" __init__.py doctor

# Install skill
mkdir -p "$(dirname "$SKILL_DIR")"

# Update skill.md with actual paths
PYTHON_PATH="$VENV_DIR/bin/python"
WORK_DIR="$SOURCE_DIR"

sed \
  -e "s|__PYTHON_PATH__|$PYTHON_PATH|g" \
  -e "s|__WORK_DIR__|$WORK_DIR/|g" \
  "$SCRIPT_DIR/claude-code/skill.md" > /tmp/deribit-skill.md

mkdir -p "$SKILL_DIR"
cp /tmp/deribit-skill.md "$SKILL_DIR/skill.md"
rm /tmp/deribit-skill.md

echo ""
echo "Done! Skill installed to: $SKILL_DIR"
echo "Python venv: $VENV_DIR"
echo ""
echo "Now open Claude Code and try:"
echo '  "BTC 期权怎么样"'
echo '  "有什么收租机会"'
echo '  "ETH 期权波动率健康吗"'
